##
# Temporary storage for contacts downloaded from third party apps such as Facebook

class Contact
  include Mongoid::Document
  include Mongo::Invitable::Invited

  belongs_to :user
  field :name
  field :image
  field :fb_uid
  field :email
  field :strava_uid
  field :is_user, :default => false # is this a user that has signed up with us?
  attr_accessible :name, :image, :email, :fb_uid, :strava_uid, :is_user
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ _id: 1 }, { unique: true, background: true })

  def self.create_fb_contact(params,user)
    email = params["name"] + "@facebook.com"
    user_status = false
    user_status = Contact.is_already_a_user('fb',params["id"])
    #user.contacts << Contact.new(
    user.contacts.create(
        fb_uid: params["id"],
        name:   params["name"], 
        email:  email,
        image:  params["picture"]["data"]["url"],
        is_user: user_status
        )
  end

  def self.create_strava_contact(params,user)
    name = params["firstname"] + " " + params["lastname"]
    #user.contacts << Contact.new(
    user.contacts.create(
        strava_uid: params["id"],
        name: name, 
        email: params['email'],
        image: params["profile_medium"]
        )
  end

  ## 
  # Is the user on this app yet?
  def self.is_already_a_user(strava_or_fb,uid)
    @user = nil
    if strava_or_fb == 'strava'
      @user = User.find_by(strava_uid:uid)
    else
      @user = User.find_by(uid:uid)
    end
    if @user
      true
    else
      false
    end
  end

end