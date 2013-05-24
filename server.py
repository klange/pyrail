from paste.httpserver import serve
from pyramid.config   import Configurator
from pyramid.response import Response

import json
import time

stations = ["Quantsini Farmstead", "Sandy Shores", "Main Base", "Research Center"]

def getdest(station, direction):
	if not station in stations:
		return "???"

	current = stations.index(station)

	if direction.lower() == "inbound":
		if current == len(stations)-1:
			return "(Loop back)"
		else:
			return stations[current+1]
	else:
		if current == 0:
			return "(Loop back)"
		else:
			return stations[current-1]

def checkpoint(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	return Response(json.dumps(resp))

def schedule(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	resp['name']   = "Red Line"
	resp['time']   = time.strftime("%H:%M:%S", time.localtime(time.time()+20))
	resp['dest']   = getdest(data['stop_name'], data['direction'])
	resp['leave']  = 20
	return Response(json.dumps(resp))

def nexttrain(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	resp['name']   = "Red Line"
	resp['time']   = time.strftime("%H:%M", time.localtime(time.time()+5*60))
	resp['dest']   = getdest(data['stop_name'], data['direction'])
	return Response(json.dumps(resp))

def api_time(request):
	return Response(time.strftime("%H:%M"))

if __name__ == "__main__":
	config = Configurator()
	config.add_route('checkpoint', '/checkpoint')
	config.add_view(checkpoint, route_name='checkpoint')
	config.add_route('schedule', '/schedule')
	config.add_view(schedule, route_name='schedule')
	config.add_route('nexttrain', '/nexttrain')
	config.add_view(nexttrain, route_name='nexttrain')
	config.add_route('time', '/time')
	config.add_view(api_time, route_name='time')
	app = config.make_wsgi_app()
	serve(app, host='0.0.0.0:8002')

