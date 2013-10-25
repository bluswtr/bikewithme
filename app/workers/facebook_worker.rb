class FacebookWorker 
include Sidekiq::Worker
require 'open-uri'

	def perform(token,uid,db_uid)
		#fb_url = "https://graph.facebook.com/656118299?fields=id,name,friends.fields(picture)"
		fb_url = "https://graph.facebook.com/"
		#pic_endpnt = "/picture?redirect=false&access_token="
		#friends_endpnt = "/friends?access_token="
		endpoint = "?fields=friends.fields(id,name,username,picture)&access_token="
		#response = URI.parse(fb_url+uid+friends_endpnt+token).read
		response = URI.parse(fb_url+uid+endpoint+token).read
		friendlist_hash = JSON.parse response

		user = User.find(db_uid)

		friendlist_hash["friends"]["data"].each do |contact|
			# id = contact["id"].to_s
			# img_response = URI.parse(fb_url+id+pic_endpnt+token).read
			# image_hash = JSON.parse img_response
			# user.contacts << Contact.new(
			# 				fb_uid: contact["id"],
			# 				name:   contact["name"], 
			# 				email: 	contact["username"] + "@facebook.com",
			# 				image:  contact["picture"]["data"]["url"])
		end
		user.update_attribute(:update_fb_friends, false)
	end
end