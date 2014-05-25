// Map Concerns: display, publish marker changes
// UI Concerns: change display when events occur, subscribe to relevant events

// 
// Relationships between concerns:
// Geolocation <---> UI <---> Map
//
// UI <---> Map is written with the Constructor and Publish/Subscribe Patterns
// Geolocation <---> UI is written with the Command Pattern


function Map(lat,lng,editable){
	this.div = '#map';
	this.infoWindowMaxWidth = 280;
	this.lat = lat;
	this.lng = lng;
	this.objname;
	this.editable = editable;
	this.coordinates = [];
	this.markers = [];

	if(editable) 
		{ this.gmap = this.init_editable_map(); }
	else
		{ this.gmap = this.init_map(false); }
}

Map.prototype.updateMap = function(lat,lng) {
	this.lat = lat;
	this.lng = lng;
	this.gmap.removeMarkers();
	this.gmap.addMarker({lat:this.lat,lng:this.lng});
}

Map.prototype.centerMap = function() {
	this.gmap.setCenter(this.lat,this.lng);
}


Map.prototype.init_editable_map = function(){
	this.gmap = this.init_map(true);
	return this.gmap;
}

Map.prototype.init_static_map = function(lat,lng){
	var map = init_map(false);
	return map;
}

Map.prototype.init_map = function(editable){
	bikewithme_log("map initializing");

	var triggerMarkerChange = false;
	if(editable) {
		triggerMarkerChange = function(coords){
			$(document).trigger("marker_change",[coords.latLng.lat(),coords.latLng.lng()]);}
	}

	this.gmap = new GMaps({
    el: this.div,
    lat: this.lat,
    lng: this.lng,
    zoomControl : true,
    zoomControlOpt: {
        style : 'SMALL',
        position: 'TOP_LEFT'
    },
	click : triggerMarkerChange,
	scrollwheel: false,
    panControl : false,
    streetViewControl : false,
    mapTypeControl: false,
    overviewMapControl: false
	});

	if(this.lat != false && this.lng != false) {
		var temp_marker = this.gmap.addMarker({
	        lat: this.lat,
	        lng: this.lng,
	        animation: google.maps.Animation.DROP,
	        infoWindow: {
	        	content:"Meeting Point"
	        }
		});
		// temp_marker.infoWindow.open(this.gmap,temp_marker);
		this.markers.push(temp_marker);
	}
	return this.gmap;
}

Map.prototype.draw_streams = function(polyline){
	this.gmap.drawPolyline({
	    path: polyline,
	    strokeColor: '#131540',
	    strokeOpacity: 0.6,
	    strokeWeight: 6
	});
}

Map.prototype.append = function(lat,lng,content) {
	this.coordinates.push(new google.maps.LatLng(lat,lng));

	var temp = this.gmap.createMarker({
        lat: lat,
        lng: lng,
        animation: google.maps.Animation.DROP,
       	infoWindow: {
			content: content
		}
	});
	this.gmap.addMarker(temp);
	var index = this.markers.push(temp) - 1;
	return index; //return marker index
}

Map.prototype.fitBounds = function() {
	this.gmap.fitLatLngBounds(this.coordinates);
	bikewithme_log("fit bounds: ", this.coordinates);
}
// end of map object
//@@@@@@@@@@@@@@@@@@

function convert_coords_to_bounds_obj(polylines){
	var coords = new Array();
	var lat = 0;
	var lng = 1;
	polylines.forEach(function(polyline){
		var temp = new google.maps.LatLng(polyline[lat],polyline[lng]);
		coords.push(temp);
	});
	return coords;
}

// @@
// infoWindow - appears after clicking marker
function event_content_helper(event_content,options) {
	var content = "<h3>"+event_content["title"]+"</h3>";
	var pace = event_content["bicycle_ride"]["pace"];
	var road_type = event_content["bicycle_ride"]["road_type"];
	var terrain = event_content["bicycle_ride"]["terrain"];

	var pace_options = options["pace"];
	var road_type_options = options["road_type"];
	var terrain_options = options["terrain"];

	content+="<b>Description: </b>" + event_content["description"] + "<br><br>";
	content+="<b>Distance: </b>" + event_content["bicycle_ride"]["distance"] + " miles<br>";
	content+="<b>Pace: </b>" + pace_options[pace] + "<br>";
	content+="<b>Road Type: </b>" + road_type_options[road_type] + "<br>";
	if (typeof terrain_options[terrain] != 'undefined')
		content+="<b>Terrain: </b>" + terrain_options[terrain].replace(/'/g,"") + "<br>";
	return(content);
}

// // send current geolocation to backend
// function save_geolocation() {
// 	if (navigator.geolocation) {
// 	    navigator.geolocation.getCurrentPosition(function(position){
// 			$.post("/events/save_geolocation",
// 		    	{lat:position.coords.latitude,lng:position.coords.longitude}
// 			);
// 		});
// 	}
// }

// get user's current geolocation
// // function getGeolocation
// function geolocate() {

// 	if (navigator.geolocation) {
// 	    navigator.geolocation.getCurrentPosition(function(position){
// 			var map = init_map(position.coords.latitude,position.coords.longitude,1);
// 			put_address_flow(map);
// 		},function(error){
// 			// please add in newer versions: use ip address to determine nearest location?
// 			alert("sorry, cannot get your location\n turn on your location settings in:");
// 		});
// 	} else {
// 		//provide links to Firefox 3.5
// 		alert("your browser doesn't support geolocation");
// 	}

// }

// function getNearestEvents
// should use save_geolocation
// // backend should use the geolocation that was saved
// function geolocate_nearest() {

// 	if (navigator.geolocation) {
// 	    navigator.geolocation.getCurrentPosition(function(position){
// 		    $.get("/events/nearest_json",
// 		    	{lat:position.coords.latitude,lng:position.coords.longitude},
// 		    	function(data) {
// 					init_populated_map(data,position.coords.latitude,position.coords.longitude);
// 		    	}
// 			);
// 		},function(error){

// 		    // please add in newer versions: use ip address to determine nearest location?
// 		    alert("sorry, cannot get your location\n turn on your location settings in:");
// 		});
// 	} else {
// 	    //provide links to Firefox 3.5
// 	    alert("your browser doesn't support geolocation");
// 	}

// }


