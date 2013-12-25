'use strict';

/* Controllers */

var inviteApp = angular.module('inviteApp', []);
FriendListCtrl.$inject = ['$scope', '$http']; // See: A note on minification in angularjs docs
function FriendListCtrl($scope, $http) {

	$scope.orderProp = 'name';

	$scope.invited = "";

	$scope.addFriend = function(friend,link,event_id) {

		FB.ui(
			{
			  method: 'send',
			  link: link + '?id=' + friend._id,
			  to: friend.fb_uid,
			});

		// update arrays if send button was clicked
		// bug alert: preferrably executed after user clicks but no callback available from facebook send module. therefore this executes EVERYTIME. solutions, ideas?
		var index_to_delete = null;
		$.each($scope.not_yet_invited, function(index,value){
			if($scope.not_yet_invited[index]['fb_uid'] == fb_uid) {
				//console.log($scope.not_yet_invited[index]["name"]);
				$scope.invited.push($scope.not_yet_invited[index]);
				index_to_delete = index;
			}
		});
		if(index_to_delete != null)
			$scope.not_yet_invited.splice(index_to_delete,1);
	}

	$scope.init = function (event_id,current_user_id) {
		var root = window.location.host;
		var protocol = window.location.protocol;

		// pull invite list from database, set to angular variables
		$scope.invited_url = protocol+'//'+root+'/events/'+event_id+'/invite/invited';
		$scope.not_yet_invited_url = protocol+'//'+root+'/events/'+event_id+'/invite/not_yet_invited';
		$scope.followed =  protocol+'//'+root+'/users/'+current_user_id+'/followers';
		$scope.following =  protocol+'//'+root+'/users/'+current_user_id+'/following';
		$http.get($scope.invited_url).success(function(data) {
			$scope.invited = data;
		});
		$http.get($scope.not_yet_invited_url).success(function(data) {
			$scope.not_yet_invited = data;
		});
	}
}

inviteApp.controller('FriendListCtrl',FriendListCtrl);

