#!/bin/bash

# Define the source and target directories
source_dir="$HOME/Downloads/odyssey"  # Using $HOME for proper path expansion
target_dir="assets/"  # Assuming this is the correct relative path

# Iterate through all files in the source directory recursively
find "$source_dir" -type f | while read -r source_file; do
    # Extract the file name from the source file path
    file_name=$(basename "$source_file")

    # Find the corresponding file in the target directory recursively (not just subfolders)
    target_file=$(find "$target_dir" -type f -name "$file_name")

    # Check if the file exists in the target directory
    if [ -n "$target_file" ]; then
        # Replace the target file with the source file
        echo "Replacing '$target_file' with '$source_file'"
        cp -f "$source_file" "$target_file"
    else
        echo "File '$file_name' not found in the target directory, skipping."
    fi
done

echo "File replacement complete."
