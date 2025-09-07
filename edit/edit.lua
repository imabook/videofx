require "globals"
require "menu.custom_print"

local ALGORITHMS = require "edit.algorithms"

function get_framedata(file)
	local dt = io.open(file, "rb")
	if not dt then return nil end

	local buff = dt:read(2)
	DT_COLUMNS = math.floor(buff:byte(2) * 2 ^ 8 + buff:byte(1))

	buff = dt:read(2)
	DT_ROWS = math.floor(buff:byte(2) * 2 ^ 8 + buff:byte(1))

	DT_FRAMES = math.floor((lfs.attributes(file).size - 4) * 2 / (DT_COLUMNS * DT_ROWS) + 0.5)

	return dt
end

local frames = {}
function save_frames_to_memory()
	local path = VIDEO_PATH .. "/" .. VIDEO:match("^(.*)%.") .. "/"
	local i = 1

	print_e(string.format("leyendo bytes de .....ppm (    /%4d)", VIDEO_FRAMES), false)

	for f, _ in lfs.dir(path) do
		if not f:match(".+%.ppm") then goto continue end


		local frame = io.open(path .. f, "rb")
		if frame then
			local byte_string = frame:read("*a")
			-- if not CABECERA then
			-- 	V_COLUMNS, V_ROWS = byte_string:match("P6\x0A(%d+) (%d+)\x0A255\x0A")
			-- 	CABECERA = 9 + tostring(V_COLUMNS):len() + tostring(V_ROWS):len() + 1

			-- 	print("video de resolucion " .. V_COLUMNS .. "x" .. V_ROWS)
			-- end

			table.insert(frames, { byte_string:byte(1, -1) })

			print_l("leyendo bytes de " ..
				with_color(f, Color.YELLOW) .. with_color(string.format(" (%4d/%4d)", i, VIDEO_FRAMES), Color.GRAY))
			-- io.write("\27[20D" ..
			-- 	with_color(f, Color.YELLOW) .. with_color(string.format(" (%4d/%4d)", i, VIDEO_FRAMES), Color.GRAY))
			i = i + 1

			frame:close()
		end
		::continue::
	end
end

function start_pixel_change(dt, selection)
	local inicio = os.clock()

	for j, frame in ipairs(frames) do
		dt_frame = dt:read(math.floor(DT_COLUMNS * DT_ROWS / 2 + 0.5))
		if not dt_frame then
			-- ya no hay mas frames en el dataset, volver a la primera
			dt:seek("set", 4)
			dt_frame = dt:read(math.floor(DT_COLUMNS * DT_ROWS / 2 + 0.5))
		end

		dt_frame = { dt_frame:byte(1, -1) }

		local pixel = 0
		for i = 1, V_COLUMNS * V_ROWS do
			local v = ALGORITHMS[selection or 1](pixel, dt_frame, V_COLUMNS, V_ROWS, DT_COLUMNS, DT_ROWS)

			if v == 15 or pixel == V_COLUMNS * V_ROWS then
				-- print("final v = " .. v) -- no deberia de entrar aqui
				-- break
			end

			if v ~= 0 then
				local indice = ((j + v - 1) % #frames) + 1 -- para que haga wrap arround
				-- local indice = ((math.random(-10, 10) - 1) % #frames) + 1 -- para que haga wrap arround
				-- local indice = j
				-- update_pixel(frame, frames[indice], pixel)
				update_pixel_overlay(frame, frames[indice], pixel)
			end

			pixel = pixel + 1
		end

		local file = io.open(string.format("%s/%s/%04d.ppm", VIDEO_PATH, VIDEO:match("^(.*)%."), j), "wb")
		if not file then return end
		file:write(string.char(table.unpack(frame)))
		file:close()

		print_l(
			"frame " ..
			with_color(j, Color.YELLOW) ..
			" procesada " .. with_color(string.format("(~ %.03fs restantes)", (os.clock() - inicio) * (#frames - j) / j),
				Color.GRAY))
	end

	dt:close()
end
