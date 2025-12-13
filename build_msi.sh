#!/bin/bash
# Script to build msi installer for zenity

current_dir=$(dirname "$(realpath "$0")" )

# Configuration variables
PROJECT_NAME="ZenityMs"
SOURCE_DIR="dist/ZenityMs"  # Relative path to your files
WIXPROJ_FILE="${PROJECT_NAME}.wixproj"
DOTNET_CMD="C:/Program Files/dotnet/dotnet.exe"

# Install msi build dependencies
echo dependencies can be installed with: 
echo winget install Microsoft.DotNet.SDK.8
# 1. Check if dotnet is installed
if ! command -v "$DOTNET_CMD" &> /dev/null; then
    echo "Error: '$DOTNET_CMD' command not found. Please install the .NET SDK."
    exit 1
fi

# Check source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Directory '$SOURCE_DIR' not found."
    exit 1
fi

echo "--- Generating WiX v5 Project File ---"

cat > "$WIXPROJ_FILE" <<EOF
<Project Sdk="WixToolset.Sdk/5.0.0">
  <PropertyGroup>
    <OutputName>${PROJECT_NAME}</OutputName>
    <OutputType>Package</OutputType>
    <InstallerPlatform>x64</InstallerPlatform>
    <SuppressValidation>true</SuppressValidation>
  </PropertyGroup>

  <ItemGroup>
    <HarvestDirectory Include="${SOURCE_DIR}">
      <ComponentGroupName>PublishedComponents</ComponentGroupName>
      <DirectoryRefId>INSTALLFOLDER</DirectoryRefId>
      <SuppressRootDirectory>true</SuppressRootDirectory>
    </HarvestDirectory>
    <BindPath Include="${SOURCE_DIR}" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="WixToolset.Heat" Version="5.0.0" />
    <PackageReference Include="WixToolset.UI.wixext" Version="5.0.0" />
  </ItemGroup>
</Project>
EOF

echo "--- Building MSI with Dotnet ---"
# Restore ensures the UI package is downloaded
"$DOTNET_CMD" restore "$WIXPROJ_FILE"
# This command downloads the WiX SDK and Heat extension, compiles, and links all Included ("**/*.wxs") files into an MSI.
"$DOTNET_CMD" build "$WIXPROJ_FILE" -c Release

if [ $? -eq 0 ]; then
    echo "--- Build Success! ---"
    # Move the artifact from the messy bin folder to the root
    mv "bin/Release/${PROJECT_NAME}.msi" ./dist/
    echo "Installer available at: $(pwd)/dist/${PROJECT_NAME}.msi"
    
    # Cleanup (Optional)
    rm "$WIXPROJ_FILE"
    rm -rf bin obj
else
    echo "Error: Build failed."
    exit 1
fi

echo "MSI Build script completed."