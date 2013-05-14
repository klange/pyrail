-- Disable left output

local stopName  = "Quantsini Farmstead"
local stopDir   = "inbound"
local lineName  = "red"
local track     = "4"

local boarding  = "left"
local incoming  = "front"
local outgoing  = "right"

local disp_port = "back"

local apiURL    = "http://localhost:8002/"

local function stopTrain ()
    redstone.setAnalogOutput(boarding, 15.0)
end

local function startTrain ()
    redstone.setAnalogOutput(boarding, 0.0)
end

local function apiRequest(endpoint, args)
    return http.get(apiURL..endpoint.."?"..args).readAll()
end

local function waitForTrain ()
    while true do
        local x = redstone.getInput(incoming)
        if x then
            return true
        end
        os.sleep(0.2)
    end
end

local modem = false
local peripherals = ""
local monitor_name = ""
if disp_port then
    modem = peripheral.wrap(disp_port)
    peripherals = modem.getNamesRemote()
    monitor_name = peripherals[1]
end
local function dispDo(func, ...)
  modem.callRemote(monitor_name, func, unpack(arg))
end

local function trainApproach ()
    if disp_port then
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
    else
        os.sleep(2)
    end
end

local function nextTrainIs(train, time)
    dispDo("setCursorPos", 1, 1)
    dispDo("setTextColor", colors.white)
    dispDo("setBackgroundColor", colors.black)
    dispDo("clear")
    dispDo("write", "Next train: "..train)
    dispDo("setCursorPos", 1, 2)
    dispDo("write", "        At: "..time)
end

local function waitTrainLeft ()
    while true do
        local x = redstone.getInput(outgoing)
        if x then
            return true
        end
        os.sleep(0.2)
    end
end

local function trainName(name, destination, time)
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
    dispDo("write", "  "..destination)
    dispDo("setCursorPos", 1, 5)
    dispDo("write", "Leaving at: "..time)
end

-- Rejigger train.
startTrain()
os.sleep(2)
stopTrain()

while true do
    -- local resp = apiRequest("status","stop="..stopName..";dir="..stopDir)
    nextTrainIs("Test","17:00")
    print("Waiting for train...")
    waitForTrain()
    print("Train is approaching!")
    trainApproach()
    stopTrain()
    -- This is the \/      for \/  leaving at \/
    trainName("Awesome Sauce", "Main Base", "17:25")
    print("Holding train at track for 20 seconds.")
    os.sleep(20)
    print("Starting train...")
    startTrain()
    print("Waiting for train to leave...")
    waitTrainLeft()
    print("Train has left.")
    stopTrain()
end
