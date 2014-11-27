class UsersController < ApplicationController
	before_filter :authenticate_user!

	def index
		# find friends on bwm and find out if already following by returning @user objects
		@contacts = current_user.contacts.where(is_user:true)

		@users = Array.new
		@following = Array.new
		unless @contacts.blank?
			@contacts.each do |contact|
				if !contact.fb_uid.blank?
					@user = User.find_by(uid:contact.fb_uid)
				elsif !contact.strava_uid.blank?
					@user = User.find_by(strava_uid:contact.strava_uid)
				end

				unless @user.blank?
					@users << @user
					if current_user.follower_of?(@user)
						@following << @user
					end
				end
			end
		end
	end

	def show
		@user = User.find(params[:id])
	end

	def followers
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def following #user's follow list
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def my_watches
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def my_joins
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def friends
		@friend_ids = current_user.contact_ids
		@friends = current_user.contacts.find(@friend_ids)
		render :json => @friends.to_json
	end

	##
	# Show activity current_user's follow list
	def status_feed
		# get following list
		@user = User.find(current_user.id)
		following_ids = []
		@microposts = nil
		@count = @user.followees_count_by_type("user")

		if @count > -1
			following_list = @user.followees_by_type("user")
			following_list.each do |following|
     			following_ids.push(following._id)
     		end
     		# business logic: add current_user's history as well
     		puts "@@@@@@@@@@@@@@@@@ following_ids"
     		p following_ids
     		puts "current_user.id"
     		p current_user
     		following_ids << current_user._id
			@microposts = Micropost.in(user:following_ids).limit(30).order_by(:created_at.desc)
		end
		render 'users/feed'
	end

	def invitation
		render 'users/invitation'
	end
end