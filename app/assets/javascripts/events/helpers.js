
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
		    		console.log(data);
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
	$('#event_meeting_point').val(longitude + "," + latitude);
	$('#longitude').val(longitude);
	$('#latitude').val(latitude);
}

function init_map(curr_lat,curr_lng,click_callback){

	var map = new GMaps({
    el: '#map',
    lat: curr_lat,
    lng: curr_lng,
    zoomControl : true,
    zoomControlOpt: {
        style : 'SMALL',
        position: 'TOP_LEFT'
    },

	click : function(e){
          //console.log(e);
          map.removeMarkers();
          // jb = latitude, kb = longitude
          map.addMarker({lat:e.latLng.jb,lng:e.latLng.kb});
          update_coords_in_form(e.latLng.kb,e.latLng.jb)
          console.log(map);
    },

    panControl : false,
    streetViewControl : false,
    mapTypeControl: false,
    overviewMapControl: false
	});

	map.addMarker({
        lat: curr_lat,
        lng: curr_lng,
        title: 'Your Location',
        infoWindow: {
		  content: '<p>HTML Content</p>'
		}
	});

	update_coords_in_form(curr_lng,curr_lat);
	return map;
}

function init_populated_map(data,lat,lng) {
	var map = new GMaps({
    el: '#map',
    lat: lat,
    lng: lng,
    zoomControl : true,
    zoomControlOpt: {
        style : 'SMALL',
        position: 'TOP_LEFT'
    },

    panControl : false,
    streetViewControl : false,
    mapTypeControl: false,
    overviewMapControl: false
	});

	data["nearest_events"].forEach(function(event){
	var event_details = content_helper(event,data["options"]);
		map.addMarker({
	        lat: event["meeting_point"][1],
	        lng: event["meeting_point"][0],
	        title: event["title"],
	        infoWindow: {
			  content: event_details
			}
		});

	});


	return map;
}

function content_helper(event_content,options) {
	var content = "<h3>"+event_content["title"]+"</h3>";
	var pace = event_content["bicycle_ride"]["pace"];
	var road_type = event_content["bicycle_ride"]["road_type"];
	var terrain = event_content["bicycle_ride"]["terrain"];

	content+="<b>Description: </b>" + event_content["description"] + "<br><br>";
	content+="<b>Distance: </b>" + event_content["bicycle_ride"]["distance"] + " miles<br>";
	content+="<b>Pace: </b>" + options["pace"][pace] + "<br>";
	content+="<b>Road Type: </b>" + options["terrain"][terrain] + "<br>";
	content+="<b>Terrain: </b>" + options["road_type"][road_type].replace(/'/g,"") + "<br>";
	return(content);
}

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

	$('#geocoding_form').before('<label>Address</label><br>');

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
