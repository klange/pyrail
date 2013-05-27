from paste.httpserver import serve
from pyramid.config   import Configurator
from pyramid.response import Response

import json
import time

class Train(object):
	def __init__(self, number, line, at, dest):
		self.number = number
		self.line   = line
		self.at     = at
		self.dest   = dest

class Line(object):
	def __init__(self, name, stations, times, trains=1):
		self.name        = name
		self.stations    = stations
		self.times       = times # XXX do this experimentally
		self.train_count = trains
		self.trains_seen = 0
		self.trains      = []
		self.rtt         = None

	def next_train_number(self):
		out = self.trains_seen
		self.trains_seen += 1
		return out

	def identify(self, station, dest, direction):
		# Direction might help later.
		train = None
		for i in self.trains:
			if i.dest == station:
				train = i
		if not train and self.trains_seen < self.train_count:
			train = Train(self.next_train_number(), self, station, dest)
			print "   Newly identified train."
			self.trains.append(train)
		elif not train and self.trains_seen >= self.train_count:
			print "Failed to identify train!"
			return None
		else:
			train.at   = station
			train.dest = dest
		print "   This is train #%d. It should arrive at its destination at %s." % (train.number, time.strftime("%H:%M:%S", time.localtime(time.time() + self.time_between(station, dest))))
		return train


	def getdest(self, station, direction):
		if not station in self.stations:
			return "???"

		current = self.stations.index(station)

		if direction.lower() == "inbound":
			if current == len(self.stations)-1:
				return self.stations[current]
			else:
				return self.stations[current+1]
		elif direction.lower() == "outbound":
			if current == 0:
				return self.stations[current]
			else:
				return self.stations[current-1]
		else: # Special loops
			if current == len(self.stations)-1:
				return self.stations[0]
			else:
				return self.stations[current+1]

	def time_between(self, start, dest):
		if not (start, dest) in self.times:
			return 1000.0
		else:
			return self.times[(start,dest)] + 20

	def round_trip_time(self):
		if not self.rtt:
			total = 0.0
			for k,v in self.times.items():
				total += v + 21.0 # Approximate wait time
			self.rtt = total
			return total
		else:
			return self.rtt

lines = {}

# This is a complete list of all stations.
_qf = "Quantsini Farmstead" # -480, 340
_ss = "Sandy Shores"        # -330, 200
_mb = "Main Base"           # 130, 200
_rc = "Research Center"     # 235, 245
_sp = "Spawn Point"         # 235, 350

lines["Red Line"] = Line("Red Line", [_qf,_ss,_mb,_rc,_sp], {
		(_qf,_ss): 53.0,
		(_ss,_mb): 82.0,
		(_mb,_rc): 44.0,
		(_rc,_sp): 23.0,
		(_sp,_rc): 17.0,
		(_rc,_mb): 26.0,
		(_mb,_ss): 87.0,
		(_ss,_qf): 55.0,
		}, 1)

lines["Yellow Line"] = Line("Yellow Line", [_qf], {
		(_qf, _qf): 74.0,
	}, 1)

def checkpoint(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	return Response(json.dumps(resp))

def schedule(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	if not data['line_name'] in lines:
		resp['name']   = "???"
		resp['dest']   = "???"
		resp['time']   = time.strftime("%H:%M:%S", time.localtime(time.time()+20))
		resp['leave']  = 20
	else:
		line = lines[data['line_name']]
		resp['name']   = line.name
		resp['dest']   = line.getdest(data['stop_name'], data['direction'])
		resp['time']   = time.strftime("%H:%M:%S", time.localtime(time.time()+20))
		print "%s train arriving at %s station (%s) at %s" % (line.name, data['stop_name'], data['direction'], time.strftime("%H:%M:%S", time.localtime(time.time())))
		print "   It is bound for %s." % (resp['dest'])
		train = line.identify(data['stop_name'], resp['dest'], data['direction'])
		resp['leave']  = 20
	return Response(json.dumps(resp))

def nexttrain(request):
	resp = {}
	data = json.loads(request.body)
	resp['status'] = 'ok'
	if not data['line_name'] in lines:
		resp['name']   = "???"
		resp['dest']   = "???"
		resp['time']   = time.strftime("%H:%M", time.localtime(time.time()+5*60))
	else:
		line = lines[data['line_name']]
		resp['name']   = line.name
		resp['dest']   = line.getdest(data['stop_name'], data['direction'])
		resp['time']   = time.strftime("%H:%M", time.localtime(time.time()+line.round_trip_time()/line.train_count))
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

