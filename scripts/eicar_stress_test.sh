#!/bin/bash
script_dir=$(dirname "$0") # The Current directory we are in
# $1 = number of iteration 
# $2 = name of the test
# $3 = number of iterations between performance samples

# 1. pre run steps / clean up
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
sleep 5 # Usually good to have so we can make sure the files are created before we start trying to read the performance. More important on older hardware like Intel.
top -a -n20 -o cpu -ncols 3 | grep "com.jamf.protect" > $tmp_results & # Read the performance as a background task
top_pid=$!
echo "Started background process with PID: $top_pid" # This is the PID for our performance results. We need to kill this at the end

# 3. Test steps    
# Run any test steps here :)
for (( i=1; i<=$3; i++ )); do
    hash="X5O!P%@AP[4\\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*"

    # Decode the base 64 encoded string.
    decoded_hash=$(echo "$hash" | base64 --decode)
    
    # Create a .sh script with the contents of the hash, then attempt to execute it.
    touch "$tmp_dir/eicar_tmp.sh"
    echo "$decoded_hash" > "$tmp_dir/eicar_tmp.sh"
    sh "$tmp_dir/eicar_tmp.sh"
    sleep 5

    rm -rf "$tmp_dir/eicar_tmp.sh"
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