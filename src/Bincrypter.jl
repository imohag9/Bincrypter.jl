module Bincrypter

export bincrypter


using Pkg.Artifacts
using Downloads

"""
The download_script function is called automatically when the module is loaded.
We use it to check for the existence of the `bincrypter` script.
"""
function download_script()
    artifact_name = "bincrypter_artifact"
    artifacts_toml = joinpath(dirname(@__DIR__), "Artifacts.toml")
    hash = artifact_hash(artifact_name, artifacts_toml)
    if isnothing(hash) || !artifact_exists(hash)
        hash = create_artifact() do artifact_dir
            println("Downloading files to $artifact_dir...")

            bincrypter_url = "https://github.com/hackerschoice/bincrypter/releases/download/v1.1/bincrypter"

            bincrypter_path = joinpath(artifact_dir, "bincrypter")
            println("Downloading $bincrypter_url to $bincrypter_path...")
            try
                Downloads.download(bincrypter_url, bincrypter_path)
                chmod(bincrypter_path, 0o755)
            catch e
                println("Error installing bincrypter script: $e")
                BINCRYPTER_PATH[] = nothing
            end
        end

        bind_artifact!(
            artifacts_toml,
            artifact_name,
            hash,
            force = true
        )
    end
    return joinpath(artifact_path(hash), "bincrypter")
end

const BINCRYPTER_PATH = Ref{Union{String, Nothing}}(nothing)
BINCRYPTER_PATH[] = download_script()

"""
    bincrypter(input_file::AbstractString; <kwargs>)

Encrypts or obfuscates a binary or script using the `bincrypter` command-line tool.

This function serves as a Julia wrapper, operating on a specified input file path.

# Arguments
- `input_file`: The path to the source file (`String`) to be processed by `bincrypter.sh`.
              The `bincrypter.sh` tool modifies this file in place.

# Keyword Arguments
- `password::Union{AbstractString, Nothing}=nothing`: The password for encryption. If `nothing`, the input will be obfuscated without password protection.
- `quiet::Bool=false`: If `true`, suppresses all console output from the `bincrypter` script (corresponds to the `-q` flag).
- `lock::Bool=false`: If `true`, locks the resulting binary to the current system and user ID (corresponds to the `-l` flag).
- `env::Union{Dict{String, String}, Nothing}=nothing`: A dictionary of environment variables to set for the `bincrypter.sh` process.
                                                      For example, `Dict("BC_PADDING" => "0")` to disable padding.

# Security Notes
- **Password Visibility**: When `password` is provided, it is passed as a command-line argument to the underlying `bincrypter.sh` script. This means the password might be visible in process lists (e.g., `ps aux`) on the system for a short period. Exercise caution with sensitive information.

# Examples
```julia
# Encrypt a file with a password
bincrypter("my_script.sh"; password="secret")

# Obfuscate a script
bincrypter("my_script.sh")

# Lock a script to the current system
bincrypter("my_important_script.sh"; lock=true)

# Obfuscate with a custom environment variable (e.g., disable padding)
bincrypter("my_script.sh"; env=Dict("BC_PADDING" => "0"))
```
"""
function bincrypter(
        input_file::AbstractString; # Renamed from `input` for clarity, now only AbstractString
        password::Union{AbstractString, Nothing} = nothing,
        quiet::Bool = false,
        lock::Bool = false,
        env::Union{Dict{String, String}, Nothing} = nothing)
    if isnothing(BINCRYPTER_PATH[])
        error("`bincrypter` executable not found. Please follow the installation instructions in the README.")
    end

    # --- Command-line arguments ---
    # As per Julia documentation, it's robust to build the command as an array of strings.
    # The first element is the executable, followed by each argument.
    cmd_array = [BINCRYPTER_PATH[]]

    if lock && !isnothing(password)
        @warn "The `password` argument is ignored when `lock=true`, as per bincrypter's behavior."
    end

    !isfile(input_file) &&
        error("Input file not found or is not a regular file: \"$input_file\"")
    push!(cmd_array, abspath(input_file))

    # The password, if provided
    !isnothing(password) && !lock && push!(cmd_array, password)
    lock && push!(cmd_array, "-l")
    quiet && push!(cmd_array, "-q")
    base_cmd = Cmd(cmd_array)
    # Construct the command with environment variables if provided
    bincrypter_cmd = if isnothing(env)
        base_cmd # No environment variables to add, use the base command
    else
        Base.setenv(base_cmd, env)
    end

    proc_pipeline = pipeline(bincrypter_cmd; stdout = stdout, stderr = stderr)

    try
        run(proc_pipeline)

    catch e
        if e isa ProcessFailedException
            error("The `bincrypter` command failed with an exit code. Please check the error output above for details.")
        else
            rethrow()
        end
    end

    return nothing
end

export bincrypter

end # module Bincrypter
