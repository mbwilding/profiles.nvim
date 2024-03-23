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
				local selection = action_state.get_selected_entry()
				local profile = selection.value

				-- print("Executing profile: " .. profile.profile_name)

				-- for key, value in pairs(profile.environment_vars) do
				-- 	print("K: " .. key .. " | " .. "V: " .. value)
				-- end

				-- for _, cmd in ipairs(profile.commands) do
				-- 	local output = vim.fn.system(cmd)
				-- 	if vim.v.shell_error ~= 0 then
				-- 		print("Error executing command: " .. cmd)
				-- 	elseif profile.print == nil or profile.print == true then
				-- 		print("Command output: " .. output)
				-- 	end
				-- end

				M.create_terminals(profile)

				actions.close(prompt_bufnr)
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
	for i, command in ipairs(profile.commands) do
		toggleterm.exec(
			command,
			i,
			40,
			vim.fn.getcwd():gsub("\\", "/"),
			"tab",
			"Term" .. i,
			true,
			true
		)
	end
end

return M
