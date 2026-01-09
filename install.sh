#!/usr/bin/env bash
set -e

echo "Installing star-runner…"

# Remove old install
sudo rm -f /usr/local/bin/star-runner
sudo rm -rf /usr/local/share/star-runner

# Create install dir
sudo mkdir -p /usr/local/share/star-runner

# Copy all files from current dir (where game.sh and install.sh are)
sudo cp -r ./* /usr/local/share/star-runner/

# Create launcher
sudo tee /usr/local/bin/star-runner > /dev/null << 'EOF'
#!/usr/bin/env bash
exec /usr/local/share/star-runner/game.sh "$@"
EOF

sudo chmod +x /usr/local/bin/star-runner

echo "✔ star-runner installed!"
echo "You can now run the game with: star-runner"
