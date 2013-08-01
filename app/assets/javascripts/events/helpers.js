
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
					//map.removeMarkers();
          			//map.addMarker({lat:e.latLng.jb,lng:e.latLng.kb});
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
					//$('#event_meeting_point').val(latlng.lng() + "," + latlng.lat());
					update_coords_in_form(latlng.lng(),latlng.lat())
				}
			}
		});
	});
}
