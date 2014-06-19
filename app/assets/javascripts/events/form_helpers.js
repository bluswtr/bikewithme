function update_address(string) {
	bikewithme_log("update_address");
	$('#event_address').val(string);
}

function update_coords(lat,lng){
	$('#longitude').val(lng);
	$('#latitude').val(lat);
}

function saveTimeZoneOffset(url){
	var date = new Date();
	var currentTimeZoneOffsetInMinutes = date.getTimezoneOffset();
	$.post(url,{offset:currentTimeZoneOffsetInMinutes});
	bikewithme_log("saveTimeZoneOffset: " + currentTimeZoneOffsetInMinutes);
}
