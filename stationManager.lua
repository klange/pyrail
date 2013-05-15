-- pyRail Station Manager
-- (C) 2013 Kevin Lange
-- Released under the terms of the NCSA License

local pyrail = dofile("pyrail.lua")

-- Configuration
local config = {}
-- Default config values:
config.boarding = "left"
config.incoming = "front"
config.outgoing = "right"
config.display  = false
-- Station naming
config.name     = "Unamed Checkpoint"
config.line     = "Unknown Line"
config.linedir  = "inbound"
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

local function stopTrain ()
	redstone.setAnalogOutput(config.boarding, 15.0)
end

local function startTrain ()
	redstone.setAnalogOutput(config.boarding, 0.0)
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

local function waitTrainLeft ()
	while true do
		local x = redstone.getInput(config.outgoing)
		if x then
			return true
		end
		os.pullEvent("redstone")
	end
end

local modem = false
local peripherals = ""
local monitor_name = ""
if config.display then
	modem = peripheral.wrap(config.display)
	peripherals = modem.getNamesRemote()
	monitor_name = peripherals[1]
end
local function dispDo(func, ...)
	if config.display then
		modem.callRemote(monitor_name, func, unpack(arg))
	end
end

local function trainApproach ()
	for i = 1, 5, 1 do
		dispDo("setCursorPos", 1,1)
		dispDo("setTextColor", colors.white)
		dispDo("setBackgroundColor", colors.red)
		dispDo("clear")
		dispDo("write", "Train Approaching")
		os.sleep(0.5)
		dispDo("setCursorPos", 1,1)
		dispDo("setTextColor", colors.black)
		dispDo("setBackgroundColor", colors.yellow)
		dispDo("clear")
		dispDo("write", "Train Approaching")
		os.sleep(0.5)
	end
	dispDo("setCursorPos", 1,1)
	dispDo("setTextColor", colors.white)
	dispDo("setBackgroundColor", colors.black)
	dispDo("clear")
end

local function nextTrainIs()
	local resp  = pyrail.nexttrain(config.name, config.line, config.linedir, config.track)
	if resp then
		local train = resp['name']
		local dest  = resp['dest']
		local time  = resp['time']
		dispDo("setCursorPos", 1, 1)
		dispDo("setTextColor", colors.white)
		dispDo("setBackgroundColor", colors.black)
		dispDo("clear")
		dispDo("write", "Next train is the")
		dispDo("setCursorPos", 3, 2)
		dispDo("write", train)
		dispDo("setCursorPos", 1, 3)
		dispDo("write", " at "..time)
		dispDo("setCursorPos", 1, 4)
		dispDo("write", "for "..dest)
	else
		dispDo("setCursorPos", 1, 1)
		dispDo("setTextColor", colors.white)
		dispDo("setBackgroundColor", colors.black)
		dispDo("clear")
		dispDo("write", "(Train status")
		dispDo("setCursorPos", 1, 2)
		dispDo("write", "unavailable)")
	end
end

-- "This is the..."
local function scheduleDeparture()
	local resp  = pyrail.schedule(config.name, config.line, config.linedir, config.track)
	if resp then
		local name = resp['name']
		local dest = resp['dest']
		local time = resp['time']
		dispDo("setCursorPos", 1, 1)
		dispDo("setTextColor", colors.black)
		dispDo("setBackgroundColor", colors.white)
		dispDo("clear")
		dispDo("write", "This is the:")
		dispDo("setCursorPos", 1, 2)
		dispDo("write", "  "..name)
		dispDo("setCursorPos", 1, 3)
		dispDo("write", "For:")
		dispDo("setCursorPos", 1, 4)
		dispDo("write", "  "..dest)
		dispDo("setCursorPos", 1, 5)
		dispDo("write", "Leaving: "..time)
		return resp['leave']
	else
		dispDo("setCursorPos", 1, 1)
		dispDo("setTextColor", colors.black)
		dispDo("setBackgroundColor", colors.white)
		dispDo("clear")
		dispDo("write", "TRAIN SYSTEM DOWN")
		dispDo("setCursorPos", 1, 2)
		dispDo("write", "TRAIN IS RUNNING")
		dispDo("setCursorPos", 1, 3)
		dispDo("write", "AUTOMATICALLY")
		return 20
	end
end

-- Rejigger train.
startTrain()
os.sleep(2)
stopTrain()

while true do
    nextTrainIs()
    print("Waiting for train...")
    waitForTrain()
    print("Train is approaching!")
    trainApproach()
    stopTrain()
    local when = scheduleDeparture()
    print("Holding train at track for "..when.." seconds.")
    os.sleep(when)
    print("Starting train...")
    startTrain()
    print("Waiting for train to leave...")
    waitTrainLeft()
    print("Train has left.")
    stopTrain()
end
