import math
import random


def degrees_to_radians(deg):
	return deg * math.pi/180

def populate():
	array = []
	lat = 42.0572047
	lon = -72.55540460000002

	miles = degrees_to_radians(lat) * 69.172

	meters_lon = 1.60934 * miles * 1000
	meters_lat = 69.172 * 1.60934 * 1000

	const_lon = 60 / meters_lon
	const_lat = 60 / meters_lat

	array = create_array(lat, lon, const_lat, const_lon)
	array.insert(0, {"latitude": lat, "longitude": lon, "ship": "ship0"})

	file = open("points.json","w")

	file.write('{\n  "coords" : {\n')

	for i in range(0, 41):
		if i == 40:
			file.write('    "' + array[i]['ship'] + '" : {\n        "latitude" : ' + str(array[i]['latitude']) + ',\n        "longitude" : ' + str(array[i]['longitude']) + ',\n        "altitude" : 36\n    }\n')
		else:
			file.write('    "' + array[i]['ship'] + '" : {\n        "latitude" : ' + str(array[i]['latitude']) + ',\n        "longitude" : ' + str(array[i]['longitude']) + ',\n        "altitude" : 36\n    },\n')
		
	file.write('  }\n}')

	file.close()

def create_array(starting_lat, starting_lon, constant_lat, constant_lon):
	array = []

	counter = 1
	for i in range(1, 6):

		starting_lon_var = starting_lon + constant_lon * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat, "longitude": starting_lon_var, "ship": "ship" + str(counter)})
		counter+=1

		starting_lon_var = starting_lon - constant_lon * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat, "longitude": starting_lon_var, "ship": "ship" + str(counter)})
		counter+=1

		starting_lat_var = starting_lat + constant_lat * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat_var, "longitude": starting_lon, "ship": "ship" + str(counter)})
		counter+=1

		starting_lat_var = starting_lat - constant_lat * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat_var, "longitude": starting_lon, "ship": "ship" + str(counter)})
		counter+=1

		starting_lon_var = starting_lon + constant_lon * (i * random.uniform(0, 1))
		starting_lat_var = starting_lat - constant_lat * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat_var, "longitude": starting_lon_var, "ship": "ship" + str(counter)})
		counter+=1

		starting_lon_var = starting_lon - constant_lon * (i * random.uniform(0, 1))
		starting_lat_var = starting_lat + constant_lat * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat_var, "longitude": starting_lon_var, "ship": "ship" + str(counter)})
		counter+=1

		starting_lon_var = starting_lon + constant_lon * (i * random.uniform(0, 1))
		starting_lat_var = starting_lat + constant_lat * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat_var, "longitude": starting_lon_var, "ship": "ship" + str(counter)})
		counter+=1

		starting_lon_var = starting_lon - constant_lon * (i * random.uniform(0, 1))
		starting_lat_var = starting_lat - constant_lat * (i * random.uniform(0, 1))
		array.append({"latitude": starting_lat_var, "longitude": starting_lon_var, "ship": "ship" + str(counter)})
		counter+=1

	return array

populate()