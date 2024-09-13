#!/bin/bash

# File to store vhost entries
VHOSTS_FILE=".vhosts"

# Function to add a vhost
add_vhost() {
    echo "$1" >> "$VHOSTS_FILE"
    echo "Added $1 to vhosts"
}

# Function to remove a vhost
remove_vhost() {
    sed -i "" "/$1/d" "$VHOSTS_FILE"
    echo "Removed $1 from vhosts"
}

# Function to list all vhosts
list_vhosts() {
    if [ -f "$VHOSTS_FILE" ]; then
        cat "$VHOSTS_FILE"
    else
        echo "No vhosts configured"
    fi
}

# Function to update /etc/hosts
update_hosts() {
    sudo sed -i "" '/# START SPIN VHOSTS/,/# END SPIN VHOSTS/d' /etc/hosts
    echo "# START SPIN VHOSTS" | sudo tee -a /etc/hosts > /dev/null
    while IFS= read -r line; do
        echo "127.0.0.1 $line" | sudo tee -a /etc/hosts > /dev/null
    done < "$VHOSTS_FILE"
    echo "# END SPIN VHOSTS" | sudo tee -a /etc/hosts > /dev/null
    echo "Updated /etc/hosts"
}

# Function to get project name from current directory
get_project_name() {
    basename "$(pwd)"
}

# Function to add default vhost
add_default_vhost() {
    local project_name=$(get_project_name)
    local vhost="${project_name}.test"
    if ! grep -q "^${vhost}$" "$VHOSTS_FILE" 2>/dev/null; then
        add_vhost "$vhost"
        echo "Added default vhost: $vhost"
    else
        echo "Default vhost $vhost already exists"
    fi
}

# Main script logic
# Main script logic
case "$1" in
    init)
        add_default_vhost
        update_hosts
        ;;
    add)
        add_vhost "$2"
        update_hosts
        ;;
    remove)
        remove_vhost "$2"
        update_hosts
        ;;
    list)
        list_vhosts
        ;;
    update)
        update_hosts
        ;;
    *)
        echo "Usage: $0 {init|add|remove|list|update} [vhost]"
        exit 1
esac