# Shield Guard Utility
A utility for making stress testing and reporting on Jamf Protect performance using bash scripts

## How To Use
Simply download the repo onto the test computer you want to use it on and run `stress_test_script_runner.sh`. You can configure which tests run by adding or removing them to the `test_names` variable and can change how many times each runs by editing the `num_runs_for_tests` array. 

NOTE: If you abort the tests before it completes and cleans up, please make sure to removed the `/scripts/tmp/` directory or you could run into issues. Also, you can enable / disable debug mode (extra logging, prevents deletiong of `/scripts/tmp/` after completion) by setting `debug` to 1 in order to enable and 0 to disable. 

## Description of Tests (alphabetical)
- "auth_event_c"
    - Tests auth events by creating and compiling a bunch of C files which contain "hello world". It will run 100 times for each iteration you set in "num_runs_for_tests"
- "chmod_file"
    - Creates and then changes permissions on a ton of files on your computer. These files will have lorem ipsum text injected into them so they aren't just empty files. It will run 100 times for each iteration you set in "num_runs_for_tests"
- "create_file"
    - Creates a ton of files on your computer. These files will have lorem ipsum text injected into them so they aren't just empty files. It will run 100 times for each iteration you set in "num_runs_for_tests"
- "delete_file"
    - Creates and then deletes a ton of files on your computer. These files will have lorem ipsum text injected into them so they aren't just empty files. It will run 100 times for each iteration you set in "num_runs_for_tests"
- "diesel" 
    - Created by Shopify, it GIT clones the https://github.com/diesel-rs/diesel and runs a cargo check on a specific manifest path. 
- "eicar_stress_test"    
    - Run the eicar file x number of times. It will run 100 times for each iteration you set in "num_runs_for_tests"
- "ripgrep" 
    - Craated by Shopify, it runs "time rg anyrandomstring" and "'sync && purge'". It will run 100 times for each iteration you set in "num_runs_for_tests"
- "rust" 
    - Created by Shopify, it GIT clones the https://github.com/pola-rs/polars/ repo and runs "cargo build --release" and "cargo clean"
- "tamper_prevention"
    - Tests that tamper prevention is triggered and withstands a large amount of stress. 
