

class InviteController < ApplicationController
	before_filter :authenticate_user!

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

		@not_yet_invited = current_user.contacts.find(not_yet_invited)
		render :json => @not_yet_invited.to_json
	end

	def invitation
		@event = Event.find(params[:event_id])
		@descriptors = Descriptor.format_for_option_tag(1)
	end
end