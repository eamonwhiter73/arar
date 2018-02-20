var functions = require('firebase-functions');
var request = require('request');
var updates = {};

function runThroughPromise(ship, original) {

	return new Promise((resolve, reject) => {
		var url = "https://maps.googleapis.com/maps/api/elevation/json?locations=" + original[ship]['l'][0] + "," + original[ship]['l'][1] + "&key=AIzaSyD1pGrSbB0QCvxV9BEq1e_5qVT1f6BpCRs";
		request(url, (error, response, body) => {
			if(error !== null) {
				console.log(error + "------ error for request --------");
				reject(error);
			}
			console.log(JSON.stringify(response) + "      response ---------------");
			console.log(JSON.stringify(JSON.parse(body)) + "      body ---------------");

			var elevationResults = JSON.parse(body).results;

			console.log(JSON.stringify(elevationResults));

			var elevation = elevationResults[0].elevation + Math.random() * 8;

			updates["/" + ship + "/altitude"] = elevation;
			//updates["/" + ship + '/altitude'] = elevation;
			resolve();
		});	
	})
}

exports.elevation = functions.database.ref('/ships_for_locations/{pushId}').onCreate(event => {
	updates = {};

	const original = event.data.val();
	console.log(JSON.stringify(original) + "      event.data.val() ---------------");
	var promises_array = [];

	//var original2 = original[Object.keys(original)[0]];

	//console.log(JSON.stringify(original2) + "    -----------> original 2");

	for(var ship in original) {
		console.log(JSON.stringify(ship) + " ship ------><     " + JSON.stringify(original[ship]) + " 0000000000 " + event.data.key);
		promises_array.push(runThroughPromise(ship, original));
	}

	return Promise.all(promises_array).then(() => {
		console.log(JSON.stringify(updates) + "------- updates --------");
		return event.data.ref.update(updates);
	})
})

exports.hourly_job = functions.pubsub.topic('hourly-tick').onPublish((event) => {
	console.log(JSON.stringify(event) + " ------ event --------");
    var url = "http://eamondev.com/ar";
	return request(url, (error, response, body) => {
		if(error !== null) {
			console.log(error + "------ error for request --------");
		}

		console.log(JSON.stringify(response) + "      response ---------------");
	});	
});

	

	
