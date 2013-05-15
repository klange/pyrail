-- pyRail Server API Clientlib
-- (C) 2013 Kevin Lange
-- Released under the terms of the NCSA License

local pyrail = {}

local json = dofile("json.lua")

local apiURL    = "http://localhost:8002/"

-- Alert the server that a train has reached a checkpoint
function pyrail.checkpoint(name,line,direction,track)
	print("Notifying master server...")
	return http.post(apiURL.."checkpoint", json.encode({
		["stop_name"]= name,
		["line_name"]= line,
		["direction"]= direction,
		["track_no"]=  track
	}))
end

-- Get information on the current train, like when to leave
function pyrail.schedule(name,line,direction,track)
	print("Scheduling departure...")
	local resp = http.post(apiURL.."schedule", json.encode({
		["stop_name"]= name,
		["line_name"]= line,
		["direction"]= direction,
		["track_no"]=  track
	}))
	if resp then
		local text = resp.readAll()
		return json.decode(text)
	else
		return false
	end
end

-- Request the next train schedule for this stop
function pyrail.nexttrain(name,line,direction,track)
	print("Requesting next train...")
	local resp = http.post(apiURL.."nexttrain", json.encode({
		["stop_name"]= name,
		["line_name"]= line,
		["direction"]= direction,
		["track_no"]=  track
	}))
	if resp then
		local text = resp.readAll()
		return json.decode(text)
	else
		return false
	end
end

-- Current API time as a string
function pyrail.time()
	local resp = http.get(apiURL.."time")
	if resp then
		return resp.readAll()
	else
		return "00:00"
	end
end

return pyrail
