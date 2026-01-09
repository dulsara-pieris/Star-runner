#!/usr/bin/env bash
set -e

echo "Installing star-runner…"

# Remove old launcher
sudo rm -f /usr/local/bin/star-runner

# Install directory
sudo mkdir -p /usr/local/share/star-runner

# Copy game files
sudo cp -r src/* /usr/local/share/star-runner/

# Copy installer/uninstaller (optional)
sudo cp install.sh uninstall.sh /usr/local/share/star-runner/ || true

# Create launcher
sudo tee /usr/local/bin/star-runner > /dev/null << 'EOF'
#!/usr/bin/env bash
exec /usr/local/share/star-runner/game.sh "$@"
EOF

sudo chmod +x /usr/local/bin/star-runner

echo "✔ star-runner installed!"
echo "You can now run the game with: star-runner"
