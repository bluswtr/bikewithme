##
# Temporary storage for contacts downloaded from third party apps such as Facebook

class Contact
  include Mongoid::Document
  include Mongo::Invitable::Invited

  belongs_to :user
  field :name
  field :image
  field :fb_uid, :default => nil
  field :email
  field :strava_uid, :default => nil
  field :is_user, :default => nil # is this a user that has signed up with us?
  field :bwm_uid
  attr_accessible :name, :image, :email, :fb_uid, :strava_uid, :is_user, :bwm_uid
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ _id: 1 }, { unique: true, background: true })

  def self.create_fb_contact(params,user)
    # is friend a bwm user?
    bwm_user = Contact.is_already_a_user('fb',params["id"])
    # is friend in current user's contact list?
    # contact = Contact.find_by(user_id:user.id).where(fb_uid:params[:id])
    contact = Contact.where(fb_uid:params["id"]).find(user_id:user.id)

    if bwm_user && contact
      puts "@@@@@@@@@@@@@@@@ bwm_user && contact"
      contact.is_user = true
      contact.save
    elsif bwm_user && !contact
      puts "@@@@@@@@@@@@@@@@ bwm_user && !contact"
      user.contacts.create(
        fb_uid: params["id"],
        name:   params["name"], 
        email:  params["username"] + '@facebook.com',
        image:  params["picture"]["data"]["url"],
        is_user: true
        )
    elsif !bwm_user && contact
      # do nothing
      puts "@@@@@@@@@@@@@@@@ !bwm_user && contact"
    elsif !bwm_user && !contact
      puts "@@@@@@@@@@@@@@@@ !bwm_user && !contact"
      user.contacts.create(
          fb_uid: params["id"],
          name:   params["name"], 
          email:  params["username"] + '@facebook.com',
          image:  params["picture"]["data"]["url"].to_s,
          is_user: false
          )
    end
  end

  ##
  # New user's may have been invited by a friend
  # So their contact record may be somewhere in the database
  # and we want their friends to know when they've signed up
  # Thus we need to flag
  # those contact records to reflect new status as a bwm user
  def self.update_new_user_contact(fb_uid,strava_uid,current_user_url)
    if !fb_uid.blank?
      bwm_user = Contact.is_already_a_user('fb',fb_uid)
    elsif !strava_uid.blank?
      bwm_user = Contact.is_already_a_user('strava',strava_uid)
    end

    if bwm_user && !fb_uid.blank? # loop thru all contacts and update is_user = true
      @contacts = Contact.where(fb_uid:fb_uid)
    elsif bwm_user && !strava_uid.blank?
      @contacts = Contact.where(strava_uid:strava_uid)
    end

    # update each friend's contact document and status feed w/ new user's status
    unless @contacts.blank?
      @contacts.each do |contact|
        contact.is_user = true
        contact.save
      end
    end
  end

  def self.create_strava_contact(params,user)
    name = params["firstname"] + " " + params["lastname"]
    bwm_user = Contact.is_already_a_user("strava",strava_uid:params["id"])

    if bwm_user
      contact = Contact.find_by(strava_uid,params["id"])
      contact.is_user = true
      contact.save
    else
      user.contacts.create(
          strava_uid: params["id"],
          name: name, 
          email: params["email"],
          image: params["profile_medium"],
          is_user: false
          )
    end
  end

  ## 
  # Is the user on this app yet?
  def self.is_already_a_user(service,uid)
    @user = nil
    if service == 'strava'
      @user = User.find_by(strava_uid:uid)
    elsif service == 'fb'
      @user = User.find_by(uid:uid)
    end

    if @user.blank?
      false
    else
      true
    end
  end

end