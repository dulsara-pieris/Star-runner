#!/usr/bin/env bash
  printf "$COLOR_CYAN"
  cat << "EOF"

    ███████╗████████╗ █████╗ ██████╗     ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
    ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
    ███████╗   ██║   ███████║██████╔╝    ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
    ╚════██║   ██║   ██╔══██║██╔══██╗    ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
    ███████║   ██║   ██║  ██║██║  ██║    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
    ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
                                                                                                
EOF
set -e
pwd=pwd
echo "Installing star-runner…"

# Remove old install
sudo rm -f /usr/local/bin/Star-runner
sudo rm -rf /usr/local/share/Star-runner

# Create install dir
sudo mkdir -p /usr/local/share/Star-runner
cd /usr/local/share/
git clone https://github.com/dulsara-pieris/Star-runner
cd Star-runner

# Create launcher
sudo tee /usr/local/bin/Star-runner > /dev/null << 'EOF'
#!/usr/bin/env bash
exec /usr/local/share/Star-runner/src/game.sh "$@"
EOF

sudo chmod +x /usr/local/bin/Star-runner

echo "✔ star-runner installed!"
echo "You can now run the game with: star-runner"
cd $pwd