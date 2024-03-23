local M = {}

local Path = require('plenary.path')
local scan = require('plenary.scandir')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')

function M.select_profile()
	local profiles = M.find_profiles()
	M.pick_profiles(profiles)
end

function M.find_profiles()
	local cwd = vim.fn.getcwd()
	local nvim_dir = Path:new(cwd .. '/.nvim')
	if nvim_dir:exists() then
		local lua_files = scan.scan_dir(nvim_dir:absolute(), {
			hidden = false,
			only_dirs = false,
			depth = 1,
			search_pattern = "%.lua$",
		})

		local profiles = {}
		for _, file_path in ipairs(lua_files) do
			local content = dofile(file_path)
			if content.name ~= nil then
				table.insert(profiles, content)
			end
		end

		return profiles
	else
		print(".nvim directory not found in the root.")
	end
end

function M.pick_profiles(contents)
	pickers.new({}, {
		prompt_title = "Profiles",
		finder = finders.new_table({
			results = contents,
			entry_maker = function(profile)
				return {
					value = profile,
					display = profile.name,
					ordinal = profile.name,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local profile = selection.value
				print("Executing profile: " .. profile.name)
				for _, cmd in ipairs(profile.commands) do
					local output = vim.fn.system(cmd)
					if vim.v.shell_error ~= 0 then
						print("Error executing command: " .. cmd)
					else
						print("Command output: " .. output)
					end
				end
			end)

			return true
		end,
	}):find()
end

return M
