'use strict';

/* Controllers */

var inviteApp = angular.module('inviteApp', []);
FriendListCtrl.$inject = ['$scope', '$http']; // See: A note on minification in angularjs docs
function FriendListCtrl($scope, $http) {

	$scope.orderProp = 'name';

	$scope.invited = "";

	$scope.addFriend = function(friend,link) {

		// link has to be publicly available... 
		if($('#invite-text-'+friend.fb_uid).html() == " Invite") {
			FB.ui(
				{
				  method: 'send',
				  link: link,
				  to: friend.fb_uid,
				},function(response){
					bikewithme_log("facebook response: " + response);
					$scope.updateInviteButton(response,friend.fb_uid);
				}
			);
		}
	}

	$scope.updateInviteButton = function(response,user_id) {		
		if(response == null) {
			bikewithme_log("facebook message cancelled");
		} else if(response["success"]) {
			bikewithme_log("facebook message sent");
			$.each($scope.guestlist, function(guest,value){
				if($scope.guestlist[guest]['fb_uid'] == user_id) {
					$('#invite-text-'+user_id).html('Invited');
				}
			});
		} else {
			bikewithme_log("facebook message failed to send");
		}
	}

	// filter by: "bwm", "all"
	$scope.init_guestlist = function (filter) {
		var address = window.location.protocol + '//' + window.location.host;
		var guestlist_bwm_url = address+'/invite/guestlist_bwm';
		var guestlist_all_url = address+'/invite/guestlist_all';
		var guestlist_outsiders_url = address+'/invite/guestlist_outsiders';		

		if(filter.localeCompare("bwm") == 0) {
			$scope.guestlist_url = guestlist_bwm_url;
		} else if (filter.localeCompare("all") == 0) {
			$scope.guestlist_url = guestlist_all_url;
		} else if (filter.localeCompare("outsiders") == 0) {
			$scope.guestlist_url = guestlist_outsiders_url;}

		$http.get($scope.guestlist_url).success(function(data) {
			$scope.guestlist = data;
		});	
	}
}

inviteApp.controller('FriendListCtrl',FriendListCtrl);

