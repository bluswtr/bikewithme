

class InviteController < ApplicationController
	before_filter :authenticate_user!, :except => [:invitation]

	def create
		event = Event.find(params[:event_id])
		@contact = Contact.find(params[:contact_id])
		event.invit(@contact) # create invite for contact
		render nothing: true
	end

	def new
		@event = Event.find(params[:event_id])
		render "events/compose_invite"
	end

	def invited
		# verify login and is owner
		@event = Event.find(params[:event_id])
		@invited = @event.all_invitees
		render :json => @invited.to_json
	end

	def not_yet_invited
		friend_ids = current_user.contact_ids
		
		@event = Event.find(params[:event_id])
		invited_ids = []
		@event.all_invitees.each do |invitee|
			invited_ids.push(invitee.id)
		end
		not_yet_invited = []
		not_yet_invited = friend_ids.select { |friend_id| !invited_ids.include?(friend_id) }

		@not_yet_invited = current_user.contacts.find(not_yet_invited).where(:fb_uid.gt => 0)
		render :json => @not_yet_invited.to_json
	end

	def invitation
		@event = Event.find(params[:event_id])
		@descriptors = Descriptor.format_for_option_tag(1)
		# current_user.followee_of?(@group)
		invited = is_invited(params[:contact_id],@event)
		#puts "is_invited? #{invited}"
		if !invited
			redirect_to root_url(), notice: "We are so sorry but that invitation doesn't exist. Want to join a public ride instead?"
		end
	end

	def is_invited(contact_id,event_obj)
		is_invited = false
		if contact_id != nil
			contact = Contact.find(contact_id)
			if contact != nil
				is_invited = contact.invitee_of?(event_obj)
			end
		else
			flash.now[:notice] = "We are so sorry but that invitation doesn't exist. Want to join a public ride instead?"
		end
		is_invited
	end
end