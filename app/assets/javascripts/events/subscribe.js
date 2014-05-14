function subscribeMarkerChange(map){
	$(document).on("marker_change",function(event,lat,lng){
		map.updateMap(lat,lng);
		update_coords(lat,lng);
		geocodeLatlng(map.lat,map.lng);
	});
}

function subscribeAddressFound(){
	$(document).on("address_found",function(event,status,address,lat,lng){
			if(status=='OK') {
				update_address(address);
				update_coords(lat,lng)
			}
	});
}

function subscribeLatLngFound(map){
	$(document).on("latlng_found",function(event,status,lat,lng){
			if(status=='OK') {
				map.updateMap(lat,lng);
				map.centerMap();
				update_coords(lat,lng);
			}
	});
}