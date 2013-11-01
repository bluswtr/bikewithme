'use strict';

/* Controllers */

var inviteApp = angular.module('inviteApp', []);

inviteApp.controller('FriendListCtrl', function FriendListCtrl($scope, $http) {
	var root = window.location.host;
	var protocol = window.location.protocol;
	$http.get(protocol+'//'+root+'/users/friends').success(function(data) {
	$scope.friends = data;
	});

	$scope.orderProp = 'name';

	$scope.to_field = "";

	$scope.addFriend = function(email) {

		if($scope.to_field == "")
			$scope.to_field += email;
		else
			$scope.to_field += ", " + email;
	};
});