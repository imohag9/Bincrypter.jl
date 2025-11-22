# Bincrypter [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://imohag9.github.io/Bincrypter.jl/dev/) [![Build Status](https://github.com/imohag9/Bincrypter.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/imohag9/Bincrypter.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

`Bincrypter.jl` is a Julia package that provides a convenient and robust wrapper around the popular `bincrypter.sh` command-line tool. It allows you to easily encrypt, obfuscate, and lock executable binaries and shell scripts directly from your Julia environment.

The `bincrypter.sh` tool, developed by The Hackers Choice (THC), is a powerful utility for making binaries or scripts harder to analyze or reverse-engineer, and can optionally protect them with a password or lock them to a specific system/user ID. `Bincrypter.jl` simplifies its usage within Julia projects.

## Features

*   **Seamless Integration**: Easily call `bincrypter.sh` functions directly from Julia.
*   **Automatic Dependency Management**: The `bincrypter.sh` script is automatically downloaded and managed using Julia's `Pkg.Artifacts`, ensuring it's available without manual setup.
*   **Comprehensive Options**: Supports `bincrypter.sh`'s key functionalities, including:
    *   Basic obfuscation.
    *   Password-based encryption.
    *   System/user ID locking.
    *   Quiet mode for suppressing output.
*   **Robust Error Handling**: Catches and reports errors from the `bincrypter.sh` process.
*   **Cross-Platform Compatibility**: Leveraging GitHub Actions, the package is tested across Linux and macOS environments.

## Installation

`Bincrypter.jl` can be installed like any other Julia package:

```julia
using Pkg
Pkg.add("Bincrypter")
```

The `bincrypter.sh` script itself is automatically downloaded and managed by `Pkg.Artifacts` when the `Bincrypter` module is first loaded, so no manual installation of the script is required.

## Quick Start

The main function is `Bincrypter.bincrypter()`. It takes the path to your input file as its first argument, and various keyword arguments to control the `bincrypter.sh` behavior.

```julia
using Bincrypter

# Create a dummy executable script for demonstration
script_path = "my_temp_script.sh"
open(script_path, "w") do f
    write(f, "#!/bin/bash\n\n# This is a test script.\necho 'Hello from Bincrypter!'\n")
end
chmod(script_path, 0o755) # Make it executable

println("--- Original script content ---")
run(`cat $script_path`)
println("-----------------------------")

# 1. Basic obfuscation (without a password)
println("\n>>> Obfuscating $(script_path)...")
bincrypter(script_path)
println("Obfuscation complete. The original file has been overwritten.")
println("Note: To run the obfuscated script, simply execute it.")
println("-----------------------------")

# Re-create script for next example
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'Hello again!'")
end
chmod(script_path, 0o755)

# 2. Encrypt a script with a password
println("\n>>> Encrypting $(script_path) with password 'MySecretPassword123'...")
bincrypter(script_path; password="MySecretPassword123")
println("Encryption complete. The original file has been overwritten.")
println("Note: When executed, the script will now prompt for the password.")
println("-----------------------------")

# Re-create script for next example
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'Hello from a locked script!'")
end
chmod(script_path, 0o755)

# 3. Lock a script to the current system and user ID
#    Note: When `lock=true`, the `password` argument is ignored by bincrypter.sh.
println("\n>>> Locking $(script_path) to the current system and user...")
bincrypter(script_path; lock=true)
println("Locking complete. The original file has been overwritten.")
println("Note: This script will only run on the system it was locked on and by the same user.")
println("-----------------------------")

# Re-create script for next example
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'Quiet operation!'")
end
chmod(script_path, 0o755)

# 4. Run quietly (suppress bincrypter.sh's console output)
println("\n>>> Obfuscating $(script_path) quietly...")
bincrypter(script_path; quiet=true)
println("Quiet obfuscation complete.")
println("-----------------------------")

# 5. Use custom Environment Variables
println("\n>>> Obfuscating $(script_path) with BC_PADDING=0...")
# bincrypter.sh can be configured via environment variables.
# For example, BC_PADDING=0 can disable padding, potentially resulting in a smaller file.
bincrypter(script_path; env=Dict("BC_PADDING" => "0"))
println("Obfuscation complete with custom environment variable set.")
println("-----------------------------")

# Clean up the dummy script
rm(script_path)
```

## Important Notes and Security Considerations

*   **Password Security**: When providing a `password` via the `bincrypter` function, it is passed as a command-line argument to the underlying `bincrypter.sh` script. This means the password might be visible in process lists (e.g., `ps aux`) on the system for a short period. Exercise caution with sensitive information and consider the security implications of this method.
*   **In-Place Modification**: The `bincrypter.sh` tool, and consequently this wrapper, modifies the input file *in place*. Always ensure you have backups of your original scripts/binaries before using this tool.
*   **Locking Behavior**: As documented by `bincrypter.sh`, if `lock=true`, the `password` argument is ignored, and the binary is locked to the current system and user ID.

## Documentation

For more detailed information, API reference, and advanced usage, please refer to the [official documentation](https://imohag9.github.io/Bincrypter.jl/dev/).


## Development Notes

This package was developed with the assistance of multiple AI coding tools to accelerate implementation and ensure compatibility with the original project. These tools helped with:

- API design consistency
- Error handling patterns
- Documentation generation
- Test case development

The core functionality remains faithful to the original Bincrypter project, and the script file is downloaded directly from The Hackers Choice's repository to ensure consistent behavior.

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
