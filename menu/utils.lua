require "globals"

local path = lfs.currentdir()
local files = {}

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

	return files
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
