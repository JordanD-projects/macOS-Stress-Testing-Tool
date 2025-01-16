#!/opt/homebrew/bin/bash

# TODO: Make sure you clean up tmp folder even when not done with run or you could get extra data shoved into old files... need to either use the timestamp on the tmp folder as well or find another workaround. 
# TODO: Add in changes Sergiusz made to first test report for Matt - talk to Sergiusz
# TODO: refactor code by creating functions and removing duplicate for loops
# TODO: Tell user to set computer to not sleep / do this if we can with swift?
# TODO: Pass in num_iterations and from Swift app and ability to specify a test name as well as an array of tests (tests_to_run) and whether or not you want formatting results for each one...
# TODO: Should we nuke the protect db before running scripts and restart system extension?
# TODO: Add network testing using System Settings
# TODO: Export data to CSV? Add more explanaitons to output? 
# TODO: Add any additional info to output that would be useful. 
# TODO: Analyze data over time. 

time_format() {
    local start_time_in_seconds=$1
    local end_time_in_seconds=$2

    # Calculate duration in seconds
    local duration_test=$(($end_time_in_seconds - $start_time_in_seconds))

    # Calculate minutes and seconds
    local duration_minutes=$((duration_test / 60))
    local duration_seconds=$((duration_test % 60))

    # Output the result
    echo "$duration_minutes minutes and $duration_seconds seconds."
}

# Declare an associative array
declare -A tests_to_run

# !NOTE: To turn on or off tests, simply comment out the item in the array below.
# The first value is the number of performance samples we want to take and the second is the number of loops to do before we start the next perormance sample. 
# Example: If we set the values to "5 100" we would run a total of 500 iterations but between each 100, we would start a new performance check. 
tests_to_run["auth_event_c"]="5,1000"
tests_to_run["chmod_file"]="5,10000"
tests_to_run["create_file"]="5,10000"
tests_to_run["delete_file"]="5,10000"
tests_to_run["diesel"]="5,5"
tests_to_run["eicar_stress_test"]="5,10"
tests_to_run["ripgrep"]="5,100"
tests_to_run["rust"]="5,5"
tests_to_run["tamper_prevention"]="5,10"

script_dir=$(dirname "$0")
debug=0 # Set to 1 to enable debug and 0 to disable
include_diagnostics=0 # Do we want to grab diagnostics as well?
mkdir $script_dir/scripts/scripts/tmp/
mkdir $script_dir/scripts/scripts/tmp/dependencies/
mkdir $script_dir/results/
jamfProtectBinaryLocation="/usr/local/bin/protectctl"
plist=$($jamfProtectBinaryLocation info --plist)

# Get a timestamp and create our folder for our results as well as the file the results will be listed in
timestamp=$(date "+%Y-%m-%d-%H-%M-%S")
mkdir -p $script_dir/results/results-$timestamp/

# Extension Version
protect_version=$(/usr/libexec/PlistBuddy -c "Print Version" /dev/stdin <<< "$plist")

# Prompt the user to confirm they have granted full disk access for Terminal
echo "Please ensure Terminal has Full Disk Access? (go to System Settings -> Privacy & Security -> Full Disk Access -> Terminal) and then restart Terminal"
while true; do
    read -p "Do you want to proceed? (y/n): " answer
    answer=$(echo "$answer" | xargs | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
        echo "Proceeding with the operation..."
        break  # Exit the loop once the answer is valid
    # Check if the answer is 'n' or 'no'
    elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
        echo "Operation cancelled."
        exit 1  # Exit the script if the answer is 'no'
    fi
done

# Check if homebrew is installed. If it isn't, install it. We will need it for lots of things.
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# If bash is already installed, just update it brew upgrade bash, otherwise install it
if ! brew list --formula | grep  "bash"; then
    sudo -u $(logname) brew install bash
else
    # Update bash
    sudo -u $(logname) brew upgrade bash
fi

# Capture start time for the entire test run
start_time_total=$(date +%s)

# Loop through the array of tests passed to us
for test_name in "${!tests_to_run[@]}"; do
    # Split the string into samples and iterations
    IFS=',' read -r num_samples num_iterations <<< "${tests_to_run[$test_name]}"

    echo "$test_name"
    echo "Samples: $num_samples"
    echo "Iterations: $num_iterations"

    run_total=$((num_samples * num_iterations))

    if [ $debug -eq 1 ]; then
        echo "Test Name: $test_name, Num Samples: $num_samples Num Iterations: $num_iterations"
    fi

    # Capture start time for the individual test
    start_time_test=$(date +%s)
    
    # Check if preinstall script exists and run it
    echo "Checking for preinstall script for $test_name script"
    if [ -f "$script_dir/scripts/preinstall_$test_name.sh" ]; then
        echo "Preinstall script for $test_name found. Executing script..."
        sudo -u $(logname) sh $script_dir/scripts/preinstall_$test_name.sh
    fi

    # Run the script the number of iterations specified but run each preinstall and postinstall once
    echo "Executing main $test_name test. Please wait..."
    # Save the test name and number of iterations name:
    echo "Test Name: $test_name - # of runs (iterations * samples): $run_total - Performance was checked $num_samples times after every $num_iterations iterations - Protect Version $protect_version" >> $script_dir/results/results-$timestamp/$test_name-formatted_results.txt
    for (( i=1; i<=$num_samples; i++ )); do
        echo "Executing $test_name test $i of $num_samples"
        sh $script_dir/scripts/$test_name.sh $i $test_name $num_iterations
    done

    # Check if postinstall script exists and run it
    if [ -f "$script_dir/scripts/postinstall_$test_name.sh" ]; then
        echo "Postinstall script for $test_name found. Executing script..."
        sudo -u $(logname) sh $script_dir/scripts/postinstall_$test_name.sh
    fi

    # Capture end time for the individual test
    end_time_test=$(date +%s)
    test_duration=$(time_format $start_time_test $end_time_test)

    echo "Test $test_name completed in $test_duration" >> $script_dir/results/results-$timestamp/$test_name-formatted_results.txt

    # Compile the results
    for (( i=1; i<=$num_samples; i++ )); do
        # format results
        awk '{printf "%.2f\n", $3}' $script_dir/scripts/tmp/"$test_name"-results-"$i".txt >> $script_dir/scripts/tmp/$test_name-formatted-results.txt
    done
    echo "\n \n"  >> $script_dir/results/results-$timestamp/$test_name-formatted_results.txt
done

# Capture end time for the entire test run
end_time_total_test=$(date +%s)
test_duration_total=$(time_format $start_time_total $end_time_total_test)

# Print total test duration
echo "All test runs completed in $test_duration_total" >> $script_dir/results/results-$timestamp/final_formatted_results.txt

# Get macOS version information
os_version=$(sw_vers -productVersion)

# Get processor information
processor=$(sysctl -n machdep.cpu.brand_string)

echo "OS Version: macOS $os_version - Processor: $processor" >> $script_dir/results/results-$timestamp/final_formatted_results.txt

# Get HTTP Queue
http_queue_size=$(/usr/libexec/PlistBuddy -c "Print UploadQueue:HTTP" /dev/stdin <<<"$plist")

# Get Log Queue
log_queue_size=$(/usr/libexec/PlistBuddy -c "Print UploadQueue:LogFile" /dev/stdin <<<"$plist")

# Jamf Cloud Queue
jamf_cloud_queue=$(/usr/libexec/PlistBuddy -c "Print UploadQueue:JamfCloud" /dev/stdin <<<"$plist")

echo "HTTP Queue: $http_queue_size - Jamf Cloud Queue: $jamf_cloud_queue - Log Queue: $log_queue_size" >> $script_dir/results/results-$timestamp/final_formatted_results.txt
echo "\n \n"  >> $script_dir/results/results-$timestamp/final_formatted_results.txt

# If we chose to run with diagnostics, do that now and add it to the results folder
if [ $include_diagnostics -eq 1 ]; then
    echo "Runnning Diagnostics..."
    protectctl diagnostics -o $script_dir/results/results-$timestamp/
fi

for test_name in "${!tests_to_run[@]}"; do

    # Values from test files stored in array
    lines=()

    # Loop through each line in the file and append it to the array
    while IFS= read -r line; do

        # Check if the line matches the regular expression for a float and discard it if it doesn't
        # Ignore 0.00 by only looking at things greater than 0.1
        if [[ "$line" =~ ^[+-]?[0-9]+(\.[1-9]+)?$ ]]; then
            # If it's a valid float, append it to the array
            lines+=("$line")
        fi

    done < "$script_dir/scripts/tmp/$test_name-formatted-results.txt"

    min_value=${lines[0]}
    max_value=${lines[0]}
    sum=0
    count=0

    # Loop through the array to calculate min, max, sum, and count
    for num in "${lines[@]}"; do
        if [ $debug -eq 1 ]; then
            echo "Processing: $num"
        fi

        # Calculate min (using bc for floating-point comparison)
        min_check=$(echo "$num < $min_value" | bc -l)
        if [ $debug -eq 1 ]; then
            echo "Min check: $min_check"
        fi
        if [ "$min_check" -eq 1 ]; then
            min_value=$num
        fi

        # Calculate max (using bc for floating-point comparison)
        max_check=$(echo "$num > $max_value" | bc -l)
        if [ $debug -eq 1 ]; then
            echo "Max check: $max_check"
        fi 
        if [ "$max_check" -eq 1 ]; then
            max_value=$num
        fi

        # Calculate sum (using bc for floating-point arithmetic)
        sum=$(echo "$sum + $num" | bc -l)
        
        if [ $debug -eq 1 ]; then
            echo "Sum so far: $sum"
        fi

        # Increment count for each number
        ((count++))
    done

    # Calculate mean (average) using bc
    mean_value=$(echo "$sum / $count" | bc -l)

    # Print results
    if [ $debug -eq 1 ]; then
        echo "Minimum value: $min_value"
        echo "Maximum value: $max_value"
        echo "Sum: $sum"
        echo "Mean (average): $mean_value"
    fi

    # Save values to file
    echo "Number of Records: $count - Minimum Value Recorded: $min_value - Maximum Value Recorded: $max_value - Mean: $mean_value" >> $script_dir/results/results-$timestamp/$test_name-formatted_results.txt

    # Cat out the formatted data
    cat $script_dir/results/results-$timestamp/$test_name-formatted_results.txt

    # Compile all results together into "final results"
    cat $script_dir/results/results-$timestamp/$test_name-formatted_results.txt >> $script_dir/results/results-$timestamp/final_formatted_results.txt
done

echo "Description of values: \n \n" >> $script_dir/results/results-$timestamp/final_formatted_results.txt
echo "Average = mean (sum of all values divided by the number of values) \n \n" >> $script_dir/results/results-$timestamp/final_formatted_results.txt
echo "Minimum Value = the smallest recorded value in the set \n \n" >> $script_dir/results/results-$timestamp/final_formatted_results.txt
echo "Maximum Value = the largest recorded value in the set \n \n" >> $script_dir/results/results-$timestamp/final_formatted_results.txt
echo "Sum = the sum of all values recorded across all runs of the test \n \n" >> $script_dir/results/results-$timestamp/final_formatted_results.txt
echo "\n \n" >> $script_dir/results/results-$timestamp/final_formatted_results.txt

# clean up all files in tmp dir
if [ $debug -eq 0 ]; then
    rm -rf $script_dir/scripts/tmp/
fi
