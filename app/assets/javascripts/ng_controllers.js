'use strict';

/* Controllers */

var inviteApp = angular.module('inviteApp', []);

inviteApp.controller('FriendListCtrl', function FriendListCtrl($scope, $http) {

	$scope.orderProp = 'name';

	$scope.invited = "";

	$scope.addFriend = function(fb_uid,name,link,event_id) {


		FB.ui({
		  method: 'send',
		  link: link,
		  to: fb_uid
		});

		// remove new guest from 'not_yet_invited', add to 'invited'
		var index_to_delete = null;
		$.each($scope.not_yet_invited, function(index,value){
			if($scope.not_yet_invited[index]['fb_uid'] == fb_uid) {
				console.log($scope.not_yet_invited[index]["name"]);
				$scope.invited.push($scope.not_yet_invited[index]);
				index_to_delete = index;
			}
		});

		// js is unhappy about deleting things while still looping through it. So, deleting after it's done looping
		if(index_to_delete != null)
			$scope.not_yet_invited.splice(index_to_delete,1);
	};

	$scope.init = function (event_id) {
		var root = window.location.host;
		var protocol = window.location.protocol;

		// pull invite list from database, set to angular variables
		$scope.invited_url = protocol+'//'+root+'/events/'+event_id+'/invite/invited';
		$scope.not_yet_invited_url = protocol+'//'+root+'/events/'+event_id+'/invite/not_yet_invited';
		$http.get($scope.invited_url).success(function(data) {
			$scope.invited = data;
		});
		$http.get($scope.not_yet_invited_url).success(function(data) {
			$scope.not_yet_invited = data;
		});
	}
});
