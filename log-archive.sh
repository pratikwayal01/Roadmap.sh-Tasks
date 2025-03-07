#!/bin/bash

# Check if log directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <log-directory>"
    exit 1
fi

log_dir="$1"
archive_dir="${log_dir}/archives"
timestamp=$(date +%Y%m%d_%H%M%S)
archive_name="logs_archive_${timestamp}.tar.gz"
log_file="${archive_dir}/archive.log"

# Validate log directory existence
if [ ! -d "$log_dir" ]; then
    echo "Error: Log directory '$log_dir' does not exist."
    exit 1
fi

# Create archive directory if it doesn't exist
mkdir -p "$archive_dir"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create archive directory '$archive_dir'."
    exit 1
fi

# Create compressed archive of log directory, excluding the archives directory
echo "Archiving logs from $log_dir..."
tar czf "${archive_dir}/${archive_name}" --exclude="archives" -C "$log_dir" .
if [ $? -ne 0 ]; then
    echo "Error: Failed to create archive. Check permissions and try again."
    exit 1
fi

# Log the archive operation
log_entry="$(date '+%Y-%m-%d %H:%M:%S') - Created archive: ${archive_name}"
echo "$log_entry" >> "$log_file"
if [ $? -ne 0 ]; then
    echo "Error: Failed to write to log file '$log_file'."
    exit 1
fi

echo "Successfully created archive: ${archive_dir}/${archive_name}"
