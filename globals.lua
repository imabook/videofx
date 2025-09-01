package.path = package.path .. ";./modules/share/lua/5.4/?.lua"
package.cpath = package.cpath .. ";./modules/lib/lua/5.4/?.so"

lfs = require("lfs")

VIDEO = nil           -- el nombre del video (con extension)
VIDEO_PATH = nil      -- el path del video
VIDEO_SIZE = nil      -- el tamaño en bytes del video
FRAME_SIZE = nil      -- el tamaño en bytes de un frame (.ppm)
VIDEO_FRAMES = 0      -- los frames procesados del video (puede que no sean todos)

FRAME_FILE = nil      -- el nombre del .fdt
FRAME_FILE_PATH = nil -- el path de .fdt

V_COLUMNS = nil       -- el width del video
V_ROWS = nil          -- el height del video
DT_COLUMNS = nil      -- el width de la simulacion
DT_ROWS = nil         -- el height de la simulacion
DT_FRAMES = nil       -- el numero de frames de la simulacion

CABECERA = nil        -- los bytes que ocupa la cabecera del .ppm
