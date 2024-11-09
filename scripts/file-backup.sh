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