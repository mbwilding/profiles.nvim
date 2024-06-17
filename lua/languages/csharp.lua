return {
	Run = {
		terminal_commands = {
			[1] = {
				"dotnet run",
			},
		},
	},
	Build = {
		terminal_commands = {
			[1] = {
				"dotnet build",
			},
		},
	},
	Restore = {
		terminal_commands = {
			[1] = {
				"dotnet restore",
			},
		},
	},
	Test = {
		terminal_commands = {
			[1] = {
				"dotnet test",
			},
		},
	},
	Upgrade = {
		terminal_commands = {
			[1] = {
				[[
                update_packages() {
                    project_file=$1

                    echo "Updating packages for $project_file..."

                    # Get a list of outdated packages and their current versions
                    outdated_packages=$(dotnet list $project_file package --outdated | awk '/>/{print $2}')

                    # Check if there are any outdated packages
                    if [ -z "$outdated_packages" ]; then
                        echo "No outdated packages found in $project_file."
                        return
                    fi

                    for package in $outdated_packages; do
                        echo "Updating $package..."

                        # Update the package to the latest version
                        dotnet add $project_file package $package
                    done
                }

                # Find all .csproj files in the current directory and subdirectories
                project_files=$(find . -name "*.csproj")

                for project_file in $project_files; do
                    update_packages "$project_file"
                done

                echo "All outdated packages have been updated."
                ]],
			},
		},
	},
}
