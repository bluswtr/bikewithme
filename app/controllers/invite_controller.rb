

class InviteController < ApplicationController
	before_filter :authenticate_user!, :except => [:invitation_to_bwm]

	def guestlist_all
		bikewithme_log("InviteController#guestlist_all #{current_user.contacts}")
		render :json => current_user.contacts.to_json
	end

	def guestlist_bwm
		@contacts = Array.new
		current_user.contacts.each do |contact|
			if contact.is_user
				@contacts << contact
			end
		end
		bikewithme_log("InviteController#guestlist_bwm #{@contacts}")
		render :json => @contacts.to_json
	end

	def guestlist_outsiders
		@contacts = Array.new
		current_user.contacts.each do |contact|
			if !contact.is_user
				@contacts << contact
			end
		end
		bikewithme_log("InviteController#guestlist_outsiders #{@contacts}")
		render :json => @contacts.to_json
	end

	def to_app
		@has_friends = false
		if current_user.contacts.count > 0 
			@has_friends = true
		end
		@session = "invite_to_app"
		render "invite/compose_invite"
	end

    def to_event
    	@session = "invite_to_event"
    	@event = Event.find(params[:event_id])
		render "invite/compose_invite"
    end
    
    def outsider_to_event
    	@session = "invite_outsider_to_event"
    	@event = Event.find(params[:event_id])
		render "invite/compose_invite"
    end

end