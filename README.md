# macOS Stress Test Utility
A utility for making stress testing and reporting on Jamf Protect performance using bash scripts
## How to deploy and use this tool 

### Prerequisites: 
 - Please make sure you are on bash 5.2 or higher using homebrew. In order to use assciative arrays we need to be on 5.2 or higher or the script will not work. 
 - Terminal needs to have Full Disk Access and the Terminal application needs to be restarted after enabling Full Disk Access in order to apply it. 
 - Optional: It is not required as the script will install Brew but it isn't a bad idea to have it already installed so we can skip this step.

### Steps to use: 
1. Simply download the repo onto the test computer you want to use it on and run `sudo bash path/to/stress_test_script_runner.sh`. You can configure which tests run by simply commenting them in / out of teh `tests_to_run` array. For setting the numner of iterations and samples, the first value is the number of performance samples we want to take and the second is the number of loops to do before we start the next perormance sample. Example: If we set the values to "5 100" we would run a total of 500 iterations but between each 100, we would start a new performance check. Tests that execute quickly will need to have more iterations or the performance information will be blank as they will execute too fast for the performance information to be accurately captured.
2. Once the tests complete, you can find the compiled results in the "results" folder labelled with a data / time stamp of when you started the test. 
NOTE: If you abort the tests before it completes and cleans up, please make sure to removed the `/scripts/tmp/` directory or you could run into issues. Also, you can enable / disable debug mode (extra logging, prevents deletiong of `/scripts/tmp/` after completion) by setting `debug` to 1 in order to enable and 0 to disable. Enabling debug will produce more logging but will also skip deletign the `/scripts/tmp` directory during clean up which can be very helpful with debugging. You can also enable / disable including diagnostics for Jamf Protect by setting `include_diagnostics` to 1 to capture diagnostics or 0 to ignore it. 
## Description of Tests (alphabetical)
- "auth_event_c"
    - Tests auth events by creating and compiling a bunch of C files which contain "hello world".
- "chmod_file"
    - Creates and then changes permissions on a ton of files on your computer. These files will have lorem ipsum text injected into them so they aren't just empty files.
- "create_file"
    - Creates a ton of files on your computer. These files will have lorem ipsum text injected into them so they aren't just empty files.
- "delete_file"
    - Creates and then deletes a ton of files on your computer. These files will have lorem ipsum text injected into them so they aren't just empty files.
- "diesel" 
    - This test GIT clones the https://github.com/diesel-rs/diesel and runs a cargo check on a specific manifest path. 
- "eicar_stress_test"    
    - Run the eicar file x number of times.
- "ripgrep" 
    - This test runs "time rg anyrandomstring" and "'sync && purge'".
- "rust" 
    - This test GIT clones the https://github.com/pola-rs/polars/ repo and runs "cargo build --release" and "cargo clean"
- "tamper_prevention"
    - Tests that tamper prevention is triggered and withstands a large amount of stress. 
