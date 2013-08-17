

class FollowController < ApplicationController	

	def update
		# in template check if already following 
		# create a button that corresponds to that state
		@user = User.find(params[:id])
		current_user.follow(@user)

		# send back http success
		# if @contact.followed? head :created else head :not_found end
		# head :created
		render nothing: true
	end 
end

##
# How the gem 'mongo_followable' works:
# f_id and followable_id each represent the actual User _id in the User model
# followable_id follows f_id
# f_id is being followed by followable_id
#

##
# Example of what the follow document in mongodb looks like when
# user: 520e9c1ec7471830e5000001 follows both
# user: 520e9c1fc7471830e5000004 & user: 520e9c1fc7471830e5000005
#

##
# Relationship documents are created:
#
# > db.follows.find().pretty()
# {
# 	"_id" : ObjectId("520e9c43c747189e0100000d"),
# 	"f_type" : "User",
# 	"f_id" : "520e9c1ec7471830e5000001",
# 	"followable_id" : ObjectId("520e9c1fc7471830e5000005"),
# 	"followable_type" : "User"
# }
# {
# 	"_id" : ObjectId("520e9c43c747189e0100000e"),
# 	"f_type" : "User",
# 	"f_id" : "520e9c1fc7471830e5000005",
# 	"following_id" : ObjectId("520e9c1ec7471830e5000001"),
# 	"following_type" : "User"
# }
# {
# 	"_id" : ObjectId("520e9cfac747189e0100000f"),
# 	"f_type" : "User",
# 	"f_id" : "520e9c1ec7471830e5000001",
# 	"followable_id" : ObjectId("520e9c1fc7471830e5000004"),
# 	"followable_type" : "User"
# }
# {
# 	"_id" : ObjectId("520e9cfac747189e01000010"),
# 	"f_type" : "User",
# 	"f_id" : "520e9c1fc7471830e5000004",
# 	"following_id" : ObjectId("520e9c1ec7471830e5000001"),
# 	"following_type" : "User"


