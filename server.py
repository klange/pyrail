from paste.httpserver import serve
from pyramid.config   import Configurator
from pyramid.response import Response

import json
import time

def checkpoint(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	return Response(json.dumps(resp))

def schedule(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	resp['name']   = "Some Train"
	resp['time']   = time.strftime("%H:%M")
	resp['dest']   = "Main Base"
	resp['leave']  = 20
	return Response(json.dumps(resp))

def nexttrain(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	resp['name']   = "Some Train"
	resp['time']   = time.strftime("%H:%M")
	resp['dest']   = "Main Base"
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

