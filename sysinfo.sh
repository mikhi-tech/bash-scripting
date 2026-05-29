#!/bin/bash

# --- HELP FLAG HANDLING ---
# Check if the script was called with -h or --help argument
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "========================================================="
    echo "                 System Info Script Help                 "
    echo "========================================================="
    echo "Usage: ./sysinfo.sh"
    echo ""
    echo "This is an interactive Bash script that provides a local"
    echo "system dashboard. It allows you to monitor:"
    echo "  1) OS version, hostname, kernel, and uptime."
    echo "  2) Human-readable disk usage statistics."
    echo "  3) Currently active users and their active processes."
    echo "  4) Top 5 CPU-intensive processes formatted in a clean table."
    echo "========================================================="
    exit 0
fi

# --- HELPER FUNCTIONS FOR FORMATTING ---
print_header() {
    echo ""
    echo "========================================================="
    echo "  $1"
    echo "  Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================================="
}

print_divider() {
    echo "---------------------------------------------------------"
}

# --- MAIN MENU LOOP ---
while true; do
    echo ""
    echo "Welcome, select one of the following options using the number keys:"
    print_divider
    echo "1: Show System Info"
    echo "2: Show Disk Usage"
    echo "3: Show Current Users"
    echo "4: Show Top Processes"
    echo "5: Exit"
    print_divider
    
    # Capture user input
    read -p "Enter choice [1-5]: " choice
    
    case $choice in
        1)
            print_header "SYSTEM INFORMATION"
            # Get OS Name/Version safely
            if [ -f /etc/os-release ]; then
                grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"'
            else
                uname -s
            fi
            
            echo "Hostname:   $(hostname)"
            echo "Kernel:     $(uname -r)"
            echo "Uptime:    $(uptime -p 2>/dev/null || uptime)"
            ;;
            
        2)
            print_header "DISK USAGE"
            # -h makes it human-readable (Gigs, Megs)
            df -h
            ;;
            
        3)
            print_header "CURRENT LOGGED-IN USERS & APPS"
            # 'w' shows who is logged on and what they are doing
            w
            ;;
            
        4)
            print_header "TOP 5 CPU-INTENSIVE PROCESSES"
            # Print the custom ASCII table structure requested
            echo "+------+-------+--------+-------------+"
            echo "| PID  | User  | CPU%   | Command     |"
            echo "+------+-------+--------+-------------+"
            
            # ps aux sorts by %cpu, takes the top 5 (excluding header), and formats nicely
            ps aux --sort=-%cpu | awk 'NR>1 {print $2, $1, $3, $11}' | head -n 5 | while read -r pid user cpu cmd; do
                # Strip directory path from command name for cleaner table layout
                cmd_basename=$(basename "$cmd")
                printf "| %-4s | %-5s | %-6s | %-11s |\n" "$pid" "$user" "$cpu%" "$cmd_basename"
            done
            echo "+------+-------+--------+-------------+"
            ;;
            
        5)
            echo "Exiting system monitor. Goodbye!"
            exit 0
            ;;
            
        *)
            echo "Error: Invalid option. Please select a number between 1 and 5."
            ;;
    esac
    
    # Pauses the script loop until the user hits enter so they can actually read the data
    echo ""
    read -p "Press [Enter] to return to the menu..." temp_clear
done