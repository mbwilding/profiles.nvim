local M = {}

local Path = require("plenary.path")
local scan = require("plenary.scandir")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local toggleterm = require("toggleterm")

function M.select_profile()
	local profiles = M.find_profiles()
	M.pick_profiles(profiles)
end

function M.find_profiles()
	local cwd = vim.fn.getcwd()
	local nvim_dir = Path:new(cwd .. "/.nvim")
	if nvim_dir:exists() then
		local lua_files = scan.scan_dir(nvim_dir:absolute(), {
			hidden = false,
			depth = 1,
			search_pattern = "%.lua$",
		})

		local profiles = {}
		for _, file_path in ipairs(lua_files) do
			local content = dofile(file_path)
			if content.profile_name ~= nil then
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
		prompt_title = "Pick a profile to execute",
		results_title = "Profiles",
		finder = finders.new_table({
			results = contents,
			entry_maker = function(profile)
				return {
					value = profile,
					display = profile.profile_name,
					ordinal = profile.profile_name,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)

				local selection = action_state.get_selected_entry()
				local profile = selection.value

				print("Executing profile: " .. profile.profile_name)

				M.create_terminals(profile)
				M.run_applications(profile)
			end)

			return true
		end,
		layout_config = {
			width = 0.4,
			height = 0.6,
		},
	}):find()
end

function M.create_terminals(profile)
	local env_cmd = ""
	local is_windows = vim.fn.has("win32") == 1

	for key, value in pairs(profile.environment_vars) do
		if is_windows then
			env_cmd = env_cmd .. "$env:" .. key .. " = \"" .. value .. "\"; "
		else
			env_cmd = env_cmd .. "export " .. key .. "=\"" .. value .. "\"; "
		end
	end
end

function M.run_applications(profile)
	for _, command in ipairs(profile.applications) do
		os.execute(command)
	end
end

return M
