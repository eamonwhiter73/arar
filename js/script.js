var map;
var service;
var infowindow;
var updates = {};

// Set the configuration for your app
// TODO: Replace with your project's config object
/*var config = {
  apiKey: "AIzaSyAgIKHY4Ev0sUP0cTBaq2gTTcUmVLZilnE",
  authDomain: "scavenger-1517182169698.firebaseapp.com",
  databaseURL: "https://scavenger-1517182169698.firebaseio.com/",
  storageBucket: "scavenger-1517182169698.appspot.com"
};*/

// Get a reference to the database service

function initialize() {
  updates = {};
  //firebase.initializeApp(config);

  var pyrmont = new google.maps.LatLng(42.341614,-71.122094);
  map = new google.maps.Map(document.getElementById('map'), {
    center: pyrmont,
    zoom: 12
  });

  var request = {
    location: pyrmont,
    radius: '600',
    type: ['restaurant']
  };

  service = new google.maps.places.PlacesService(map);
  service.nearbySearch(request, callback);
}

function degrees_to_radians(deg) {
  return (deg * Math.PI)/180
}

function ships_for_a_location(place) {

  var miles = degrees_to_radians(place.geometry.location.lat()) * 69.172;

  var meters_lon = 1.60934 * miles * 1000;
  var meters_lat = 69.172 * 1.60934 * 1000;

  var const_lon = 1 / meters_lon;
  var const_lat = 1 / meters_lat;

  var lat = place.geometry.location.lat();
  var lon = place.geometry.location.lng();

  write_points(lat, lon, const_lat, const_lon, place);
}

function write_points(starting_lat, starting_lon, constant_lat, constant_lon, place) {
  var counter = 1;

  geoHash = Geohash.encode(starting_lat, starting_lon);
  var obj = {name: place.name};
  if (place.rating != null) {
    obj['rating'] = place.rating;
  }
  if (place.icon != null) {
    obj['icon'] = place.icon;
  }

  updates["locations/" + place.place_id] = obj;
  updates["location_coord/" + place.place_id + "/g"] = geoHash;
  updates["location_coord/" + place.place_id + "/l"] = new Array(starting_lat, starting_lon);

  console.log(place.place_id + "    place ------------- ^^^^^^^^^^^^^")
  //ref.update(updates);

  for (var i = 1; i < 5; i++) {

    var starting_lon_var = starting_lon + constant_lon * (i * Math.random());
    var geoHash = Geohash.encode(starting_lat, starting_lon_var);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat, starting_lon_var);
    counter+=1;

    starting_lon_var = starting_lon - constant_lon * (i * Math.random());
    geoHash = Geohash.encode(starting_lat, starting_lon_var);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat, starting_lon_var);
    counter+=1;

    var starting_lat_var = starting_lat + constant_lat * (i * Math.random());
    geoHash = Geohash.encode(starting_lat_var, starting_lon);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon);
    counter+=1;

    starting_lat_var = starting_lat - constant_lat * (i * Math.random());
    geoHash = Geohash.encode(starting_lat_var, starting_lon);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon);
    counter+=1;

    starting_lon_var = starting_lon + constant_lon * (i * Math.random());
    starting_lat_var = starting_lat - constant_lat * (i * Math.random());
    geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
    counter+=1;

    starting_lon_var = starting_lon - constant_lon * (i * Math.random());
    starting_lat_var = starting_lat + constant_lat * (i * Math.random());
    geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
    counter+=1;

    starting_lon_var = starting_lon + constant_lon * (i * Math.random());
    starting_lat_var = starting_lat + constant_lat * (i * Math.random());
    geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
    counter+=1;

    starting_lon_var = starting_lon - constant_lon * (i * Math.random());
    starting_lat_var = starting_lat - constant_lat * (i * Math.random());
    geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/g"] = geoHash;
    updates["ships_for_locations/" + place.place_id + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
    counter+=1;
  }

  //ref.update(updates);
}

function callback(results, status) {
  if (status == google.maps.places.PlacesServiceStatus.OK) {
    for (var i = 0; i < results.length; i++) {
      var place = results[i];
      //createMarker(results[i]);
      console.log(JSON.stringify(place));

      ships_for_a_location(place);
    }

    var miles = degrees_to_radians(42.24682749999999 * 69.172);

    var meters_lon = 1.60934 * miles * 1000;
    var meters_lat = 69.172 * 1.60934 * 1000;

    var constant_lon = 1 / meters_lon;
    var constant_lat = 1 / meters_lat;

    geoHash = Geohash.encode(42.24682749999999, -71.17463089999997);
    var obj = {name: "home"};
    obj['rating'] = 5;

    updates["locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo"] = obj;
    updates["location_coord/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/g"] = geoHash;
    updates["location_coord/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/l"] = new Array(42.24682749999999, -71.17463089999997);

    console.log(JSON.stringify(updates) + "    updates ------------- ^^^^^^^^^^^^^")
    //ref.update(updates);

    var counter = 1;
    for (var i = 1; i < 5; i++) {

      var starting_lon_var = -71.17463089999997 + constant_lon * (i * Math.random());
      var geoHash = Geohash.encode(42.24682749999999, starting_lon_var);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(42.24682749999999, starting_lon_var);
      counter+=1;

      starting_lon_var = -71.17463089999997 - constant_lon * (i * Math.random());
      geoHash = Geohash.encode(42.24682749999999, starting_lon_var);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(42.24682749999999, starting_lon_var);
      counter+=1;

      var starting_lat_var = 42.24682749999999 + constant_lat * (i * Math.random());
      geoHash = Geohash.encode(starting_lat_var, -71.17463089999997);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, -71.17463089999997);
      counter+=1;

      starting_lat_var = 42.24682749999999 - constant_lat * (i * Math.random());
      geoHash = Geohash.encode(starting_lat_var, -71.17463089999997);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, -71.17463089999997);
      counter+=1;

      starting_lon_var = -71.17463089999997 + constant_lon * (i * Math.random());
      starting_lat_var = 42.24682749999999 - constant_lat * (i * Math.random());
      geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
      counter+=1;

      starting_lon_var = -71.17463089999997 - constant_lon * (i * Math.random());
      starting_lat_var = 42.24682749999999 + constant_lat * (i * Math.random());
      geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
      counter+=1;

      starting_lon_var = -71.17463089999997 + constant_lon * (i * Math.random());
      starting_lat_var = 42.24682749999999 + constant_lat * (i * Math.random());
      geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
      counter+=1;

      starting_lon_var = -71.17463089999997 - constant_lon * (i * Math.random());
      starting_lat_var = 42.24682749999999 - constant_lat * (i * Math.random());
      geoHash = Geohash.encode(starting_lat_var, starting_lon_var);
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/g"] = geoHash;
      updates["ships_for_locations/" + "ChIJpd7tz5B_44kRfvSIyNDxpMo" + "/ship" + counter.toString() + "/l"] = new Array(starting_lat_var, starting_lon_var);
      counter+=1;
    }
    
    var database = firebase.database();
    var ref = database.ref();

    ref.update(updates);
    console.log("EVERYTHING WORKED OUT");
  }
}
