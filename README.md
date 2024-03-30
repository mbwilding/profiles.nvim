# profiles.nvim

This plugin allows you to easily access commands that you want to run for the project at hand.

Be it builds, tests, running the project, or whatever.

## Lazy setup

```lua
return {
    "mbwilding/profiles.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "akinsho/nvim-toggleterm.lua"
    },
    config = function()
        local profiles = require("profiles")

        -- Select from your profiles in '.nvim'
        vim.keymap.set("n", "<leader>p", function()
            profiles.select_profile()
        end, { desc = "Profiles: Select Local" })

        -- Select from generic profiles (tailored via file patterns)
        vim.keymap.set("n", "<leader>P", function()
            profiles.select_default_profile()
        end, { desc = "Profiles: Select Default" })
    end,
}
```

## Example

Here is an example profile in the `.nvim` directory sitting in the current working directory: `.nvim/Example.lua`

For example, this will show as `Example` in the `Profiles` list in Telescope.

```lua
return {
    -- Terminal commands will open in ToggleTerm
    -- Specify which terminal will run what set of commands
    terminal_commands = {
        [1] = {
            "dotnet restore",
            "dotnet build",
        },
        [2] = {
            "echo 'Hello, World!'"
        }
    },
    -- OS commands will open a program
    -- For example, a web page if you are spinning up an API
    os_commands = {
        "calc.exe",
        "notepad.exe"
    },
    -- Environment Variables
    -- This will set the environment vars prior to running the commands
    environment_vars = {
        ["THIS_IS_THE_KEY"] = "This is the value",
        ["THIS_IS_ALSO_A_KEY"] = "This is also a value",
    }
}
```
