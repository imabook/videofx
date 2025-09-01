require "globals"

function get_videodata(file)
	local handle = io.popen(
		"ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,duration -of csv=p=0 '" ..
		file .. "'")

	if handle then
		local video_data = {}
		local raw = handle:read()
		local width, height, frames, seconds, duration = raw:match("([%d]+),([%d]+),([%d]+)/([%d]+),([%d]+.[%d]+)")
		handle:close()

		video_data = {
			path = lfs.currentdir(),
			filename = file,
			width = width,
			height = height,
			fps = (frames / seconds),
			duration = duration,
			frames = math.floor(duration *
				(frames / seconds))
		}

		V_COLUMNS = tonumber(width)
		V_ROWS = tonumber(height)

		-- +1 porque arrays en lua empiezan en indice 1
		CABECERA = 9 + tostring(V_COLUMNS):len() + tostring(V_ROWS):len() + 1
		VIDEO = file
		VIDEO_PATH = video_data.path

		return video_data
	end

	return nil
end

function extract_frames(filename)
	os.execute(string.format('rm -rf ./%s', filename:match("^(.*)%.")))
	os.execute(string.format('mkdir %s', filename:match("^(.*)%.")))
	os.execute(string.format('ffmpeg -i "%s" -f image2 "%s"/%%04d.ppm', filename, filename:match("^(.*)%.")))
end

function compile_video(filename)
	local save_path = VIDEO_PATH .. "/" .. VIDEO:match("^(.*)%.") .. "-mod"
	os.execute(string.format("mkdir %s", save_path))
	os.execute(string.format("ffmpeg -f image2 -i %s/%%04d.ppm -pix_fmt yuv420p -c:v libx264 %s/%s.mp4 -y",
		VIDEO_PATH .. "/" .. VIDEO:match("^(.*)%."), save_path, filename))

	print_e()
	print_e("video guardado en " .. with_color(save_path .. "/", Color.BG_BLUE))
end
