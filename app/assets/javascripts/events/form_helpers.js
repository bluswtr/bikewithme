

function update_address(string) {
	bikewithme_log("update_address");
	$('#event_address').val(string);
}

function update_coords(lat,lng){
	$('#longitude').val(lng);
	$('#latitude').val(lat);
}
