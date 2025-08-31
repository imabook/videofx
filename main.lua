require "globals"
require "menu"
require "utils"

::start::

local video_data = nil
repeat
	print_menu({ "mp4", "mov" })
	print_e()
	print_e("elige un video: ", false)

	local video = select_file(tonumber(io.read()) or 1)
	if video then
		video_data = get_videodata(video.name)
	end
until video_data

local exists = print_video_data(video_data)
local ans = io.read():lower() == "y"

if ans then
	-- borrar frames anteriores (si existen)
	-- procesar frames
	extract_frames(video_data.filename)
elseif not exists then
	goto start -- es mala practica pero bueno
end
