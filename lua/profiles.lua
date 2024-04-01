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
	local cwd = vim.fn.getcwd()
	local nvim_dir = Path:new(cwd .. "/.nvim")

	if not nvim_dir:exists() then
		print("'/.nvim/' not found in the working directory")
		return
	end

	local lua_files = scan.scan_dir(nvim_dir:absolute(), {
		hidden = false,
		depth = 1,
		search_pattern = "%.lua$",
	})

	local profiles = {}
	for _, file_path in ipairs(lua_files) do
		local name = vim.fn.fnamemodify(file_path, ":t:r")
		local content = dofile(file_path)
		if content ~= nil then
			table.insert(profiles, {
				name = name,
				content = content,
			})
		end
	end

	if #profiles == 0 then
		print("No profiles found in '/.nvim/'")
		return
	end

	M.pick_profiles(profiles)
end

function M.select_default_profile()
	local project_types = M.check_project_types()
	local profiles = {}

	for project_type, _ in pairs(project_types) do
		local language = require("languages/" .. project_type)

		if language ~= nil then
			for name, content in pairs(language) do
				table.insert(profiles, {
					name = name .. " (" .. project_type:upper() .. ")",
					content = content,
				})
			end
		end
	end

	if #profiles == 0 then
		print("No default profiles found for the current project")
		return
	end

	M.pick_profiles(profiles)
end

function M.pick_profiles(contents)
	pickers
		.new({}, {
			prompt_title = "Search for a profile to execute",
			results_title = "Profiles",
			finder = finders.new_table({
				results = contents,
				entry_maker = function(entry)
					return {
						value = entry.content,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)

					local selection = action_state.get_selected_entry()
					local profile = selection.value

					M.create_terminals(profile)
					M.run_applications(profile)
				end)

				return true
			end,
			layout_config = {
				width = 0.4,
				height = 0.6,
			},
		})
		:find()
end

function M.create_terminals(profile)
	local env_cmd = ""
	local is_windows = vim.fn.has("win32") == 1

	if profile.environment_vars ~= nil then
		for key, value in pairs(profile.environment_vars) do
			if is_windows then
				env_cmd = env_cmd .. "$env:" .. key .. ' = "' .. value .. '"; '
			else
				env_cmd = env_cmd .. "export " .. key .. '="' .. value .. '"; '
			end
		end
	end

	for terminal, commands in pairs(profile.terminal_commands) do
		local concatenated_commands = ""
		for _, command in ipairs(commands) do
			concatenated_commands = concatenated_commands .. command .. ";"
		end

		toggleterm.exec(
			env_cmd .. concatenated_commands,
			terminal,
			0,
			vim.fn.getcwd():gsub("\\", "/"),
			"horizontal",
			"Term" .. terminal,
			true,
			true
		)
	end
end

function M.run_applications(profile)
	if profile.os_commands ~= nil then
		for _, command in ipairs(profile.os_commands) do
			M.exec_silent(command)
		end
	end
end

function M.exec_silent(command)
	local p = assert(io.popen(command))
	local result = p:read("*all")
	p:close()
	return result
end

function M.check_project_types()
	local uv = vim.loop

	local project_types = {}

	local cwd = uv.cwd() or ""

	local files_to_check = {
		["Cargo.toml"] = "rust",
	}

	local patterns_to_check = {
		[".*%.sln$"] = "csharp",
		[".*%.csproj$"] = "csharp",
	}

	for file, project_type in pairs(files_to_check) do
		local full_path = cwd .. "/" .. file

		if uv.fs_stat(full_path) then
			project_types[project_type] = true
		end
	end

	for pattern, project_type in pairs(patterns_to_check) do
		local scan_result = uv.fs_scandir(cwd)
		if not scan_result then
			goto continue
		end

		for entry in
			function()
				return uv.fs_scandir_next(scan_result)
			end
		do
			if entry:match(pattern) then
				project_types[project_type] = true
				break
			end
		end

		::continue::
	end

	return project_types
end

return M
