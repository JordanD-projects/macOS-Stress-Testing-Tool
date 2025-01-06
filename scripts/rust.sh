#!/bin/bash
script_dir=$(dirname "$0")
# $1 = number of iteration 
# $2 = name of the test

#1. pre run steps / clean up
# Downloads polars (rust project) from github
tmp_dir="$script_dir/tmp/dependencies/$2/"
tmp_results="$script_dir/tmp/$2-results-$1.txt"

# Remove existing tmp_dir and recreate it
if [ -d "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
fi
mkdir -p "$tmp_dir"
touch "$tmp_results"

# 2. Run performance logging here
sleep 5
top -a -n20 -o cpu -ncols 3 | grep "com.jamf.protect" > "$tmp_results" &
top_pid=$!
echo "Started background process with PID: $top_pid"

# 3. Test steps    
# Compiles polars from its directory and then deletes it, continuing loop
git clone https://github.com/pola-rs/polars/ $script_dir/tmp/dependencies/polars/

cd $script_dir/tmp/dependencies/polars

cargo build --release
cargo clean

cd "$script_dir"

# 4. Clean up files, remove temp files
# Kill the background `top` process when done
wait $top_pid
echo "Top process completed."

# Kill the background `top` process if it's still running
if ps -p $top_pid > /dev/null; then
    kill $top_pid
    echo "Killed top process."
else
    echo "Top process already finished."
fi

rm -rf "${tmp_dir}"*  # Remove the tmp folder we created