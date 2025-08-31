local lfs = require("lfs")

local Color = {
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

local _printed_lines = 0
function print_e(s, newline)
	-- print borrable, cuenta las lineas
	newline = newline or (newline == nil)
	s = (s or "") .. (newline and "\n" or "")
	io.write(s)

	s:gsub("\n", function() _printed_lines = _printed_lines + 1 end)
end

local path = lfs.currentdir()
local files = {}

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

function matches_extension(ext, extensions)
	for _, v in ipairs(extensions) do
		if ext == v then return true end
	end
	return false
end

function get_files(extensions)
	files = {}

	for file, _ in lfs.dir(path) do
		file_attr = lfs.attributes(path .. "/" .. file)

		if file_attr.mode == "directory" then
			table.insert(files, { name = file, is_dir = true, size = file_attr.size })
		elseif file_attr.mode == "file" then
			local ext = file:lower():match("%.(.*)$")

			if not extensions or matches_extension(ext, extensions) then
				table.insert(files, { name = file, is_dir = false, size = file_attr.size })
			end
		else
		end
	end

	table.sort(files, function(a, b)
		if a.is_dir and not b.is_dir then
			return true
		elseif not a.is_dir and b.is_dir then
			return false
		else
			return a.name < b.name
		end
	end)
end

function print_menu(extensions)
	clear_output()

	print_e()
	print_e(with_color(path, Color.BG_BLUE))

	get_files(extensions)
	-- if #files == 0 then get_files() end

	for i, file in ipairs(files) do
		if file.is_dir then
			print_e(" " .. i .. ". " .. with_color(file.name, Color.BLUE))
		else
			print_e(
				" " ..
				i .. ". " .. with_color(file.name, Color.CYAN) .. " " .. with_color("(" .. file.size .. " bytes)",
					Color.GRAY))
		end
	end
end

function print_video_data(vd)
	clear_output()

	print_e()
	print_e(with_color(vd.path, Color.BG_BLUE))
	print_e()

	print_e("video seleccionado: " .. with_color(vd.filename, Color.BLUE))
	print_e("propiedades: " .. with_color(vd.width .. "x" .. vd.height .. " - " .. vd.fps .. "fps", Color.CYAN))
	print_e("duracion: " ..
		with_color(vd.frames .. " frames", Color.CYAN) .. with_color(" (" .. vd.duration .. "s)	", Color.GRAY))

	if not lfs.attributes(vd.path .. "/" .. vd.filename:match("^(.*)%.")) then
		-- no se ha procesado el video en frames todavia
		print_e()
		print_e("se necesitan extraer los frames del video")

		local bytes = 9 + tostring(vd.height):len() + tostring(vd.width):len() + 3 * vd.height * vd.width
		print_e("se van a crear " ..
			with_color(vd.frames, Color.YELLOW) ..
			" imagenes de " ..
			with_color(bytes .. " bytes ",
				Color.YELLOW) .. with_color("(total de " .. vd.frames * bytes .. " bytes)", Color.GRAY))

		print_e(
			"continuar y crear archivos? (" .. with_color("Y", Color.GREEN) .. "/" .. with_color("n", Color.RED) .. "): ",
			false)

		return false -- no existe el directorio
	else
		print_e()
		print_e("parece que ya se han extraido los frames")
		print_e("se pueden usar los que ya estan o reextraerlos")

		local bytes = 9 + tostring(vd.height):len() + tostring(vd.width):len() + 3 * vd.height * vd.width
		print_e("si se reextrae se crearan " ..
			with_color(vd.frames, Color.YELLOW) ..
			" imagenes de " ..
			with_color(bytes .. " bytes ",
				Color.YELLOW) .. with_color("(total de " .. vd.frames * bytes .. " bytes)", Color.GRAY))

		print_e(
			"reextraer frames del video? (" .. with_color("Y", Color.GREEN) .. "/" .. with_color("n", Color.RED) .. "): ",
			false)

		return true -- existe el directorio
	end
end

function select_file(index)
	if index <= 0 or index > #files then
		return
	end

	if files[index].is_dir then
		lfs.chdir(path .. "/" .. files[index].name)
		path = lfs.currentdir()
	else
		return files[index]
	end

	return nil
end
