#!/usr/bin/env bash
set -e

cat << "EOF"

    ███████╗████████╗ █████╗ ██████╗     ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
    ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
    ███████╗   ██║   ███████║██████╔╝    ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
    ╚════██║   ██║   ██╔══██║██╔══██╗    ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
    ███████║   ██║   ██║  ██║██║  ██║    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
    ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
                                                                                                
EOF
echo "Installing star-runner…"

# Remove old install
sudo rm -f /usr/local/bin/Star-runner
sudo rm -f /usr/local/bin/star-runner
sudo rm -rf /usr/local/share/Star-runner

# Clone game files
cd /usr/local/share/
sudo git clone --depth 1 https://github.com/dulsara-pieris/Star-runner

# Create launcher
sudo tee /usr/local/bin/star-runner > /dev/null << 'EOF'
#!/usr/bin/env bash
exec bash /usr/local/share/Star-runner/src/game.sh "$@"
EOF

sudo chmod +x /usr/local/share/Star-runner/src/game.sh
sudo chmod +x /usr/local/bin/star-runner
sudo chmod -R +x /usr/local/share/Star-runner/src

# Make sure files exist
touch ~/.star_runner_profile ~/.star_runner_checksum

# Give yourself ownership
chown $USER:$USER ~/.star_runner_profile ~/.star_runner_checksum

# Set read/write permissions for your user only
chmod 600 ~/.star_runner_profile ~/.star_runner_checksum

echo "✔ star-runner installed!"
echo "You can now run the game with: star-runner"
