local pyrail = dofile("pyrail.lua")

-- Configuration
local config = {}
-- Default config values:
config.clock = "top"

config_name = ".config"

if fs.exists(config_name) then
	print("Loading config file...")
	local _config = dofile(config_name)
	for k,v in pairs(_config) do
		config[k] = v
	end
end

local display = peripheral.wrap(config.clock)
display.setTextScale(4.0)

while true do
	display.clear()
	display.setCursorPos(1,1)
	display.write(pyrail.time())
	os.sleep(60)
end
