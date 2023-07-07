# Dont run this script if you don't understand the script!

#!/bin/bash

# Function to display disk space usage before and after
display_disk_usage() {
    echo ">>> Disk Space Usage (Before):"
    df -h /

    # Run the maintenance tasks
    run_maintenance_tasks

    echo ">>> Disk Space Usage (After):"
    df -h /
}

# Function to run the maintenance tasks
run_maintenance_tasks() {
    # Update the system
    echo ">>> Updating the system..."
    sudo pacman -Syu

    # Clean all log files
    echo ">>> Cleaning all log files..."
    sudo find /var/log -type f -exec truncate --size 0 {} \;

    # Clean systemd journal logs
    echo ">>> Cleaning systemd journal logs..."
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s

    # Remove unused packages
    echo ">>> Removing unused packages..."
    sudo pacman -Rns $(pacman -Qdtq)

    # Clear the package cache
    echo ">>> Clearing the package cache..."
    sudo pacman -Sc

    # Clean the system cache (pacman package cache)
    echo ">>> Cleaning the system cache..."
    sudo paccache -r

    # Remove any automatic dependencies that are no longer needed
    echo ">>> Removing automatic dependencies that are no longer needed..."
    sudo paccache -ruk0

    # Free up space by cleaning out the cached packages
    echo ">>> Freeing up space by cleaning out the cached packages..."
    sudo pacman -Scc --noconfirm

    # Clean the thumbnail cache
    echo ">>> Cleaning the thumbnail cache..."
    rm -rf ~/.cache/thumbnails/*

    # Getting rid of no longer required packages
    echo ">>> Getting rid of no longer required packages..."
    sudo pacman -Qtdq | sudo pacman -Rns - --noconfirm

    # Remove orphaned packages
    echo ">>> Removing orphaned packages..."
    sudo pacman -Rns $(pacman -Qdtq) --noconfirm

    # Clean temporary files using bleachbit
    echo ">>> Cleaning temporary files using bleachbit..."
    sudo pacman -S --noconfirm bleachbit
    sudo bleachbit --clean system.*

    # Remove old log files
    echo ">>> Removing old log files..."
    sudo find /var/log -type f -name "*.log" -delete

    # Clean cache in /home
    echo ">>> Cleaning cache in /home..."
    rm -rf ~/.cache/*

    # Remove old revisions of snaps (leaves only 2 versions)
    echo ">>> Removing old revisions of snaps..."
    sudo snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done

    # Remove man pages
    echo ">>> Removing man pages..."
    sudo rm -rf /usr/share/man/*

    # Remove the Trash
    echo ">>> Removing the Trash..."
    rm -rf ~/.local/share/Trash/*

    # Delete all .gz and rotated files
    echo ">>> Deleting all .gz and rotated files..."
    sudo find / -type f \( -name "*.gz" -o -name "*.log.*" \) -delete

    # Remove old configuration files
    echo ">>> Removing old configuration files..."
    find ~ -type f -name "*.pacnew" -delete
    find ~ -type f -name "*.pacsave" -delete

    # Find and remove duplicate and empty files, empty directories, and broken symlinks
    echo ">>> Finding and removing duplicate and empty files, empty directories, and broken symlinks..."
    sudo find ~ -type f -size 0 -delete
    sudo find ~ -type d -empty -delete
    sudo find ~ -type l ! -exec test -e {} \; -delete

    # Find the files taking up the most disk space
    echo ">>> Finding the files taking up the most disk space..."
    du -ha ~ | sort -rh | head -n 10

    # Disk cleaning programs (optional, uncomment the lines below if desired)
    # echo ">>> Installing ncdu disk usage analyzer..."
    # sudo pacman -S --noconfirm ncdu
    # echo ">>> Running ncdu to analyze disk usage interactively..."
    # ncdu ~
}

# Prompt for confirmation
read -p "This script will perform system maintenance tasks. Do you want to continue? (y/n): " choice
if [[ $choice == "y" || $choice == "Y" ]]; then
    display_disk_usage
    echo ">>> Maintenance completed."
else
    echo ">>> Maintenance canceled."
fi
