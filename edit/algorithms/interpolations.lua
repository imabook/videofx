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

function update_pixel_overlay(frame_dest, frame_orig, i)
	i = 3 * i + CABECERA

	frame_dest[i] = math.floor((frame_orig[i] + frame_dest[i]) / 2 + 0.5)          -- R
	frame_dest[i + 1] = math.floor((frame_orig[i + 1] + frame_dest[i + 1]) / 2 + 0.5) -- G
	frame_dest[i + 2] = math.floor((frame_orig[i + 2] + frame_dest[i + 2]) / 2 + 0.5) -- B
	-- end
end

function transform_coords_floor(p, v_cols, v_rows, dt_cols, dt_rows)
	local x = math.floor(p % v_cols)
	local y = math.floor(p / v_cols)

	local dt_x = math.floor(x * (dt_cols - 1) / (v_cols - 1))
	local dt_y = math.floor(y * (dt_rows - 1) / (v_rows - 1))

	return dt_x, dt_y, dt_x + dt_y * dt_cols
end

function floor_interpolation(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	-- local x = math.floor(p % v_cols)
	-- local y = math.floor(p / v_cols)

	-- local dt_x = math.floor(x * (dt_cols - 1) / (v_cols - 1))
	-- local dt_y = math.floor(y * (dt_rows - 1) / (v_rows - 1))

	-- print("a las coordenadas del video (" .. x .. ", " .. y .. ") se le asignan (" .. dt_x .. ", " .. dt_y .. ")")

	local _, _, dt_p = transform_coords_floor(p, v_cols, v_rows, dt_cols, dt_rows)

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

function random_frame(seed)
	math.randomseed(seed)
	return math.random(VIDEO_FRAMES + 1) - 1
end

function all_random(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	-- random por bloques ignorando el fdt siendo consistente
	-- siguen la interpolacion vecino proximo (floor int.)

	local _, _, dt_p = transform_coords_floor(p, v_cols, v_rows, dt_cols, dt_rows)

	return random_frame(RANDOM_SEED + dt_p)
end

function partial_random(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	-- random por bloques dependiendo del valor en el fdt siendo consistente
	-- siguen la interpolacion vecino proximo (floor int.)
	local _, _, dt_p = transform_coords_floor(p, v_cols, v_rows, dt_cols, dt_rows)
	if get_value(dt_frame, dt_p) == 0 then
		return 0
	end

	return random_frame(RANDOM_SEED + dt_p)
end

function all_random_per_frame(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	-- random por bloques ignorando sin ser consistente
	-- siguen la interpolacion vecino proximo (floor int.)
	local _, _, dt_p = transform_coords_floor(p, v_cols, v_rows, dt_cols, dt_rows)
	local v = get_value(dt_frame, dt_p)

	return random_frame(RANDOM_SEED * v + dt_p)
end

function partial_random_per_frame(p, dt_frame, v_cols, v_rows, dt_cols, dt_rows)
	-- random por bloques dependiendo del valor en el fdt sin ser consistente entre frames (por fdt)
	-- siguen la interpolacion vecino proximo (floor int.)
	local _, _, dt_p = transform_coords_floor(p, v_cols, v_rows, dt_cols, dt_rows)
	local v = get_value(dt_frame, dt_p)

	if v == 0 then
		return 0
	end

	return random_frame(RANDOM_SEED * v + dt_p)
end

return { floor_interpolation, nearest_neighbour, bilinear, all_random, partial_random, all_random_per_frame,
	partial_random_per_frame }
