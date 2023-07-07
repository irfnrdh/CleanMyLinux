#!/bin/bash

# Update the system
sudo pacman -Syu

# Remove unused packages
sudo pacman -Rns $(pacman -Qdtq)

# Clear the package cache
sudo pacman -Sc

# Clean the system cache
sudo paccache -r

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq)

# Clean temporary files using bleachbit
sudo pacman -S --noconfirm bleachbit
sudo bleachbit --clean system.*

# Remove old log files
sudo find /var/log -type f -name "*.log" -delete

# Clean pacman package cache
sudo paccache -r

# Clean cache in /home
rm -rf ~/.cache/*

# Remove old configuration files
find ~ -type f -name "*.pacnew" -delete
find ~ -type f -name "*.pacsave" -delete

# Find and remove duplicate and empty files, empty directories, and broken symlinks
sudo find ~ -type f -size 0 -delete
sudo find ~ -type d -empty -delete
sudo find ~ -type l ! -exec test -e {} \; -delete

# Find the files taking up the most disk space
du -ha ~ | sort -rh | head -n 10

# Disk cleaning programs (optional, uncomment the lines below if desired)
# sudo pacman -S --noconfirm ncdu  # Install ncdu disk usage analyzer
# ncdu ~  # Run ncdu to analyze disk usage interactively

# Display completion message
echo "Maintenance completed."
