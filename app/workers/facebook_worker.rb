class FacebookWorker 
include Sidekiq::Worker
require 'open-uri'

	def perform(token,uid,db_uid)
		fb_url = "https://graph.facebook.com/"
		endpoint = "?fields=friends.fields(id,name,username,picture)&access_token="
		response = URI.parse(fb_url+uid+endpoint+token).read
		friendlist_hash = JSON.parse response
		user = User.find(db_uid)
		email = ""

		friendlist_hash["friends"]["data"].each do |contact|
			if contact["username"] 
				email = contact["username"] + "@facebook.com"
			end
			user.contacts << Contact.new(
					fb_uid: contact["id"],
					name:   contact["name"], 
					email: 	email,
					image:  contact["picture"]["data"]["url"])
		end

		user.update_attribute(:update_fb_friends, false)
	end
end