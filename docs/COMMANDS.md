# Shell Odyssey Command Reference

Quick reference for all commands taught in Shell Odyssey.

## Navigation Basics (Prerequisites)

```bash
pwd                     # Print working directory
ls                      # List files
ls -la                  # List all files (including hidden)
cd directory            # Change directory
cd ..                   # Go up one directory
cat file                # Display file contents
clear                   # Clear terminal screen
```

## Sector 1: Engineering - Search & Discovery

### grep - Search file contents
```bash
grep "pattern" file           # Search for pattern in file
grep -r "pattern" directory   # Recursive search
grep -i "pattern" file        # Case-insensitive search
grep -n "pattern" file        # Show line numbers
grep -c "pattern" file        # Count matches
grep -l "pattern" *.txt       # List files containing pattern
```

### find - Locate files
```bash
find . -name "filename"       # Find by exact name
find . -name "*.txt"          # Find by pattern
find . -type f                # Find only files
find . -type d                # Find only directories
find . -name "*.log" -type f  # Combined filters
```

### wc - Word/Line count
```bash
wc file                 # Lines, words, characters
wc -l file              # Count lines only
wc -w file              # Count words only
wc -c file              # Count characters only
```

## Sector 2: Communications - Data Processing

### Pipes - Chain commands
```bash
command1 | command2           # Send output of cmd1 to cmd2
cat file | grep "x" | wc -l   # Chain multiple commands
```

### head/tail - View portions of files
```bash
head file               # First 10 lines
head -n 20 file         # First 20 lines
tail file               # Last 10 lines
tail -n 20 file         # Last 20 lines
tail -n +5 file         # Everything from line 5 onward
```

### sort/uniq - Sort and deduplicate
```bash
sort file               # Sort alphabetically
sort -n file            # Sort numerically
sort -r file            # Reverse sort
uniq                    # Remove adjacent duplicates
sort file | uniq        # Sort then deduplicate
sort file | uniq -c     # Count occurrences
```

### cut - Extract fields
```bash
cut -d',' -f1 file      # Get 1st comma-separated field
cut -d':' -f2 file      # Get 2nd colon-separated field
cut -d' ' -f1,3 file    # Get fields 1 and 3
cut -c1-10 file         # Get characters 1-10
```

### awk - Pattern processing
```bash
awk '{print $1}' file         # Print 1st field (space-delimited)
awk '{print $NF}' file        # Print last field
awk -F',' '{print $2}' file   # Use comma as delimiter
awk '$1 > 10' file            # Filter by condition
```

### Redirects - Output control
```bash
command > file          # Write output to file (overwrite)
command >> file         # Append output to file
command 2> file         # Redirect errors to file
command &> file         # Redirect all output to file
command < file          # Use file as input
```

## Sector 3: Reactor - Automation & Repair

### sed - Stream editor
```bash
sed 's/old/new/' file         # Replace first occurrence per line
sed 's/old/new/g' file        # Replace all occurrences
sed -i '' 's/old/new/g' file  # Edit in place (macOS)
sed -i 's/old/new/g' file     # Edit in place (Linux)
sed '/pattern/d' file         # Delete lines matching pattern
sed -n '5,10p' file           # Print lines 5-10
```

### xargs - Build commands from input
```bash
echo "a b c" | xargs echo           # Run echo with a b c as args
find . -name "*.txt" | xargs grep "x"  # Search found files
ls *.log | xargs -I {} mv {} {}.bak    # Use placeholder
cat list.txt | xargs -n 1 command      # One arg at a time
```

### Shell Scripts
```bash
#!/bin/bash             # Shebang line (first line of script)
chmod +x script.sh      # Make script executable
./script.sh             # Run script

# Variables
NAME="value"
echo $NAME

# Conditionals
if [ condition ]; then
    commands
fi

# Loops
for file in *.txt; do
    echo $file
done
```

### chmod - File permissions
```bash
chmod +x file           # Add execute permission
chmod -x file           # Remove execute permission
chmod 755 file          # rwxr-xr-x
chmod 644 file          # rw-r--r--
```

## Advanced (Bridge - Optional)

### Process management
```bash
ps                      # List your processes
ps aux                  # List all processes
kill PID                # Terminate process
kill -9 PID             # Force terminate
jobs                    # List background jobs
command &               # Run in background
fg                      # Bring to foreground
```

### Networking
```bash
curl URL                # Fetch URL content
curl -o file URL        # Save to file
wget URL                # Download file
ssh user@host           # Connect to remote host
scp file user@host:path # Copy file to remote
```

## Tips & Tricks

### Command History
```bash
history                 # Show command history
!!                      # Repeat last command
!n                      # Repeat command n from history
Ctrl+R                  # Search history
```

### Getting Help
```bash
man command             # Manual page
command --help          # Quick help
```

### Useful Combinations
```bash
# Find and replace in multiple files
find . -name "*.txt" | xargs sed -i '' 's/old/new/g'

# Count unique values in a column
cut -d',' -f2 file.csv | sort | uniq -c | sort -rn

# Find large files
find . -type f -size +1M

# Watch a log file in real-time
tail -f logfile.log
```

---

*"Master your terminal, master your universe."*
