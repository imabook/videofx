local lfs = require "lfs"

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

		return video_data
	end

	return nil
end

function extract_frames(filename)
	os.execute(string.format('rm -rf ./%s', filename:match("^(.*)%.")))
	os.execute(string.format('ffmpeg -i "%s" -f image2 "%s"/%%04d.ppm', filename, filename:match("^(.*)%.")))
end
