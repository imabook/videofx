require "globals"
require "menu.utils"
require "menu.custom_print"


function print_menu(extensions)
	clear_output()

	print_e()
	print_e(with_color(lfs.currentdir(), Color.BG_BLUE))

	local files = get_files(extensions)
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

	local bytes = 9 + tostring(vd.height):len() + tostring(vd.width):len() + 3 * vd.height * vd.width
	FRAME_SIZE = bytes
	VIDEO_SIZE = bytes * vd.frames


	if not lfs.attributes(vd.path .. "/" .. vd.filename:match("^(.*)%.")) then
		-- no se ha procesado el video en frames todavia
		print_e()
		print_e("se necesitan extraer los frames del video")

		print_e("se van a crear " ..
			with_color(vd.frames, Color.YELLOW) ..
			" imagenes de " ..
			with_color(bytes .. " bytes ",
				Color.YELLOW) .. with_color("(total de " .. VIDEO_SIZE .. " bytes)", Color.GRAY))

		print_e(
			"continuar y crear archivos? (" .. with_color("Y", Color.GREEN) .. "/" .. with_color("n", Color.RED) .. "): ",
			false)

		return false -- no existe el directorio
	else
		print_e()
		print_e("parece que ya se han extraido los frames")
		print_e("se pueden usar los que ya estan o reextraerlos")

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

function print_interpolation_menu()
	local selection = nil
	repeat
		-- clear_output()

		print_e()
		print_e("el video y el dataset tienen diferentes dimensiones")
		print_e("se necesita especificar el algoritmo de interpolacion para convertir las coordenadas:")
		print_e()
		print_e("1. " .. with_color("floor interpolation", Color.CYAN))
		print_e("2. " .. with_color("nearest neighbour", Color.CYAN))
		print_e("3. " .. with_color("bilinear interpolation", Color.CYAN))
		print_e("4. " .. with_color("random interpolation", Color.CYAN))

		print_e()
		print_e("elige un metodo de interpolacion: ", false)
		selection = tonumber(io.read()) or 0
		if selection < 1 or selection > 4 then
			clear_output()
			selection = nil
		end
	until selection

	return selection
end

function save_menu()
	print_e()
	print_e("se han editado correctamente los frames")
	print_e("con que nombre quieres guardar el video: ", false)
	return io.read()
end
