class FacebookWorker 
	include Sidekiq::Worker
	require 'open-uri'

	def perform(token,uid,db_uid)
		fb_url = "https://graph.facebook.com/"
		endpoint = "?fields=friends.fields(id,name,username,picture)&access_token="
		final_url = fb_url+uid+endpoint+token
		p final_url
		response = URI.parse(final_url).read
		friendlist_hash = JSON.parse response
		user = User.find(db_uid)
		# email = ""
		friendlist_hash["friends"]["data"].each do |contact|
			Contact.create_fb_contact(contact,user)
		end

		user.update_attribute(:update_fb_friends, false)
	end
end