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
			bikewithme_log("geolocation ready");
			$(document).trigger("geolocation_ready",[geolocation]);
		},function(error){
			bikewithme_log("geolocation disabled");
			handleGeolocationError("Enable your location settings to get more accurate results, then hit refresh.");
		});
	} else {
		bikewithme_log("geolocation not supported");
		handleGeolocationError("Sorry, looks like geolocation is not supported in your browser. Your results won't be as accurate, but we can continue without it.");
	}
	return 0;
}

function handleGeolocationError(message){
	alertify.set({ labels: {
	    ok     : "OK",
	    cancel : "Cancel"
	} });

	alertify.confirm(message,function(e){
		if(e)
			setGeolocation("events/save_geolocation",false,false);
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
