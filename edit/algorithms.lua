function get_value(dt_frame, p)
	local byte = dt_frame[math.floor(p / 2) + 1]

	-- porque en un byte guarda dos pixeles, 4 bits y 4 bits
	if p % 2 == 0 then
		return math.floor(byte / (2 ^ 4))
	else
		return math.floor(byte % (2 ^ 4))
	end
end

function update_pixel(frame_dest, frame_orig, i)
	i = 3 * i + CABECERA

	-- if math.random(0, 4) ~= 0 then
	-- 	frame_dest[i + math.random(0, 2)] = frame_orig[i] -- R
	-- 	frame_dest[i + math.random(0, 2)] = frame_orig[i + 1] -- G
	-- 	frame_dest[i + math.random(0, 2)] = frame_orig[i + 2] -- B
	-- else
	frame_dest[i] = frame_orig[i]      -- R
	frame_dest[i + 1] = frame_orig[i + 1] -- G
	frame_dest[i + 2] = frame_orig[i + 2] -- B
	-- end
end

function floor_interpolation(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	local x = math.floor(p % v_cols)
	local y = math.floor(p / v_cols)

	local dt_x = math.floor(x * (dt_cols - 1) / (v_cols - 1))
	local dt_y = math.floor(y * (dt_rows - 1) / (v_rows - 1))

	-- print("a las coordenadas del video (" .. x .. ", " .. y .. ") se le asignan (" .. dt_x .. ", " .. dt_y .. ")")

	local dt_p = dt_x + dt_y * dt_cols
	return get_value(dt_frame, dt_p)
end

function nearest_neighbour(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	local x = math.floor(p % v_cols)
	local y = math.floor(p / v_cols)

	local dt_x = math.floor(x * (dt_cols - 1) / (v_cols - 1) + 0.5) -- es lo unico que cambia
	local dt_y = math.floor(y * (dt_rows - 1) / (v_rows - 1) + 0.5)

	local dt_p = dt_x + dt_y * dt_cols
	return get_value(dt_frame, dt_p)
end

function lerp(a, b, r)
	-- a * (1-r) + b * r; r va de 0.0 a 1.0
	return a + (b - a) * r
end

function bilinear(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	local x = math.floor(p % v_cols)
	local y = math.floor(p / v_cols)

	local dt_x = x * (dt_cols - 1) / (v_cols - 1)
	local dt_y = y * (dt_rows - 1) / (v_rows - 1)
	local wx, wy = dt_x - math.floor(dt_x), dt_y - math.floor(dt_y)
	dt_x = math.floor(dt_x)
	dt_y = math.floor(dt_y)

	local puntos = {}
	puntos[1] = dt_x + dt_y * dt_cols
	puntos[2] = (dt_x + 1) % dt_cols + dt_y * dt_cols
	puntos[3] = dt_x + ((dt_y + 1) % dt_rows) * dt_cols
	puntos[4] = (dt_x + 1) % dt_cols + ((dt_y + 1) % dt_rows) * dt_cols


	local top = lerp(get_value(dt_frame, puntos[1]), get_value(dt_frame, puntos[2]), wx)
	local bottom = lerp(get_value(dt_frame, puntos[3]), get_value(dt_frame, puntos[4]), wx)

	return math.floor(lerp(top, bottom, wy) + 0.5)
end

return { floor_interpolation, nearest_neighbour, bilinear }
