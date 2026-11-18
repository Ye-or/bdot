local M = {}

local function supports_kitty()
	local term = os.getenv("TERM") or ""
	local term_program = os.getenv("TERM_PROGRAM") or ""

	if os.getenv("KITTY_WINDOW_ID") ~= nil then
		return true
	end

	if term:find("kitty") or term:find("ghostty") or term:find("wezterm") then
		return true
	end

	if term_program == "WezTerm" or term_program == "ghostty" or term_program == "Konsole" then
		return true
	end

	return false
end

function M:peek(job)
	if supports_kitty() then
		require("image"):peek(job)
		return
	end

	local output, err = Command("chafa"):arg({
		"--probe=off",
		"--format=symbols",
		"--size=" .. job.area.w .. "x" .. job.area.h,
		tostring(job.file.url),
	}):output()

	if output and output.status.success then
		ya.preview_widget(job, ui.Text.parse(output.stdout):area(job.area))
	else
		ya.err("Chafa error: " .. tostring(err or (output and output.stderr)))
	end
end

function M:seek(job)
	if supports_kitty() then
		require("image"):seek(job)
	end
end

return M
