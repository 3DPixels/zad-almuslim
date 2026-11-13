#!/bin/bash

# 1. Error Handling Setup
# 'set -e' stops the script immediately on any error.
# 'trap' catches the error and prints exactly which line and command failed.
set -e
trap 'echo -e "\n❌ Error: Script failed at line $LINENO while executing command: $BASH_COMMAND"; exit 1' ERR

# 2. Extract and Parse the Current Version
CURRENT_VERSION=$(grep '^version: ' pubspec.yaml | sed -E 's/version: (.*)/\1/')
echo -e "Current full version: \033[1;36m$CURRENT_VERSION\033[0m"

# Extract the base version (x.y.z)
if [[ "$CURRENT_VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    OLD_BASE="${BASH_REMATCH[1]}"
else
    OLD_BASE="$CURRENT_VERSION"
fi

# Extract the build number (the number after +)
if [[ "$CURRENT_VERSION" =~ \+([0-9]+)$ ]]; then
    OLD_BUILD="${BASH_REMATCH[1]}"
else
    OLD_BUILD=0
fi

# 3. Input with Pre-fill
read -e -i "$OLD_BASE" -p "Enter the base version (Major.Minor.Patch): " NEW_BASE

# 4. Input Validation
if ! [[ "$NEW_BASE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Error: Invalid format. Use only numbers and dots (e.g., 1.2.2)."
    exit 1
fi

IS_VALID=$(awk -v v1="$NEW_BASE" -v v2="$OLD_BASE" 'BEGIN {
    split(v1, a, "."); split(v2, b, ".");
    for (i=1; i<=3; i++) {
        if (a[i] < b[i]) { print 0; exit; }
        if (a[i] > b[i]) { print 1; exit; }
    }
    print 1; # Equal is valid
}')

if [ "$IS_VALID" -eq 0 ]; then
    echo "❌ Error: You cannot decrease the base version below $OLD_BASE."
    exit 1
fi

# 5. Google Play Compliant Versioning
if [[ "$NEW_BASE" == "$OLD_BASE" ]]; then
    NEW_BUILD=$(( OLD_BUILD + 1 ))
else
    NEW_BUILD=1
fi

FINAL_VERSION="${NEW_BASE}+${NEW_BUILD}"

echo -e "\nTarget Version: \033[1;32m$FINAL_VERSION\033[0m\n"

# 6. Execute Build
sed -i "s/^version: $CURRENT_VERSION/version: $FINAL_VERSION/" pubspec.yaml
echo "✅ pubspec.yaml updated."

echo "⏳ Building Flutter AppBundle..."
flutter build appbundle

echo -e "\n🎉 Build complete! Target $FINAL_VERSION is ready."