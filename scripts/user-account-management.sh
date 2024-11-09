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

1. **Menu Display (`display_menu`)**: Shows available options for user account management.
  
2. **Adding a User (`add_user`)**:
   - Prompts for a username and a comment (e.g., the user's full name).
   - Creates a new user with `useradd -m -c "$COMMENT" "$USERNAME"`.
   - Checks if the user was added successfully.

3. **Deleting a User (`delete_user`)**:
   - Prompts for the username to delete.
   - Deletes the user and their home directory with `userdel -r "$USERNAME"`.

4. **Listing All Users (`list_users`)**:
   - Reads usernames from `/etc/passwd` to display all existing users.

5. **Locking and Unlocking Accounts (`lock_user`, `unlock_user`)**:
   - Locks a user account with `usermod -L "$USERNAME"` and unlocks it with `usermod -U "$USERNAME"`.

6. **Main Loop**: Continuously shows the menu until the user chooses to exit.

Running the Script
Save the script to a file (e.g., `user_account_management.sh`), make it executable, and then run it:

```bash
chmod +x user_account_management.sh
./user_account_management.sh
```

This script is a simple but effective way to manage user accounts on a Linux system.
'''