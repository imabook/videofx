require "globals"
require "menu.menu"
require "menu.utils"
require "edit.edit"
require "edit.commands"

::start::

local file_data = nil
repeat
	print_menu({ "mp4", "mov" })
	print_e()
	print_e("elige un video: ", false)

	local video = select_file(tonumber(io.read()) or 1)
	if video then
		file_data = get_videodata(video.name)
	end
until file_data

local exists = print_video_data(file_data)
local ans = io.read():lower() == "y"

if ans then
	-- borrar frames anteriores (si existen)
	-- procesar frames
	extract_frames(file_data.filename)
	reset_output()
elseif not exists then
	goto start -- es mala practica pero bueno
end

for f, _ in lfs.dir(VIDEO_PATH .. "/" .. VIDEO:match("^(.*)%.") .. "/") do
	if f:match(".ppm$") then
		VIDEO_FRAMES = VIDEO_FRAMES + 1
	end
end


local dt = nil
repeat
	print_menu({ "fdt" })
	print_e()
	print_e("elige un archivo de frames " .. with_color("(.fdt)", Color.GRAY) .. ": ", false)

	local file = select_file(tonumber(io.read()) or 1)
	if file then
		dt = get_framedata(file.name)

		if (dt) then
			print_e("las dimensiones del dataset son de " ..
				with_color(DT_COLUMNS .. "x" .. DT_ROWS, Color.YELLOW) ..
				with_color(" (las del video son ", Color.GRAY) ..
				with_color(V_COLUMNS .. "x" .. V_ROWS, Color.YELLOW) .. with_color(")", Color.GRAY))
			print_e(
				"continuar y usar? (" ..
				with_color("Y", Color.GREEN) .. "/" .. with_color("n", Color.RED) .. "): ", false)

			-- no es muy bonito pero hay que hacerlo porque como se pide dos veces input del usuario hay una linea extra que no borra
			_printed_lines = _printed_lines + 1
			if io.read():lower() ~= "y" then
				dt:close()
				dt = nil
			end
		end
	end
until dt

clear_output()
if (DT_FRAMES < VIDEO_FRAMES) then
	print_e()
	print_e("el archivo tiene menos frames que el video que se va a procesar " ..
		with_color("(" .. DT_FRAMES .. " vs " .. VIDEO_FRAMES .. ")", Color.YELLOW))
	print_e("no hay ningun problema, solo que se pondra en bucle el .fdt")
	print_e()
end

local interpolation = 1
if (DT_COLUMNS ~= V_COLUMNS or DT_ROWS ~= V_ROWS) then
	interpolation = print_interpolation_menu()

	clear_output()
end


print_e()
print_e("se van a guardar los frames del video en memoria " ..
	with_color("(" .. FRAME_SIZE * VIDEO_FRAMES .. " bytes)", Color.GRAY))
print_e()

save_frames_to_memory()
print_e()

start_pixel_change(dt, interpolation) -- cierra dt automaticamente
local new_name = save_menu()
compile_video(new_name)
