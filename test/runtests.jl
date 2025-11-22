using Bincrypter
using Test
using Aqua



# We only run the tests if the executable is available.
@testset "Bincrypter.jl" begin
    IS_BINCRYPTER_AVAILABLE::Bool = !isnothing(Bincrypter.BINCRYPTER_PATH[])
    if !IS_BINCRYPTER_AVAILABLE
        @warn "`bincrypter` executable not found. Skipping all integration tests."
    end

    if IS_BINCRYPTER_AVAILABLE

        @testset "Code quality (Aqua.jl)" begin
            Aqua.test_all(Bincrypter)
        end

        # --- Test Setup ---
        # Create a temporary directory for test artifacts
        TEST_DIR = mktempdir()
        SCRIPT_NAME = "test_script.sh"
        SCRIPT_PATH = joinpath(TEST_DIR, SCRIPT_NAME)
        SCRIPT_CONTENT = "#!/bin/bash\necho 'Hello from the test script!'"

        try
            # Create a sample executable script to work with
            open(SCRIPT_PATH, "w") do f
                write(f, SCRIPT_CONTENT)
            end
            #chmod(SCRIPT_PATH, 0o755)

            @testset "File Operations" begin

                # 1. Basic obfuscation (file to file)
                bincrypter(SCRIPT_PATH)
                @test isfile(SCRIPT_PATH)
                @test filesize(SCRIPT_PATH) > 0

                # 2. Encryption with a password
                bincrypter(SCRIPT_PATH; password = "MyTestPassword123")
                @test isfile(SCRIPT_PATH)
                @test filesize(SCRIPT_PATH) > 0

                # 3. Locking the binary
                bincrypter(SCRIPT_PATH; lock = true)
                @test isfile(SCRIPT_PATH)
                @test filesize(SCRIPT_PATH) > 0

                # 4. Quiet mode (just ensure it runs without error)
                bincrypter(SCRIPT_PATH; quiet = true)
                @test isfile(SCRIPT_PATH)
                @test filesize(SCRIPT_PATH) > 0
            end

            @testset "Environment Variables" begin
                #create_test_script() # Reset script
                initial_size = filesize(SCRIPT_PATH)

                # Create a version with padding disabled via env var
                env_vars = Dict("BC_PADDING" => "0")
                bincrypter(SCRIPT_PATH; env=env_vars)
                @test isfile(SCRIPT_PATH)
                @test filesize(SCRIPT_PATH) > 0 # Still obfuscated
            end

        finally
            # --- Test Teardown ---
            # Clean up the temporary directory and all its contents
            rm(TEST_DIR, recursive = true, force = true)
        end
    else
        # If the executable is not found, we still want a passing test case
        # to confirm the warning mechanism works.
        @test_skip "Skipping integration tests: `bincrypter` not in PATH."
    end
end
