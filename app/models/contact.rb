##
# Temporary storage for contacts downloaded from third party apps such as Facebook

class Contact
  include Mongoid::Document
  include Mongo::Invitable::Invited

  has_and_belongs_to_many :users
  field :name
  field :image
  field :fb_uid
  field :email
  field :strava_uid
  # field :uid
  attr_accessible :name, :image, :email, :fb_uid, :strava_uid
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ _id: 1 }, { unique: true, background: true })

  def self.create_fb_contact(params,user)
    email = contact["username"] + "@facebook.com"
    user.contacts << Contact.new(
        fb_uid: contact["id"],
        name:   contact["name"], 
        email:  email,
        image:  contact["picture"]["data"]["url"]
        )
  end

  def self.create_strava_contact(params,user)
    name = params["firstname"] + " " + params["lastname"]
    user.contacts << Contact.new(
        strava_uid: params["id"],
        name: name, 
        image: params["profile_medium"]
        )
  end

end