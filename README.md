# profiles.nvim

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
        vim.keymap.set("n", "<leader>p", function()
            profiles.select_profile()
        end, { desc = "Profiles: Select" })
    end,
}
```

## Example

Here is an example profile in the `.nvim` in the current working directory: `/.nvim/Example.lua`

For example, this will show as `Example` in the `Profiles` list in Telescope.

```lua
return {
    -- Terminal commands will open in ToggleTerm
    -- Each command will increment the terminal number in which it runs in
    terminal_commands = {
        "dotnet build",
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
