Color = {
	RESET = "\27[0m",

	BLACK = "\27[30m",
	GRAY = "\27[90m",
	RED = "\27[31m",
	GREEN = "\27[32m",
	YELLOW = "\27[33m",
	BLUE = "\27[34m",
	MAGENTA = "\27[35m",
	CYAN = "\27[36m",
	WHITE = "\27[37m",

	BG_RED = "\27[41m",
	BG_GREEN = "\27[42m",
	BG_BLUE = "\27[44m"
}

_printed_lines = 0
function print_e(s, newline)
	-- print borrable, cuenta las lineas
	newline = newline or (newline == nil)
	s = (s or "") .. (newline and "\n" or "")
	io.write(s)

	s:gsub("\n", function() _printed_lines = _printed_lines + 1 end)
end

function print_l(s)
	-- io.write("\27[2K")
	io.write("\27[0G")
	io.write(s)
	-- sobreescribe lo que hay en la linea
end

function reset_output()
	_printed_lines = 0
end

function clear_output()
	for _ = 0, _printed_lines do
		io.write("\27[1A")
	end

	io.write("\27[0J")
	_printed_lines = 0
end

function with_color(text, color)
	return color .. text .. Color.RESET
end
