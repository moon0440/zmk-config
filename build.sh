#!/usr/bin/env bash
set -euo pipefail

# 🚨 Check required tools
check_command() {
    if ! command -v "$1" &> /dev/null; then
        # TODO: Refactor to attempt pipx install for west and yq
        echo "❌ Required command '$1' not found. Please install it first." >&2
        exit 1
    fi
}

echo "🔍 Checking environment..."
check_command west
check_command yq
check_command find

# 📁 Setup build and artifacts directories
echo "🧹 Cleaning previous builds..."
rm -rf build artifacts
mkdir -p artifacts

# 📦 Define build targets (from your build.yaml)
declare -a builds=("left" "right" "dongle" "reset-left" "reset-right" "reset-dongle")

# 🔁 Build each target
for name in "${builds[@]}"; do
    echo -e "\n🔨 Building: $name"

    board=$(yq e ".builds[] | select(.name == \"$name\") | .board" build.yaml)
    shield=$(yq e ".builds[] | select(.name == \"$name\") | .shield" build.yaml)
    cmake_args=$(yq e ".builds[] | select(.name == \"$name\") | .cmake-args // \"\"" build.yaml)

    if [[ "$board" == "null" || "$shield" == "null" ]]; then
        echo "⚠️  Skipping $name: board or shield not defined in build.yaml"
        continue
    fi

    echo "📋 Board: $board"
    echo "🛡️  Shield: $shield"

    # Run the build
    if ! west build -s zmk/app -d build/$name -b "$board" \
        -- -DSHIELD="$shield" $cmake_args; then
        echo "❌ Build failed for $name"
        continue
    fi

    # Find and copy the .uf2 output
    uf2_file=$(find build/$name -name "*.uf2" -print -quit)
    if [[ -f "$uf2_file" ]]; then
        cp "$uf2_file" artifacts/$name.uf2
        echo "✅ $name build complete: artifacts/$name.uf2"
    else
        echo "⚠️  No UF2 file found for $name"
    fi
done

echo -e "\n🏁 All builds finished. Check the artifacts/ directory for output UF2 files."
