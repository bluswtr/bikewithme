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
			$(document).trigger("address_found",[status,results[0].formatted_address,lat,lng]);
			$(document).trigger("city_state_found",[status,results[0].address_components[2].long_name,results[0].address_components[4].short_name]);			
			bikewithme_log("address_found triggered: ",results[0].formatted_address);
			bikewithme_log("city_state_found triggered: ",results[0].address_components[2].long_name + ", " + results[0].address_components[4].short_name);
		}

latlngFound = function(results,status) {
			var lat = results[0].geometry.location.lat();
			var lng = results[0].geometry.location.lng();
			$(document).trigger("latlng_found",[status,lat,lng]);
			bikewithme_log('latlng_found triggered');
		}

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
