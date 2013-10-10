var el = '#map';
var infoWindowMaxWidth = 280;
var map;

function geolocate() {

	if (navigator.geolocation) {
	    navigator.geolocation.getCurrentPosition(function(position){
		    var map = init_map(position.coords.latitude,position.coords.longitude);
		    put_address_flow(map);
		},function(error){
		    // please add in newer versions: use ip address to determine nearest location?
		    alert("sorry, cannot get your location\n turn on your location settings in:");
		});
	} else {
	    //provide links to Firefox 3.5
	    alert("your browser doesn't support geolocation");
	}

}

function geolocate_nearest(callback_initmap) {

	if (navigator.geolocation) {
	    navigator.geolocation.getCurrentPosition(function(position){
		    $.get("/events/nearest",
		    	{lat:position.coords.latitude,lng:position.coords.longitude},
		    	function(data) {
					init_populated_map(data,position.coords.latitude,position.coords.longitude);
		    	}
			);
		},function(error){
		    // please add in newer versions: use ip address to determine nearest location?
		    alert("sorry, cannot get your location\n turn on your location settings in:");
		});
	} else {
	    //provide links to Firefox 3.5
	    alert("your browser doesn't support geolocation");
	}

}

function update_coords_in_form(longitude,latitude) {
	$('#event_meeting_point').val(latitude + "," + longitude);
	$('#longitude').val(longitude);
	$('#latitude').val(latitude);
}

function init_map(lat,lng){

	var map = new GMaps({
    el: el,
    lat: lat,
    lng: lng,
    zoomControl : true,
    zoomControlOpt: {
        style : 'SMALL',
        position: 'TOP_LEFT'
    },
	click : function(e){
		map.removeMarkers();
		map.addMarker({lat:e.latLng.lat(),lng:e.latLng.lng()});
		update_coords_in_form(e.latLng.lng(),e.latLng.lat());
    },
	scrollwheel: false,
    panControl : false,
    streetViewControl : false,
    mapTypeControl: false,
    overviewMapControl: false
	});

	map.addMarker({
        lat: lat,
        lng: lng,
    	infoWindow: {
			content: "Your Ride Starting Point"
		}
	});

	update_coords_in_form(lng,lat);
	return map;
}

// @@ 
// Called by: events/show
// Populates map with data from db
function init_populated_map(data,lat,lng) {
	map = new GMaps({
    el: el,
    lat: lat,
    lng: lng,
    zoomControl : true,
    zoomControlOpt: {
        style : 'SMALL',
        position: 'TOP_LEFT'
    },
    scrollwheel: false,
    panControl : false,
    streetViewControl : false,
    mapTypeControl: false,
    overviewMapControl: false
	});

	var coords = new Array();
	$.each(data["nearest_events"],function(index,value){
		var event = data["nearest_events"][index]["event"];
		var user = data["nearest_events"][index]["user"];
		var temp = new google.maps.LatLng(event["meeting_point"][1],event["meeting_point"][0]);
		coords.push(temp);
		var event_details = event_content_helper(event,data["options"]);
	
		map.addMarker({
	        lat: event["meeting_point"][1],
	        lng: event["meeting_point"][0],
	        title: event["title"],
	        animation: google.maps.Animation.DROP,
	        infoWindow: {
				content: event_details,
				maxWidth: infoWindowMaxWidth
			},
			details: {
				event_owner: { name: user["name"],
					id: user["_id"],
					bio: user["bio"]
					},
				event_id: event["_id"]
			},
			click: function(e){
				$.ajax({
					url: '/events/more_info/' + e["details"]["event_id"],
					type: 'GET'
				});
			}
		});
	});
	map.fitLatLngBounds(coords);
	return map;
}

// @@
// infoWindow - appears after clicking marker
function event_content_helper(event_content,options) {
	var content = "<h3>"+event_content["title"]+"</h3>";
	var pace = event_content["bicycle_ride"]["pace"];
	var road_type = event_content["bicycle_ride"]["road_type"];
	var terrain = event_content["bicycle_ride"]["terrain"];

	var pace_options = options[0]["options"];
	var road_type_options = options[2]["options"];
	var terrain_options = options[1]["options"];

	content+="<b>Description: </b>" + event_content["description"] + "<br><br>";
	content+="<b>Distance: </b>" + event_content["bicycle_ride"]["distance"] + " miles<br>";
	content+="<b>Pace: </b>" + pace_options[pace] + "<br>";
	content+="<b>Road Type: </b>" + road_type_options[road_type] + "<br>";
	content+="<b>Terrain: </b>" + terrain_options[terrain].replace(/'/g,"") + "<br>";
	return(content);
}

// @@
// used in events/show, events/new
// gives users the option of using an address to find desired location
function put_address_flow(map) {
	var f = document.createElement("form");
	var s = document.createElement("input");
	var t = document.createElement("input");

	f.setAttribute('id','geocoding_form');
	t.setAttribute('type','textfield');
	t.setAttribute('id','address');
	s.setAttribute('type','submit');

	f.appendChild(t);
	f.appendChild(s);
	$('#geocoding_div').append(f);

	$('#geocoding_form').before('<label>Enter an address to change your ride\'s starting position:</label><br>');

	$('#geocoding_form').submit(function(e){
		e.preventDefault();
		GMaps.geocode({
			address: $('#address').val().trim(),
			callback: function(results,status) {
				if(status=='OK') {
					var latlng = results[0].geometry.location;
					map.setCenter(latlng.lat(),latlng.lng());
					map.removeMarkers();
					map.addMarker({lat: latlng.lat(),lng: latlng.lng()});
					update_coords_in_form(latlng.lng(),latlng.lat());
				}
			}
		});
	});
}
