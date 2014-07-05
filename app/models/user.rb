

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Followable::Followed
  include Mongo::Followable::Follower
  include Mongo::Joinable::Joined
  include Mongo::Joinable::Joiner
  include Mongo::Invitable::Invited
  include Mongo::Invitable::Inviter

  ##
  # A user can follow another user or an event

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Omniauth
  field :provider #answers the question signed in as... facebook or strava user?
  devise :omniauthable, :omniauth_providers => [:facebook, :strava]

  # Facebook
  field :uid

  # Strava
  field :strava_uid, :default => ""

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :encrypted_password
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Profile
  field :bio
  field :image

  has_many :contacts

  has_many :microposts

  ##
  # Can create many events and thusly serves as the document owner
  # by default. In the app, owner shows up as the organizer
  has_many :events

  # Does the user's facebook friend list need to be updated? State goes here.
  field :update_fb_friends, :type => Boolean, :default => 1
  field :update_strava_objects, :type => Boolean, :default => 1

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  # run 'rake db:mongoid:create_indexes' to create indexes
  # An index w/ a value of 1 specifies an index that orders items in ascending order. A value of -1 specifies an index that orders items in descending order.
  index({ email: 1 }, { unique: true, background: true })
  index({ uid: 1, strava_uid: 1 }, { background: true })
  field :name, :type => String
  validates_presence_of :name
  accepts_nested_attributes_for :contacts
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :created_at, :updated_at, :bio, :provider, :uid, :image, :contacts, :events, :update_strava_objects, :microposts, :contacts, :strava_uid

  ## Omniauth-Facebook Helpers
  # check with our db and see if this user exists
  # create a new user in our db if this user does not exist
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user 
      user = User.create(name:auth.extra.raw_info.name,
                         provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email,
                         password:Devise.friendly_token[0,20],
                         image:auth.info.image
                         )
    end
    user
  end

  ## Populate our user object with data from Facebook?
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  ## Strava Helpers
  # check with our db and see if this user exists
  # create a new user in our db if this user does not exist
  def self.find_for_strava_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.strava_uid).first
    unless user 
      user = User.create(name:auth.info.name,
                         provider:auth.provider,
                         strava_uid:auth.uid,
                         email:auth.info.email,
                         password:Devise.friendly_token[0,20],
                         image:auth.info.profile_medium
                         )
    end
    user
  end
end
