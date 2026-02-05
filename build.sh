#!/bin/bash
# Build script for Command Center
# Encrypts HTML files and copies JSON data files from src/ to root

PASSWORD="W5l3bA1MFOYkEn0X"

echo "🔐 Building Command Center..."

# 1. Encrypt each HTML file from src to root
for src_file in $(find src -name "*.html" -type f); do
    rel_path="${src_file#src/}"
    dest_dir=$(dirname "$rel_path")
    
    if [ "$dest_dir" != "." ]; then
        mkdir -p "$dest_dir"
    fi
    
    echo "  Encrypting: $rel_path"
    staticrypt "$src_file" -p "$PASSWORD" -d "${dest_dir:-.}" --remember 30 -f "$rel_path"
done

# 2. Copy all JSON files from src to root (preserving directory structure)
echo ""
echo "📦 Syncing JSON data files..."
for json_file in $(find src -name "*.json" -type f); do
    rel_path="${json_file#src/}"
    dest_dir=$(dirname "$rel_path")
    
    if [ "$dest_dir" != "." ]; then
        mkdir -p "$dest_dir"
    fi
    
    echo "  Copying: $rel_path"
    cp "$json_file" "$rel_path"
done

echo ""
echo "✅ Build complete!"
echo ""
echo "📄 HTML files encrypted:"
find . -maxdepth 1 -name "*.html" -type f ! -name "*.original.html"
find . -mindepth 2 -name "*.html" -type f ! -path "./src/*" ! -path "./encrypted/*" ! -name "*.original.html"

echo ""
echo "📊 JSON files synced:"
find . -mindepth 2 -name "*.json" -type f ! -path "./src/*" ! -path "./.vercel/*" ! -path "./node_modules/*"

echo ""
echo "📝 To deploy: git add -A && git commit -m 'Update' && git push"
