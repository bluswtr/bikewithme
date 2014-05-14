function isEmpty(str) {
    return (!str || 0 === str.length);
}

function isBlank(str) {
    return (!str || /^\s*$/.test(str));
}

var BIKEWITHME_DEBUG_ON = true;

function bikewithme_log(string,obj){
	if(BIKEWITHME_DEBUG_ON)
		console.log(string,obj);
}
