
function drawPolyline(polyline,map){
	if (polyline[0][0] != 0 && polyline[0][1] != 0) {
		map.draw_streams(polyline,map);
	    map.gmap.fitLatLngBounds(convert_coords_to_bounds_obj(polyline));
	}
}

function subscribeToChanges(map){
	subscribeMarkerChange(map);
	subscribeAddressFound();
	subscribeLatLngFound(map);
};