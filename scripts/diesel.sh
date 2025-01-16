#!/bin/bash
script_dir=$(dirname "$0")
# $1 = number of iterations
# $2 = name of the test
# $3 = number of iterations between performance samples

# 1. Pre-run steps / clean up
# run touch / mkdir for files we need
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

# 3. Test steps: Downloads diesel from GitHub, enters the directory, and runs cargo check
for (( i=1; i<=$3; i++ )); do
    git clone https://github.com/diesel-rs/diesel "$tmp_dir"
    if [ $? -eq 0 ]; then
        sudo cargo check --manifest-path "${tmp_dir}/Cargo.toml" --features "128-column-tables"
    else
        echo "Git clone failed"
        exit 1
    fi
done

# 4. Clean up files, remove temp files
# Wait for the background `top` process to finish
echo "Top process completed."

# Kill the background `top` process if it's still running
if ps -p $top_pid > /dev/null; then
    kill $top_pid
    echo "Killed top process."
else
    echo "Top process already finished."
fi

rm -rf "${tmp_dir}"*  # Remove the tmp folder we created