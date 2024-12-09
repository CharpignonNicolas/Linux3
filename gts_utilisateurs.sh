#!/bin/bash

# Function to generate a random password
generate_password() {
    echo $(openssl rand -base64 12)
}

# Function to create a user with a random password and add to groups
create_user() {
    local username=$1
    shift
    local groups=$@
    local password=$(generate_password)
    
    sudo useradd -m -s /bin/bash -G $groups $username
    echo "$username:$password" | sudo chpasswd
    echo "User $username created with password $password"
}

# Function to delete a user and remove from groups
delete_user() {
    local username=$1
    
    sudo deluser $username
    sudo rm -rf /home/$username
    echo "User $username deleted"
}

# Function to create a group
create_group() {
    local groupname=$1
    
    sudo groupadd $groupname
    echo "Group $groupname created"
}

# Function to add a user to a group
add_user_to_group() {
    local username=$1
    local groupname=$2
    
    sudo usermod -aG $groupname $username
    echo "User $username added to group $groupname"
}

# Function to grant sudo privileges to a user
grant_sudo() {
    local username=$1
    
    sudo usermod -aG sudo $username
    echo "User $username granted sudo privileges"
}

# Main script logic
case $1 in
    create_user)
        create_user $2 $3
        ;;
    delete_user)
        delete_user $2
        ;;
    create_group)
        create_group $2
        ;;
    add_user_to_group)
        add_user_to_group $2 $3
        ;;
    grant_sudo)
        grant_sudo $2
        ;;
    *)
        echo "Usage: $0 {create_user|delete_user|create_group|add_user_to_group|grant_sudo} ..."
        ;;
esac