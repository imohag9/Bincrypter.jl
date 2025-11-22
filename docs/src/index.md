```@meta
CurrentModule = Bincrypter
```

# Bincrypter

Documentation for [Bincrypter](https://github.com/imohag9/Bincrypter.jl).

# Usage Guide 

This guide demonstrates how to use `Bincrypter.jl` to encrypt, obfuscate, and manage your executable files and scripts.

## Installation

First, install the package using Julia's package manager:

```julia
using Pkg
Pkg.add("Bincrypter")
```

The `bincrypter.sh` script is automatically downloaded and configured when the `Bincrypter` module is first loaded, so no manual setup for the external tool is required.

## Basic Usage

The primary function is `Bincrypter.bincrypter(input_file::AbstractString; <kwargs>)`. It takes the path to your script or binary as the first argument, and various keyword arguments to control `bincrypter.sh`'s behavior.

Let's assume you have a simple shell script named `my_script.sh`:

```bash
#!/bin/bash
echo "Hello from my script!"
```

### Obfuscating a Script

To obfuscate a script without password protection, simply call `bincrypter` with the file path. The original file will be overwritten with its obfuscated version.

```julia
using Bincrypter

script_path = "my_script.sh"
# Ensure the script exists and is executable for this example
# (In a real scenario, you'd have your actual script here)
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'Hello from my script!'")
end
chmod(script_path, 0o755)

println("--- Before obfuscation ---")
run(`cat $script_path`)

bincrypter(script_path)

println("\n--- After obfuscation ---")
# The output will look different, but the script remains functional.
run(`cat $script_path`)
run(`bash $script_path`) # It should still run and print "Hello from my script!"

rm(script_path) # Clean up
```

### Encrypting with a Password

To encrypt a script with a password, use the `password` keyword argument. When the encrypted script is executed, it will prompt the user for this password.

```julia
using Bincrypter

script_path = "my_secret_script.sh"
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'Top secret information!'")
end
chmod(script_path, 0o755)

bincrypter(script_path; password="MySuperSecretPassword")

println("`my_secret_script.sh` has been encrypted. Try running it from your terminal:")
println("bash $(script_path)")
println("You will be prompted for the password 'MySuperSecretPassword'.")

rm(script_path)
```

### Locking to the Current System

The `lock=true` option ties the encrypted binary to the current system's ID and user ID. This is useful for distributing binaries that should only run on a specific machine. Note that when `lock=true`, any `password` argument is ignored by `bincrypter.sh`.

```julia
using Bincrypter

script_path = "my_locked_binary.sh"
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'This script is locked to this machine!'")
end
chmod(script_path, 0o755)

bincrypter(script_path; lock=true)

println("`my_locked_binary.sh` has been locked to this system. It will only run here.")
println("If you try to run it on another machine, it will likely fail.")

rm(script_path)
```

### Quiet Mode

To suppress the console output from the `bincrypter.sh` tool itself (e.g., download progress, success messages), use `quiet=true`.

```julia
using Bincrypter

script_path = "quiet_script.sh"
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'Quietly processed!'")
end
chmod(script_path, 0o755)

println("Processing `quiet_script.sh` quietly...")
bincrypter(script_path; quiet=true)
println("Done.")

rm(script_path)
```

### Custom Environment Variables

`bincrypter.sh` supports certain behaviors configurable via environment variables (e.g., `BC_PADDING`). You can pass these via the `env` keyword argument as a `Dict{String, String}`.

```julia
using Bincrypter

script_path = "nopadding_script.sh"
open(script_path, "w") do f
    write(f, "#!/bin/bash\necho 'No padding used!'")
end
chmod(script_path, 0o755)

# Obfuscate with BC_PADDING=0 to create a potentially smaller output file
bincrypter(script_path; env=Dict("BC_PADDING" => "0"))
println("`nopadding_script.sh` processed with BC_PADDING=0.")

rm(script_path)
```

## Security Considerations

*   **Password Visibility**: When `password` is provided, it is passed as a command-line argument to the underlying `bincrypter.sh` script. This means the password might be visible in process lists (e.g., `ps aux`) on the system for a short period. Exercise caution with sensitive information.
*   **In-Place Modification**: The `bincrypter.sh` tool, and consequently this wrapper, modifies the input file *in place*. Always ensure you have backups of your original scripts/binaries before using this tool.
*   **External Tool Source**: `Bincrypter.jl` relies on the `bincrypter.sh` script. While it's pinned to a specific commit for stability, ensure you trust the upstream source if you are dealing with sensitive operations.

For a detailed list of functions and their parameters, please refer to the API Reference.