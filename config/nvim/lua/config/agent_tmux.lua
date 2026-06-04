local M = {}

local DEFAULT_SELECTION_PROMPT = "Please review this code and help me with it."
local DEFAULT_FILE_PROMPT = "Please review this file and help me with it."
local DEFAULT_DIAGNOSTICS_PROMPT = "Please help me fix these diagnostics."

local function get_filetype()
	local ft = vim.bo.filetype
	if ft == "" then
		ft = "text"
	end
	return ft
end

local function get_current_file()
	local file = vim.fn.expand("%:.")
	if file == "" then
		file = "[No file]"
	end
	return file
end

local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_line, start_col = start_pos[2], start_pos[3]
	local end_line, end_col = end_pos[2], end_pos[3]

	if start_line == 0 or end_line == 0 then
		return nil
	end

	if start_line > end_line or (start_line == end_line and start_col > end_col) then
		start_line, end_line = end_line, start_line
		start_col, end_col = end_col, start_col
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	if #lines == 0 then
		return nil
	end

	lines[1] = string.sub(lines[1], start_col)
	if #lines == 1 then
		lines[1] = string.sub(lines[1], 1, end_col - start_col + 1)
	else
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	return {
		text = table.concat(lines, "\n"),
		start_line = start_line,
		end_line = end_line,
	}
end

local function get_current_file_text()
	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

local function format_diagnostics()
	local diagnostics = vim.diagnostic.get(0)
	if #diagnostics == 0 then
		return nil
	end

	table.sort(diagnostics, function(a, b)
		if a.lnum == b.lnum then
			return a.col < b.col
		end
		return a.lnum < b.lnum
	end)

	local severity_names = {
		[vim.diagnostic.severity.ERROR] = "ERROR",
		[vim.diagnostic.severity.WARN] = "WARN",
		[vim.diagnostic.severity.INFO] = "INFO",
		[vim.diagnostic.severity.HINT] = "HINT",
	}

	local lines = {}
	for _, diagnostic in ipairs(diagnostics) do
		local severity = severity_names[diagnostic.severity] or "UNKNOWN"
		local location = string.format("%s:%d:%d", get_current_file(), diagnostic.lnum + 1, diagnostic.col + 1)
		local source = diagnostic.source and (" source=" .. diagnostic.source) or ""
		local code = diagnostic.code and (" code=" .. tostring(diagnostic.code)) or ""
		local message = diagnostic.message:gsub("\n", " ")
		table.insert(lines, string.format("- [%s] %s%s%s\n  %s", severity, location, source, code, message))
	end

	return table.concat(lines, "\n")
end

local function in_tmux()
	return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function tmux_panes()
	if not in_tmux() then
		return {}
	end

	local format = table.concat({
		"#{pane_id}",
		"#{session_name}:#{window_index}.#{pane_index}",
		"#{window_name}",
		"#{pane_current_command}",
		"#{pane_title}",
		"#{pane_current_path}",
	}, "\t")

	-- -a lists all panes in the current tmux session, including other windows.
	local output = vim.fn.system({ "tmux", "list-panes", "-a", "-F", format })
	if vim.v.shell_error ~= 0 then
		return {}
	end

	local panes = {}
	for line in output:gmatch("[^\r\n]+") do
		local fields = vim.split(line, "\t", { plain = true })
		local pane = {
			id = fields[1] or "",
			location = fields[2] or "",
			window = fields[3] or "",
			command = fields[4] or "",
			title = fields[5] or "",
			path = fields[6] or "",
		}
		pane.label = string.format(
			"%s  %s  window=%s  command=%s  title=%s",
			pane.id,
			pane.location,
			pane.window,
			pane.command,
			pane.title
		)
		table.insert(panes, pane)
	end

	return panes
end

local function claude_candidates()
	local candidates = {}
	for _, pane in ipairs(tmux_panes()) do
		local haystack = table.concat({ pane.command, pane.title, pane.window }, " "):lower()
		if haystack:find("claude", 1, true) then
			table.insert(candidates, pane)
		end
	end
	return candidates
end

local function open_prompt_composer(opts, on_submit)
	opts = opts or {}
	local default_text = opts.default or ""
	local title = opts.title or " Claude prompt "

	local width = math.min(math.floor(vim.o.columns * 0.7), 90)
	local height = math.min(math.floor(vim.o.lines * 0.35), 12)
	width = math.max(width, 50)
	height = math.max(height, 6)

	local row = math.floor((vim.o.lines - height) / 2) - 1
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local lines = vim.split(default_text, "\n", { plain = true })
	if #lines == 0 then
		lines = { "" }
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "markdown"

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
		footer = " <C-s>: send  |  q: cancel  |  Enter: newline ",
		footer_pos = "center",
		width = width,
		height = height,
		row = row,
		col = col,
	})

	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].cursorline = true

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function submit()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
		close()
		on_submit(vim.trim(text))
	end

	local function cancel()
		close()
		vim.notify("Claude prompt cancelled", vim.log.levels.WARN)
	end

	local map_opts = { buffer = buf, silent = true, nowait = true }
	vim.keymap.set({ "n", "i" }, "<C-s>", submit, map_opts)
	vim.keymap.set("n", "<CR>", submit, map_opts)
	vim.keymap.set("n", "q", cancel, map_opts)
	vim.keymap.set("n", "<Esc>", cancel, map_opts)
	vim.keymap.set("i", "<C-c>", cancel, map_opts)

	vim.schedule(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_current_win(win)
			vim.cmd("startinsert!")
		end
	end)
end

local function send_to_tmux(text, target)
	if not in_tmux() then
		vim.notify("Not inside tmux", vim.log.levels.ERROR)
		return false
	end

	target = target or "!"

	local load_result = vim.fn.system({ "tmux", "load-buffer", "-" }, text)
	if vim.v.shell_error ~= 0 then
		vim.notify("tmux load-buffer failed: " .. load_result, vim.log.levels.ERROR)
		return false
	end

	local paste_result = vim.fn.system({ "tmux", "paste-buffer", "-t", target })
	if vim.v.shell_error ~= 0 then
		vim.notify("tmux paste-buffer failed: " .. paste_result, vim.log.levels.ERROR)
		return false
	end

	local enter_result = vim.fn.system({ "tmux", "send-keys", "-t", target, "Enter" })
	if vim.v.shell_error ~= 0 then
		vim.notify("tmux send-keys failed: " .. enter_result, vim.log.levels.ERROR)
		return false
	end

	return true
end

local function with_claude_target(callback)
	if vim.g.claude_tmux_target ~= nil and vim.g.claude_tmux_target ~= "" then
		callback(vim.g.claude_tmux_target)
		return
	end

	local candidates = claude_candidates()

	if #candidates == 1 then
		vim.g.claude_tmux_target = candidates[1].id
		vim.notify("Auto-detected Claude Code tmux pane: " .. candidates[1].label, vim.log.levels.INFO)
		callback(candidates[1].id)
		return
	end

	if #candidates > 1 then
		vim.ui.select(candidates, {
			prompt = "Select Claude Code tmux pane:",
			format_item = function(item)
				return item.label
			end,
		}, function(choice)
			if not choice then
				vim.notify("Claude target selection cancelled", vim.log.levels.WARN)
				return
			end
			vim.g.claude_tmux_target = choice.id
			callback(choice.id)
		end)
		return
	end

	vim.notify("No Claude pane auto-detected; falling back to previous tmux pane (!)", vim.log.levels.WARN)
	callback("!")
end

local function compose_and_send(opts)
	open_prompt_composer({
		title = opts.title or " Claude Code prompt ",
		default = opts.default_prompt or DEFAULT_SELECTION_PROMPT,
	}, function(instruction)
		if instruction == "" then
			instruction = opts.default_prompt or DEFAULT_SELECTION_PROMPT
		end

		local message = table.concat({
			instruction,
			"",
			opts.context,
		}, "\n")

		with_claude_target(function(target)
			if send_to_tmux(message, target) then
				vim.notify((opts.success_message or "Sent context to Claude Code tmux pane ") .. target, vim.log.levels.INFO)
			end
		end)
	end)
end

function M.pick_claude_target()
	local panes = tmux_panes()
	if #panes == 0 then
		vim.notify("No tmux panes found", vim.log.levels.ERROR)
		return
	end

	vim.ui.select(panes, {
		prompt = "Select Claude Code tmux target:",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			vim.notify("Claude target selection cancelled", vim.log.levels.WARN)
			return
		end
		vim.g.claude_tmux_target = choice.id
		vim.notify("Claude tmux target set to " .. choice.label, vim.log.levels.INFO)
	end)
end

function M.clear_claude_target()
	vim.g.claude_tmux_target = nil
	vim.notify("Cleared Claude tmux target", vim.log.levels.INFO)
end

function M.send_selection_to_claude()
	local selection = get_visual_selection()
	if selection == nil or selection.text == "" then
		vim.notify("No visual selection found", vim.log.levels.WARN)
		return
	end

	local context = table.concat({
		"File: " .. get_current_file(),
		"Lines: " .. selection.start_line .. "-" .. selection.end_line,
		"Filetype: " .. get_filetype(),
		"",
		"```" .. get_filetype(),
		selection.text,
		"```",
	}, "\n")

	compose_and_send({
		default_prompt = DEFAULT_SELECTION_PROMPT,
		context = context,
		success_message = "Sent selection to Claude Code tmux pane ",
	})
end

function M.send_file_to_claude()
	local file_text = get_current_file_text()
	if file_text == "" then
		vim.notify("Current buffer is empty", vim.log.levels.WARN)
		return
	end

	local context = table.concat({
		"File: " .. get_current_file(),
		"Lines: 1-" .. vim.api.nvim_buf_line_count(0),
		"Filetype: " .. get_filetype(),
		"",
		"```" .. get_filetype(),
		file_text,
		"```",
	}, "\n")

	compose_and_send({
		default_prompt = DEFAULT_FILE_PROMPT,
		context = context,
		success_message = "Sent current file to Claude Code tmux pane ",
	})
end

function M.send_diagnostics_to_claude()
	local diagnostics = format_diagnostics()
	if diagnostics == nil or diagnostics == "" then
		vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
		return
	end

	local context = table.concat({
		"File: " .. get_current_file(),
		"Filetype: " .. get_filetype(),
		"",
		"Diagnostics:",
		diagnostics,
	}, "\n")

	compose_and_send({
		default_prompt = DEFAULT_DIAGNOSTICS_PROMPT,
		context = context,
		success_message = "Sent diagnostics to Claude Code tmux pane ",
	})
end

vim.api.nvim_create_user_command("ClaudeSendSelection", function()
	M.send_selection_to_claude()
end, { desc = "Send visual selection to Claude Code in tmux" })

vim.api.nvim_create_user_command("ClaudeSendFile", function()
	M.send_file_to_claude()
end, { desc = "Send current file to Claude Code in tmux" })

vim.api.nvim_create_user_command("ClaudeSendDiagnostics", function()
	M.send_diagnostics_to_claude()
end, { desc = "Send current buffer diagnostics to Claude Code in tmux" })

vim.api.nvim_create_user_command("ClaudePickTarget", function()
	M.pick_claude_target()
end, { desc = "Pick Claude Code tmux target pane" })

vim.api.nvim_create_user_command("ClaudeClearTarget", function()
	M.clear_claude_target()
end, { desc = "Clear stored Claude Code tmux target pane" })

return M
