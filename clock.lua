local pyrail = dofile("pyrail.lua")

local display = peripheral.wrap("top")
display.setTextScale(4.0)

while true do
	display.clear()
	display.setCursorPos(1,1)
	display.write(pyrail.time())
	os.sleep(60)
end
