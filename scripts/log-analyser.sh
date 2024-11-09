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

1. **`count_requests`**: Counts the total lines in the log file, which typically represents the total requests.

2. **`list_unique_ips`**: Extracts unique IP addresses from the first column (standard position for IPs in access logs).

3. **`count_status_codes`**: Extracts the HTTP status codes from the log file and counts occurrences for each code. It expects the status code in the 9th field, which is typical for Apache/Nginx logs.

4. **`top_10_ips`**: Displays the top 10 IPs by request count, helping identify the most active clients.

5. **`count_errors`**: Counts occurrences of HTTP error codes (4xx and 5xx), useful for detecting client and server errors.

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