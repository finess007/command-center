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

# 3. Mirror everything to public/ (Vercel deploys from public/ when it exists)
echo ""
echo "📦 Mirroring to public/..."
# Copy encrypted HTML files
for f in $(find . -maxdepth 1 -name "*.html" -type f ! -name "*.original.html"); do
    cp "$f" "public/$(basename $f)"
done
# Copy subdirectory HTML files
for d in english habits data; do
    if [ -d "$d" ] && ls "$d"/*.html 1>/dev/null 2>&1; then
        mkdir -p "public/$d"
        cp "$d"/*.html "public/$d/"
    fi
done
# Copy JSON files to public
for f in $(find . -maxdepth 1 -name "*.json" -type f ! -name "package*.json"); do
    cp "$f" "public/$(basename $f)" 2>/dev/null
done
for d in english data; do
    if [ -d "$d" ] && ls "$d"/*.json 1>/dev/null 2>&1; then
        mkdir -p "public/$d"
        cp "$d"/*.json "public/$d/"
    fi
done
# Copy .vercel output too
mkdir -p .vercel/output/static
cp -R public/* .vercel/output/static/ 2>/dev/null

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
