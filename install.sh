#!/usr/bin/env bash
set -e

# Detect the folder where install.sh is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INSTALL_DIR="/usr/local/share/star-runner"

echo "Installing star-runner…"

# Create install directory
sudo mkdir -p "$INSTALL_DIR"

# Copy game.sh from this folder to the install directory
sudo cp "$DIR/game.sh" "$INSTALL_DIR/"

# Create launcher wrapper in /usr/local/bin
sudo tee /usr/local/bin/star-runner > /dev/null << 'EOF'
#!/usr/bin/env bash
exec /usr/local/share/star-runner/game.sh "$@"
EOF

# Make the launcher executable
sudo chmod +x /usr/local/bin/star-runner

echo "✔ Installed to $INSTALL_DIR"
echo "✔ Launcher created at /usr/local/bin/star-runner"
echo
echo "You can now run the game with:"
echo "  star-runner"
