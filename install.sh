#!/usr/bin/env bash
set -e

# Installation directories

echo "Installing star-runner…"

# Remove old launcher if exists
if [ -f "/usr/local/bin/star-runner" ]; then
    sudo rm -f "/usr/local/bin/star-runner"
fi

# Create the install directory
sudo mkdir -p "/usr/local/share/star-runner"

# Copy all necessary files (game.sh + any other future files in src)
sudo cp -r src/* "/usr/local/share/star-runner/"

# Copy installer and uninstaller to the install directory
sudo cp install.sh uninstall.sh "/usr/local/share/star-runner/" || true

# Create launcher
sudo tee "/usr/local/bin/star-runner" > /dev/null << 'EOF'
#!/usr/bin/env bash
exec /usr/local/share/star-runner/game.sh "$@"
EOF

sudo chmod +x "/usr/local/bin/star-runner"

echo "✔ star-runner installed!"
echo "You can now run the game simply with: star-runner"
