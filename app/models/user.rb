class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Followable::Followed
  include Mongo::Followable::Follower

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Omniauth
  field :provider
  field :uid
  devise :omniauthable, :omniauth_providers => [:facebook]

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email
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

  # 1st pass: during sign up do a diff between our db and fb data
  # 2nd pass: anytime the user requests it using the
  #           "find friend/followers" feature
  has_and_belongs_to_many :contacts 

  # mimic has_many where array of keys is in parent
  has_many :events#, inverse_of: nil # past and future


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
  index({ email: 1 }, { unique: true, background: true })
  field :name, :type => String
  validates_presence_of :name
  accepts_nested_attributes_for :contacts
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :created_at, :updated_at, :bio, :provider, :uid, :image, :contacts, :events

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

  def self.create_friendlist(auth)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    response = HTTParty.get("https://graph.facebook.com/" + auth.uid + "/friends?access_token=" + auth.credentials.token)
    #puts response.body, response.code, response.message, response.headers.inspect
    #puts response.yaml
    friendlist_hash = JSON.parse response.body
    #user.contacts << friendlist_hash["data"]

    #contact = user.contacts.create(uid:"5", name:"user mcuserton")

    friendlist_hash["data"].each do |contact|
      response = HTTParty.get("https://graph.facebook.com/" + contact["id"] + "/picture?redirect=false&access_token=" + auth.credentials.token)
      image_hash = JSON.parse response.body
      user.contacts.create(name: contact["name"], 
                           _id: contact["id"], 
                           image: image_hash["data"]["url"])
      puts "contact " + contact["name"] + "\n"
    end
  end

end
