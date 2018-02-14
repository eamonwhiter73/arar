var functions = require('firebase-functions');
var request = require('request');

function runThroughPromise(ship, original, updates) {

	return new Promise((resolve, reject) => {
		var url = "https://maps.googleapis.com/maps/api/elevation/json?locations=" + original[ship].latitude + "," + original[ship].longitude + "&key=AIzaSyD1pGrSbB0QCvxV9BEq1e_5qVT1f6BpCRs";
		request(url, (error, response, body) => {
			if(error !== null) {
				console.log(error + "------ error for request --------");
				reject(error);
			}
			console.log(JSON.stringify(response) + "      response ---------------");
			console.log(JSON.stringify(JSON.parse(body)) + "      body ---------------");

			var elevationResults = JSON.parse(body).results;

			console.log(JSON.stringify(elevationResults));

			var elevation = elevationResults[0].elevation + Math.random() * 8

			//updates["/" + ship + '/altitude'] = elevation;
			resolve({"elevation": elevation, "ref": "/" + ship + "/altitude"});
		});	
	})
}

exports.elevation = functions.database.ref('/coords').onCreate(event => {
	var updates = {}

	const original = event.data.val();
	console.log(JSON.stringify(original) + "      event.data.val() ---------------");
	var promises_array = [];

	for(var ship in original) {
		promises_array.push(runThroughPromise(ship, original).then((result) => {
			updates[result.ref] = result.elevation; 
			return;
		}));
	}

	return Promise.all(promises_array).then(() => {
		console.log(JSON.stringify(updates) + "------- updates --------");
		return event.data.ref.update(updates);
	})
}) 

	

	
