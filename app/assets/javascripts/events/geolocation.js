// Geolocation Concerns: get and set geolocations
// Geolocation is written with the Command Pattern

// save geolocation to backend only
// saving in browser might be a bad idea
function setGeolocation(url,lat,lng) {
	$.post(url,{lat:lat,lng:lng});
}

// if no geolocation, guess by using ip address
function getGeolocationFromBrowser() {
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(function(geolocation){
			$(document).trigger("geolocation_ready",[geolocation]);
		},function(error){
			getGeolocationFromIP("To get more accurate results, enable your location settings, then hit refresh.");
		});
	} else {
		getGeolocationFromIP("Looks like your browser does not support geolocation.");
	}
	return 0;
}

function getGeolocationFromIP(message){
	alertify.set({ labels: {
	    ok     : "Continue Anyway",
	    cancel : "Cancel"
	} });

	alertify.confirm(message,function(e){
		if(e)
			getGeolocationFromIP();
	});
}

addressFound = function(results,status) {
			var lat = results[0].geometry.location.lat();
			var lng = results[0].geometry.location.lng();
			bikewithme_log("address_found triggered: ",results[0].formatted_address);
			$(document).trigger("address_found",[status,results[0].formatted_address,lat,lng]);
		}

latlngFound = function(results,status) {
			var lat = results[0].geometry.location.lat();
			var lng = results[0].geometry.location.lng();
			$(document).trigger("latlng_found",[status,lat,lng]);
			bikewithme_log('latlng_found triggered');
		}

// would need to evaluate a regular expression in UI to determine if Latlng or address
function geocodeLatlng(lat,lng){
	bikewithme_log("geocodeLatlng");
	GMaps.geocode({
		lat: lat,
		lng: lng,
		callback: addressFound
	});
}

function geocodeAddress(string) {
	bikewithme_log("geocoding address");
	GMaps.geocode({
		address: string.trim(),
		callback: latlngFound
	});
}


// if for some reason session is empty
// get geolocation from browser or ip

// maybe can skip this. can get latlng from controller without invoking jscript
function getGeolocationFromSession(){

	return latlng;
}
