#!/bin/bash
script_dir=$(dirname "$0")
# $1 = number of iteration 
# $2 = name of the test

# 1. pre run steps / clean up
# run touch / mkdir for files we need
tmp_dir="$script_dir/tmp/dependencies/$2/"
tmp_results="$script_dir/tmp/$2-results-$1.txt"
src_file="$script_dir/auth_event_c_file.c"

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
sleep 5

# 3. Test steps    
# Run any test steps here :)
for (( i=1; i<=100; i++ )); do
    # Copy the .c file
    cp "$src_file" "$tmp_dir/auth_event_c_file_${i}.c"

    # Compile the file
    gcc "$tmp_dir/auth_event_c_file_$i.c" -o "$tmp_dir/auth_event_c_file_${i}.out"

    # Execute the compiled file
    "${tmp_dir}/auth_event_c_file_${i}.out" &
    sleep 2
done

# 4. Clean up files, remove temp files
# Kill the background `top` process when done
echo "Top process completed."

# Kill the background `top` process if it's still running
if ps -p $top_pid > /dev/null; then
    kill $top_pid
    echo "Killed top process."
else
    echo "Top process already finished."
fi

rm -rf "${tmp_dir}"*  # Remove the tmp folder we created