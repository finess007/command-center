#!/bin/bash
# Build script for Command Center
# Encrypts all source files from src/ to root

PASSWORD="W5l3bA1MFOYkEn0X"

echo "🔐 Building Command Center..."

# Encrypt each HTML file from src to root
for src_file in $(find src -name "*.html" -type f); do
    # Get relative path from src/
    rel_path="${src_file#src/}"
    dest_dir=$(dirname "$rel_path")
    
    # Create destination directory if needed
    if [ "$dest_dir" != "." ]; then
        mkdir -p "$dest_dir"
    fi
    
    echo "  Encrypting: $rel_path"
    staticrypt "$src_file" -p "$PASSWORD" -d "${dest_dir:-.}" --remember 30 -f "$rel_path"
done

echo ""
echo "✅ Build complete! Files encrypted:"
find . -maxdepth 1 -name "*.html" -type f ! -name "*.original.html"
find . -mindepth 2 -name "*.html" -type f ! -path "./src/*" ! -path "./encrypted/*" ! -name "*.original.html"

echo ""
echo "📝 To deploy: git add -A && git commit -m 'Update' && git push"
