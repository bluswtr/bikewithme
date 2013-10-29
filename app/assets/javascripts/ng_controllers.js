'use strict';

/* Controllers */

var inviteApp = angular.module('inviteApp', []);

inviteApp.controller('FriendListCtrl', function FriendListCtrl($scope, $http) {
  $http.get('http://localhost:3000/users/friends').success(function(data) {
    $scope.friends = data;
  });

  $scope.orderProp = 'name';
});