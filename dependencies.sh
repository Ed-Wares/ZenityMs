#!/bin/bash

# ==============================================================================
# MSYS2 Dependency Auditor (Parallel Edition)
# Features: Recursive LDD, Parallel Version Extraction, Elapsed Timer
# ==============================================================================

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_executable_or_dll>"
    exit 1
fi

# Reset bash built-in timer
SECONDS=0

# Colors
GREEN='\033[0;32m'
BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure dependencies exist
for tool in strings xargs nproc; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}Error: '$tool' command not found.${NC}"
        echo "Please run: pacman -S binutils findutils coreutils"
        exit 1
    fi
done

TARGET=$(cygpath -u "$1")
THREADS=$(nproc) # Auto-detect CPU cores
if [ -z "$THREADS" ]; then THREADS=4; fi

# State tracking
declare -A VISITED
declare -A ALL_DEPS
declare -A MISSING_DEPS
FILES_TO_CHECK=("$TARGET")

echo "============================================================"
echo -e "🔎 ${BLUE}Starting Audit${NC} (Using $THREADS parallel threads)"
echo "   Target: $(cygpath -w "$TARGET")"
echo "============================================================"

# ------------------------------------------------------------------------------
# FUNCTION: Worker Process (Exported for Parallel Execution)
# ------------------------------------------------------------------------------
get_version_worker() {
    # Input format: "DLL_NAME|UNIX_PATH"
    local line="$1"
    local key=$(echo "$line" | cut -d'|' -f1)
    local path=$(echo "$line" | cut -d'|' -f2)
    
    # 1. Get Windows Path
    local win_path=$(cygpath -w "$path")
    
    # 2. Extract Version (Fast 'strings' method)
    local ver=$(strings -e l "$path" 2>/dev/null | grep -A 1 "^FileVersion$" | head -n 2 | tail -n 1 | tr -d '\r')
    if [ -z "$ver" ]; then
         ver=$(strings -e l "$path" 2>/dev/null | grep -A 1 "^ProductVersion$" | head -n 2 | tail -n 1 | tr -d '\r')
    fi
    
    # Clean up whitespace
    ver=$(echo "$ver" | awk '{$1=$1;print}')
    if [ -z "$ver" ]; then ver="Unknown"; fi
    
    # Output result
    echo "$key -> $win_path [$ver]"
}
export -f get_version_worker

# ------------------------------------------------------------------------------
# PHASE 1: Recursive Scan (Single Threaded - Needs Sequential Logic)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}Phase 1: Recursive Dependency Scan...${NC}"

# Helper: Is System DLL?
is_system_dll() {
    echo "$1" | grep -qiE "^/c/windows|^/c/winnt"
}

SCAN_COUNT=0

while [ ${#FILES_TO_CHECK[@]} -gt 0 ]; do
    CURRENT_FILE="${FILES_TO_CHECK[0]}"
    FILES_TO_CHECK=("${FILES_TO_CHECK[@]:1}")

    if [ "${VISITED[$CURRENT_FILE]}" ]; then continue; fi
    VISITED["$CURRENT_FILE"]=1
    ((SCAN_COUNT++))
    
    # Update Status with Timer
    ELAPSED=$(date -u -d @${SECONDS} +"%T")
    printf "\r   [%s] Scanned: %d | Currently: %s\033[K" "$ELAPSED" "$SCAN_COUNT" "$(basename "$CURRENT_FILE")"

    while read -r line; do
        read -r NAME ARROW PATH_OR_STATUS _ <<< "$line"
        #lowercase the filename and path
        NAME=${NAME,,}
        PATH_OR_STATUS=${PATH_OR_STATUS,,}

        if [ "$ARROW" == "=>" ]; then
            if [ "$PATH_OR_STATUS" == "not" ]; then
                MISSING_DEPS["$NAME"]="$CURRENT_FILE"
            elif [ "$PATH_OR_STATUS" != "" ]; then
                ALL_DEPS["$NAME"]="$PATH_OR_STATUS"
                
                if [ -z "${VISITED[$PATH_OR_STATUS]}" ]; then
                    if ! is_system_dll "$PATH_OR_STATUS"; then
                        FILES_TO_CHECK+=("$PATH_OR_STATUS")
                    else
                        VISITED["$PATH_OR_STATUS"]=1 
                    fi
                fi
            fi
        fi
    done < <(ldd "$CURRENT_FILE" 2>/dev/null | grep "=>")
done

echo -e "\n   ✅ Tree scan complete."

# ------------------------------------------------------------------------------
# PHASE 2: Parallel Version Extraction
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}Phase 2: Extracting versions in parallel...${NC}"

# 1. Prepare Job List (Format: Name|Path)
> .joblist.txt
for key in "${!ALL_DEPS[@]}"; do
    echo "$key|${ALL_DEPS[$key]}" >> .joblist.txt
done

TOTAL_JOBS=$(wc -l < .joblist.txt)
echo "   Processing $TOTAL_JOBS files using $THREADS threads..."

# 2. Execute in Parallel using xargs
# -P: Number of threads
# -n 1: Pass 1 line at a time
# -I {}: Placeholder
# bash -c: Runs the exported function
cat .joblist.txt | xargs -P "$THREADS" -I {} bash -c 'get_version_worker "{}"' > .results.txt

# Clean up temp file
rm .joblist.txt

# ------------------------------------------------------------------------------
# FINAL REPORT
# ------------------------------------------------------------------------------
ELAPSED=$(date -u -d @${SECONDS} +"%T")

echo ""
echo "============================================================"
echo -e "✅ FOUND DEPENDENCIES (Total: $TOTAL_JOBS)"
echo -e "   Total Time: $ELAPSED"
echo "============================================================"

# Sort and group results
if [ -f .results.txt ]; then
    # Separate system and application DLLs
    > .system_dlls.txt
    > app_dll_versions.txt
    > app_dependencies.txt
    
    while IFS= read -r line; do
        # Extract path from line (between -> and [)
        path=$(echo "$line" | sed 's/.*-> \(.*\) \[.*/\1/')
        unix_path=$(cygpath -u "$path" 2>/dev/null)
        
        if echo "$unix_path" | grep -qiE "^/c/windows|^/c/winnt"; then
            echo "$line" >> .system_dlls.txt
        else
            echo "$line" >> app_dll_versions.txt
            echo "$path" >> app_dependencies.txt
        fi
    done < .results.txt
    
    echo -e "\n${BLUE}Windows System DLLs:${NC}"
    if [ -s .system_dlls.txt ]; then
        sort .system_dlls.txt
    else
        echo "None found."
    fi
    
    echo -e "\n${BLUE}Application Specific DLLs (app_dependencies.txt):${NC}"
    if [ -s app_dll_versions.txt ]; then
        sort app_dll_versions.txt
    else
        echo "None found."
    fi
    
    # Clean up temp files
    rm .results.txt .system_dlls.txt
else
    echo "No dependencies found."
fi

echo ""
echo "============================================================"
echo -e "❌ MISSING DEPENDENCIES (Total: ${#MISSING_DEPS[@]})"
echo "============================================================"

if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
    echo -e "${GREEN}No missing dependencies found! 🎉${NC}"
else
    for key in "${!MISSING_DEPS[@]}"; do
        REF_UNIX="${MISSING_DEPS[$key]}"
        REF_WIN=$(cygpath -w "$REF_UNIX")
        #echo -e "${RED}MISSING: $key${NC} (Referenced by $REF_WIN)"
        printf "${RED}MISSING: %s${NC} (Referenced by %s)\n" "$key" "$REF_WIN"
    done | sort
fi
echo "============================================================"