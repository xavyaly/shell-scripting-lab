'''FILE-BACKUP'''

Here are some sample shell scripts for automating file backups:

1. Simple Backup Script
This script backs up files from a source directory to a destination directory with a timestamp.

```bash
#!/bin/bash

# Variables
SOURCE_DIR="/path/to/source"      # The directory you want to back up
DEST_DIR="/path/to/backup"        # The directory where backups will be stored
DATE=$(date +'%Y-%m-%d_%H-%M-%S') # Timestamp for backup folder

# Create a new backup directory with the current timestamp
BACKUP_DIR="$DEST_DIR/backup_$DATE"
mkdir -p "$BACKUP_DIR"

# Copy files to the backup directory
cp -r "$SOURCE_DIR"/* "$BACKUP_DIR"

echo "Backup completed successfully at $BACKUP_DIR"
```

2. Backup with Compression
This script compresses the backup into a `.tar.gz` archive for efficient storage.

```bash
#!/bin/bash

# Variables
SOURCE_DIR="/path/to/source"
DEST_DIR="/path/to/backup"
DATE=$(date +'%Y-%m-%d_%H-%M-%S')

# Create a compressed tar file
tar -czf "$DEST_DIR/backup_$DATE.tar.gz" -C "$SOURCE_DIR" .

echo "Backup with compression completed: $DEST_DIR/backup_$DATE.tar.gz"
```

3. Incremental Backup Using `rsync`
Incremental backups only copy new or modified files. This is ideal for large directories with minimal changes.

```bash
#!/bin/bash

# Variables
SOURCE_DIR="/path/to/source"
DEST_DIR="/path/to/backup"
DATE=$(date +'%Y-%m-%d')

# Use rsync for incremental backup
rsync -av --delete "$SOURCE_DIR"/ "$DEST_DIR"/"$DATE"

echo "Incremental backup completed successfully to $DEST_DIR/$DATE"
```

4. Rotating Backups (Daily/Weekly/Monthly)
This script keeps a daily, weekly, and monthly backup, rotating them to avoid using too much storage.

```bash
#!/bin/bash

# Variables
SOURCE_DIR="/path/to/source"
DEST_DIR="/path/to/backup"
DATE=$(date +'%Y-%m-%d')

# Daily backup
DAILY_BACKUP="$DEST_DIR/daily"
mkdir -p "$DAILY_BACKUP"
rsync -av --delete "$SOURCE_DIR"/ "$DAILY_BACKUP"/"$DATE"

# Weekly backup - Keep Sunday's backup
if [ "$(date +%u)" -eq 7 ]; then
    WEEKLY_BACKUP="$DEST_DIR/weekly"
    mkdir -p "$WEEKLY_BACKUP"
    cp -r "$DAILY_BACKUP/$DATE" "$WEEKLY_BACKUP/$DATE"
fi

# Monthly backup - Keep the first backup of each month
if [ "$(date +%d)" -eq 01 ]; then
    MONTHLY_BACKUP="$DEST_DIR/monthly"
    mkdir -p "$MONTHLY_BACKUP"
    cp -r "$DAILY_BACKUP/$DATE" "$MONTHLY_BACKUP/$DATE"
fi

echo "Rotating backups completed."
```

5. Full and Differential Backup
This script runs a full backup once a week and differential backups on other days.

```bash
#!/bin/bash

# Variables
SOURCE_DIR="/path/to/source"
DEST_DIR="/path/to/backup"
DATE=$(date +'%Y-%m-%d')

# Check if today is Sunday (full backup day)
if [ "$(date +%u)" -eq 7 ]; then
    BACKUP_TYPE="full"
else
    BACKUP_TYPE="diff"
fi

# Full backup
if [ "$BACKUP_TYPE" == "full" ]; then
    tar -czf "$DEST_DIR/full_$DATE.tar.gz" -C "$SOURCE_DIR" .
    echo "Full backup completed: $DEST_DIR/full_$DATE.tar.gz"
else
    # Differential backup based on the last full backup
    tar -czf "$DEST_DIR/diff_$DATE.tar.gz" --newer-mtime="$(find $DEST_DIR -name 'full_*.tar.gz' | sort | tail -n 1)" -C "$SOURCE_DIR" .
    echo "Differential backup completed: $DEST_DIR/diff_$DATE.tar.gz"
fi
```

Setting Up a Cron Job for Automation
To automate any of these scripts, add them to your crontab:

1. Open the crontab editor:
   ```bash
   crontab -e
   ```
2. Add an entry to run the script daily, weekly, or monthly:
   ```bash
   # Daily at midnight
   0 0 * * * /path/to/your/backup_script.sh
   ```

These scripts offer a range of options depending on your backup needs, from simple full backups to more sophisticated differential and rotating backups.

----------------------------------------------------------------------------------------------------------------

'''LOG-ANALYSER'''

Here is a basic shell script to analyze log files, summarizing metrics like error counts, status codes, and IP addresses. It can work with common log formats like those from Apache or Nginx.

Log Analyzer Script

This script offers options to:
- Count the number of requests.
- Display unique IP addresses.
- List and count error codes (e.g., HTTP 4xx and 5xx).
- Show the top 10 IP addresses by request count.

```bash
#!/bin/bash

# Path to the log file
LOG_FILE="/path/to/your/logfile.log"

# Function to display menu
display_menu() {
    echo "Log Analyzer Script"
    echo "1. Count Total Requests"
    echo "2. List Unique IP Addresses"
    echo "3. Show Count of HTTP Status Codes"
    echo "4. Top 10 IPs by Number of Requests"
    echo "5. Show Count of 4xx and 5xx Errors"
    echo "6. Exit"
}

# Function to count total requests
count_requests() {
    local COUNT=$(wc -l < "$LOG_FILE")
    echo "Total number of requests: $COUNT"
}

# Function to list unique IP addresses
list_unique_ips() {
    echo "Unique IP addresses:"
    awk '{print $1}' "$LOG_FILE" | sort | uniq
}

# Function to show count of HTTP status codes
count_status_codes() {
    echo "HTTP Status Codes Count:"
    awk '{print $9}' "$LOG_FILE" | grep -E '^[0-9]{3}$' | sort | uniq -c | sort -nr
}

# Function to show top 10 IPs by request count
top_10_ips() {
    echo "Top 10 IP addresses by number of requests:"
    awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10
}

# Function to show count of 4xx and 5xx errors
count_errors() {
    echo "Count of 4xx and 5xx Errors:"
    awk '{print $9}' "$LOG_FILE" | grep -E '^[45][0-9]{2}$' | sort | uniq -c | sort -nr
}

# Main program loop
while true; do
    display_menu
    read -p "Choose an option [1-6]: " OPTION

    case $OPTION in
        1)
            count_requests
            ;;
        2)
            list_unique_ips
            ;;
        3)
            count_status_codes
            ;;
        4)
            top_10_ips
            ;;
        5)
            count_errors
            ;;
        6)
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid option. Please select between 1 and 6."
            ;;
    esac
    echo ""
done
```

Explanation of the Script

1. `count_requests`: Counts the total lines in the log file, which typically represents the total requests.

2. `list_unique_ips`: Extracts unique IP addresses from the first column (standard position for IPs in access logs).

3. `count_status_codes`: Extracts the HTTP status codes from the log file and counts occurrences for each code. It expects the status code in the 9th field, which is typical for Apache/Nginx logs.

4. `top_10_ips`: Displays the top 10 IPs by request count, helping identify the most active clients.

5. `count_errors`: Counts occurrences of HTTP error codes (4xx and 5xx), useful for detecting client and server errors.

Running the Script

1. Save the script to a file (e.g., `log_analyzer.sh`).
2. Make it executable:

   ```bash
   chmod +x log_analyzer.sh
   ```

3. Run the script:

   ```bash
   ./log_analyzer.sh
   ```

This script is a helpful starting point for quickly analyzing common log patterns and extracting useful metrics. You can further customize it based on your specific log format and analysis needs.

----------------------------------------------------------------------------------------------------------------

'''SYSTEM-MONITORING'''

Here are some shell scripts to monitor key system parameters like CPU, memory, disk usage, network traffic, and running processes.

1. CPU Usage Monitoring
This script monitors CPU usage and logs it if it exceeds a specified threshold.

```bash
#!/bin/bash

THRESHOLD=80  # CPU usage threshold percentage

# Get CPU usage for the last 1 minute
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

echo "Current CPU usage is: $CPU_USAGE%"

if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )); then
    echo "High CPU usage detected: $CPU_USAGE%" | tee -a /var/log/cpu_monitor.log
fi
```

2. Memory Usage Monitoring
This script checks the memory usage and logs it if it exceeds a specified threshold.

```bash
#!/bin/bash

THRESHOLD=80  # Memory usage threshold percentage

# Get memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

echo "Current memory usage is: $MEMORY_USAGE%"

if (( $(echo "$MEMORY_USAGE > $THRESHOLD" | bc -l) )); then
    echo "High memory usage detected: $MEMORY_USAGE%" | tee -a /var/log/memory_monitor.log
fi
```

3. Disk Space Monitoring
This script monitors disk space usage on specified mount points and logs an alert if usage exceeds a threshold.

```bash
#!/bin/bash

THRESHOLD=80  # Disk usage threshold percentage
MOUNT_POINT="/"  # Change as needed

# Get disk usage
DISK_USAGE=$(df -h "$MOUNT_POINT" | grep -vE '^Filesystem' | awk '{print $5}' | sed 's/%//g')

echo "Current disk usage at $MOUNT_POINT: $DISK_USAGE%"

if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    echo "High disk usage detected on $MOUNT_POINT: $DISK_USAGE%" | tee -a /var/log/disk_monitor.log
fi
```

4. Network Traffic Monitoring
This script monitors incoming and outgoing network traffic on a specified network interface.

```bash
#!/bin/bash

INTERFACE="eth0"  # Specify your network interface

# Get network traffic data
RX_BYTES_BEFORE=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES_BEFORE=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
sleep 1
RX_BYTES_AFTER=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES_AFTER=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Calculate the difference
RX_RATE=$(( ($RX_BYTES_AFTER - $RX_BYTES_BEFORE) / 1024 ))
TX_RATE=$(( ($TX_BYTES_AFTER - $TX_BYTES_BEFORE) / 1024 ))

echo "Download speed: $RX_RATE KB/s, Upload speed: $TX_RATE KB/s"
```

5. Monitoring Running Processes
This script checks for specific processes and logs if they are not running.

```bash
#!/bin/bash

# Define a list of processes to monitor
PROCESSES=("nginx" "mysqld" "sshd")

for PROCESS in "${PROCESSES[@]}"; do
    if pgrep "$PROCESS" > /dev/null; then
        echo "$PROCESS is running"
    else
        echo "$PROCESS is NOT running" | tee -a /var/log/process_monitor.log
    fi
done
```

6. System Health Check Summary
This script combines CPU, memory, disk, and process checks into a single report.

```bash
#!/bin/bash

# CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
echo "CPU usage: $CPU_USAGE%"

# Memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
echo "Memory usage: $MEMORY_USAGE%"

# Disk usage
DISK_USAGE=$(df -h / | grep -vE '^Filesystem' | awk '{print $5}' | sed 's/%//g')
echo "Disk usage: $DISK_USAGE%"

# Network usage (eth0)
RX_BYTES_BEFORE=$(cat /sys/class/net/eth0/statistics/rx_bytes)
TX_BYTES_BEFORE=$(cat /sys/class/net/eth0/statistics/tx_bytes)
sleep 1
RX_BYTES_AFTER=$(cat /sys/class/net/eth0/statistics/rx_bytes)
TX_BYTES_AFTER=$(cat /sys/class/net/eth0/statistics/tx_bytes)
RX_RATE=$(( ($RX_BYTES_AFTER - $RX_BYTES_BEFORE) / 1024 ))
TX_RATE=$(( ($TX_BYTES_AFTER - $TX_BYTES_BEFORE) / 1024 ))
echo "Network Download: $RX_RATE KB/s, Upload: $TX_RATE KB/s"

# Check for essential processes
PROCESSES=("nginx" "mysqld" "sshd")
for PROCESS in "${PROCESSES[@]}"; do
    if pgrep "$PROCESS" > /dev/null; then
        echo "$PROCESS is running"
    else
        echo "$PROCESS is NOT running"
    fi
done
```

Automate Monitoring with Cron
To run these scripts periodically:

1. Open the crontab editor:
   ```bash
   crontab -e
   ```
2. Add an entry to run the scripts at desired intervals, e.g., every 5 minutes:
   ```bash
   # Run every 5 minutes
   */5 * * * * /path/to/your/system_monitor_script.sh
   ```

These scripts help monitor system health by tracking usage and availability of system resources and key processes.

----------------------------------------------------------------------------------------------------------------

'''USER-ACCOUNT-MANAGEMENT'''

Here a shell script that allows for basic user account management tasks such as adding, deleting, and displaying users. The script includes options for setting up a new user, removing a user, and listing existing users on the system.

User Account Management Script

#!/bin/bash

# Function to display menu
display_menu() {
    echo "User Account Management Script"
    echo "1. Add a New User"
    echo "2. Delete a User"
    echo "3. List All Users"
    echo "4. Lock a User Account"
    echo "5. Unlock a User Account"
    echo "6. Exit"
}

# Function to add a new user
add_user() {
    read -p "Enter the username for the new user: " USERNAME
    read -p "Enter the comment (e.g., full name): " COMMENT
    sudo useradd -m -c "$COMMENT" "$USERNAME"
    if [ $? -eq 0 ]; then
        echo "User $USERNAME added successfully."
    else
        echo "Failed to add user $USERNAME."
    fi
}

# Function to delete a user
delete_user() {
    read -p "Enter the username to delete: " USERNAME
    sudo userdel -r "$USERNAME"
    if [ $? -eq 0 ]; then
        echo "User $USERNAME deleted successfully."
    else
        echo "Failed to delete user $USERNAME."
    fi
}

# Function to list all users
list_users() {
    echo "List of users on the system:"
    cut -d: -f1 /etc/passwd
}

# Function to lock a user account
lock_user() {
    read -p "Enter the username to lock: " USERNAME
    sudo usermod -L "$USERNAME"
    if [ $? -eq 0 ]; then
        echo "User $USERNAME locked successfully."
    else
        echo "Failed to lock user $USERNAME."
    fi
}

# Function to unlock a user account
unlock_user() {
    read -p "Enter the username to unlock: " USERNAME
    sudo usermod -U "$USERNAME"
    if [ $? -eq 0 ]; then
        echo "User $USERNAME unlocked successfully."
    else
        echo "Failed to unlock user $USERNAME."
    fi
}

# Main program loop
while true; do
    display_menu
    read -p "Choose an option [1-6]: " OPTION

    case $OPTION in
        1)
            add_user
            ;;
        2)
            delete_user
            ;;
        3)
            list_users
            ;;
        4)
            lock_user
            ;;
        5)
            unlock_user
            ;;
        6)
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid option. Please select between 1 and 6."
            ;;
    esac
    echo ""
done

'''
Explanation of the Script

1. Menu Display (`display_menu`): Shows available options for user account management.
  
2. Adding a User (`add_user`):
   - Prompts for a username and a comment (e.g., the user's full name).
   - Creates a new user with `useradd -m -c "$COMMENT" "$USERNAME"`.
   - Checks if the user was added successfully.

3. Deleting a User (`delete_user`):
   - Prompts for the username to delete.
   - Deletes the user and their home directory with `userdel -r "$USERNAME"`.

4. Listing All Users (`list_users`):
   - Reads usernames from `/etc/passwd` to display all existing users.

5. Locking and Unlocking Accounts (`lock_user`, `unlock_user`):
   - Locks a user account with `usermod -L "$USERNAME"` and unlocks it with `usermod -U "$USERNAME"`.

6. Main Loop: Continuously shows the menu until the user chooses to exit.

Running the Script
Save the script to a file (e.g., `user_account_management.sh`), make it executable, and then run it:

```bash
chmod +x user_account_management.sh
./user_account_management.sh
```

This script is a simple but effective way to manage user accounts on a Linux system.

----------------------------------------------------------------------------------------------------------------

'''PASSWORD-GENERATOR'''

Here’s a shell script to generate secure passwords with options for password length, inclusion of special characters, and more.

Password Generator Script

This script provides options to:
- Specify the password length.
- Include or exclude special characters.
- Generate multiple passwords at once.

```bash
#!/bin/bash

# Function to display menu
display_menu() {
    echo "Password Generator Script"
    echo "1. Generate a Single Password"
    echo "2. Generate Multiple Passwords"
    echo "3. Exit"
}

# Function to generate a random password
generate_password() {
    local LENGTH=$1
    local INCLUDE_SPECIAL=$2

    # Define character sets
    local CHAR_SET="A-Za-z0-9"
    if [ "$INCLUDE_SPECIAL" = "yes" ]; then
        CHAR_SET="${CHAR_SET}!@#$%^&*()_+"
    fi

    # Generate the password
    PASSWORD=$(cat /dev/urandom | tr -dc "$CHAR_SET" | fold -w "$LENGTH" | head -n 1)
    echo "$PASSWORD"
}

# Function to generate a single password
generate_single_password() {
    read -p "Enter the desired password length: " LENGTH
    read -p "Include special characters? (yes/no): " INCLUDE_SPECIAL
    echo "Generated password:"
    generate_password "$LENGTH" "$INCLUDE_SPECIAL"
}

# Function to generate multiple passwords
generate_multiple_passwords() {
    read -p "Enter the desired password length: " LENGTH
    read -p "Include special characters? (yes/no): " INCLUDE_SPECIAL
    read -p "Enter the number of passwords to generate: " COUNT
    echo "Generated passwords:"
    for ((i = 1; i <= COUNT; i++)); do
        generate_password "$LENGTH" "$INCLUDE_SPECIAL"
    done
}

# Main program loop
while true; do
    display_menu
    read -p "Choose an option [1-3]: " OPTION

    case $OPTION in
        1)
            generate_single_password
            ;;
        2)
            generate_multiple_passwords
            ;;
        3)
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid option. Please select between 1 and 3."
            ;;
    esac
    echo ""
done
```

Explanation of the Script

1. `generate_password` Function: 
   - Generates a random password using `/dev/urandom`.
   - Uses a specified character set, and includes special characters if specified.

2. `generate_single_password` Function: 
   - Prompts for password length and whether to include special characters, then generates a single password.

3. `generate_multiple_passwords` Function:
   - Prompts for password length, special characters, and the number of passwords to generate, and then generates the specified number of passwords.

4. Main Loop:
   - Displays the menu and runs the appropriate function based on user input.

Running the Script

1. Save the script to a file, e.g., `password_generator.sh`.
2. Make it executable:

   ```bash
   chmod +x password_generator.sh
   ```

3. Run the script:

   ```bash
   ./password_generator.sh
   ```

This script can help quickly generate strong passwords with customizable options to suit various security needs.

----------------------------------------------------------------------------------------------------------------

'''FILE ENCRYPTION/DECRYPTION'''

Here’s a shell script that uses `openssl` to encrypt and decrypt files. This script lets you specify the file to encrypt or decrypt and the password for encryption.

File Encryption/Decryption Script

This script provides options for:
- Encrypting a file.
- Decrypting a file.

Note: You’ll need `openssl` installed on your system to run this script.

```bash
#!/bin/bash

# Function to display menu
display_menu() {
    echo "File Encryption/Decryption Script"
    echo "1. Encrypt a File"
    echo "2. Decrypt a File"
    echo "3. Exit"
}

# Function to encrypt a file
encrypt_file() {
    read -p "Enter the file to encrypt: " FILE
    read -sp "Enter password for encryption: " PASSWORD
    echo ""
    
    if [ -f "$FILE" ]; then
        openssl aes-256-cbc -salt -in "$FILE" -out "$FILE.enc" -k "$PASSWORD"
        if [ $? -eq 0 ]; then
            echo "File encrypted successfully as $FILE.enc"
        else
            echo "Failed to encrypt the file."
        fi
    else
        echo "File does not exist."
    fi
}

# Function to decrypt a file
decrypt_file() {
    read -p "Enter the file to decrypt: " FILE
    read -sp "Enter password for decryption: " PASSWORD
    echo ""
    
    if [ -f "$FILE" ]; then
        openssl aes-256-cbc -d -in "$FILE" -out "${FILE%.enc}" -k "$PASSWORD"
        if [ $? -eq 0 ]; then
            echo "File decrypted successfully as ${FILE%.enc}"
        else
            echo "Failed to decrypt the file. Incorrect password or corrupted file."
        fi
    else
        echo "File does not exist."
    fi
}

# Main program loop
while true; do
    display_menu
    read -p "Choose an option [1-3]: " OPTION

    case $OPTION in
        1)
            encrypt_file
            ;;
        2)
            decrypt_file
            ;;
        3)
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid option. Please select between 1 and 3."
            ;;
    esac
    echo ""
done
```

Explanation of the Script

1. `encrypt_file`:
   - Prompts for the filename to encrypt and a password.
   - Uses `openssl aes-256-cbc` to encrypt the file with AES-256 encryption.
   - Saves the encrypted file as `filename.enc`.

2. `decrypt_file`:
   - Prompts for the filename to decrypt and the password.
   - Uses `openssl aes-256-cbc -d` to decrypt the file.
   - Saves the decrypted file with the original filename (removes `.enc`).

3. Main Loop:
   - Displays a menu and runs the corresponding function based on user input.

Running the Script

1. Save the script to a file, e.g., `file_encrypt_decrypt.sh`.
2. Make it executable:

   ```bash
   chmod +x file_encrypt_decrypt.sh
   ```

3. Run the script:

   ```bash
   ./file_encrypt_decrypt.sh
   ```

This script offers a simple and secure way to encrypt and decrypt files using AES-256 encryption, which is strong and widely used for file protection.

----------------------------------------------------------------------------------------------------------------

'''AUTOMATED SOFTWARE INSTALLATION'''

Here’s a shell script that automates the installation of commonly used software packages. It checks for package installation, installs missing packages, and logs installation details.

This example script is tailored for Debian-based systems (like Ubuntu), using `apt` for package management. You can modify it for other package managers (like `yum` for CentOS/RHEL or `dnf` for Fedora).

Automated Software Installation Script

This script:
- Installs a list of specified packages if they’re not already installed.
- Logs installation status and results.
- Notifies the user if a package is already installed.

```bash
#!/bin/bash

# List of packages to install
PACKAGES=("curl" "git" "vim" "htop" "wget" "docker.io" "nodejs")

# Log file
LOG_FILE="installation_log.txt"

# Function to install a package
install_package() {
    local PACKAGE=$1
    if dpkg -s "$PACKAGE" &> /dev/null; then
        echo "$PACKAGE is already installed." | tee -a "$LOG_FILE"
    else
        echo "Installing $PACKAGE..."
        sudo apt-get install -y "$PACKAGE" &>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo "$PACKAGE installed successfully." | tee -a "$LOG_FILE"
        else
            echo "Failed to install $PACKAGE." | tee -a "$LOG_FILE"
        fi
    fi
}

# Update package list
echo "Updating package list..."
sudo apt-get update &>> "$LOG_FILE"
echo "Package list updated." | tee -a "$LOG_FILE"

# Install each package
for PACKAGE in "${PACKAGES[@]}"; do
    install_package "$PACKAGE"
done

echo "Software installation completed. Check $LOG_FILE for details."
```

Explanation of the Script

1. Define Package List:
   - The `PACKAGES` array holds the names of the packages you want to install. Add or remove packages as needed.

2. Log File:
   - Logs installation progress and results to `installation_log.txt`.

3. Install Package Function (`install_package`):
   - Checks if a package is already installed using `dpkg -s`.
   - Installs the package if it’s missing and logs the result.

4. Updating Package List:
   - Runs `sudo apt-get update` before installations to make sure package sources are up to date.

5. Loop through Packages:
   - Calls `install_package` for each package in the list, logging whether it’s installed or if installation failed.

Running the Script

1. Save the script to a file, e.g., `install_software.sh`.
2. Make it executable:

   ```bash
   chmod +x install_software.sh
   ```

3. Run the script:

   ```bash
   ./install_software.sh
   ```

This script streamlines software installations, ensures required software is installed, and maintains a log for auditing or troubleshooting.

----------------------------------------------------------------------------------------------------------------

