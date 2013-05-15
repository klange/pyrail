-- pyRail Checkpoint Track
-- (C) 2013 Kevin Lange
-- Released under the terms of the NCSA License

local pyrail = dofile("pyrail.lua")

-- Configuration
local config = {}
-- Default config values:
config.incoming = "right"
config.name     = "Unamed Checkpoint"
config.line     = "Unknown Line"
config.linedir  = "incoming"
config.track    = "1"

config_name = ".config"

if fs.exists(config_name) then
	print("Loading config file...")
	local _config = dofile(config_name)
	for k,v in pairs(_config) do
		config[k] = v
	end
else
	print("This station does not have a configuration. This is probably wrong.")
	return 1
end

local function waitForTrain ()
	while true do
		local x = redstone.getInput(config.incoming)
		if x then
			return true
		end
		os.pullEvent("redstone")
	end
end

print("This is checkpoint '"..config.name.."' on the "..config.line.." ("..config.linedir..")")

while true do
	print("Waiting for train...")
	waitForTrain()
	print("Train has arrived.")
	local x = pyrail.checkpoint(config.name,config.line,config.linedir,config.track)
	if x then
		print(x.readAll())
	end
	os.sleep(0.5)
end
