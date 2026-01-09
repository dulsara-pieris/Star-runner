#!/usr/bin/env bash
set -e

echo "Installing star-runner…"

# Remove old launcher
if [ -f /usr/local/bin/star-runner ]; then
    sudo rm -f /usr/local/bin/star-runner
    echo "✔ Removed old launcher"
fi

# Remove old installation directory
if [ -d /usr/local/share/star-runner ]; then
    sudo rm -rf /usr/local/share/star-runner
    echo "✔ Removed old installation files"
fi

# Create fresh install directory
sudo mkdir -p /usr/local/share/star-runner

# Copy game files from src/ to install directory
sudo cp -r src/* /usr/local/share/star-runner/

# Copy installer/uninstaller
sudo cp install.sh uninstall.sh /usr/local/share/star-runner/ || true

# Create clean launcher
sudo tee /usr/local/bin/star-runner > /dev/null << 'EOF'
#!/usr/bin/env bash
exec /usr/local/share/star-runner/game.sh "$@"
EOF


# Make launcher executable
sudo chmod +x /usr/local/bin/star-runner

echo "✔ star-runner installed!"
echo "You can now run the game with: star-runner"
