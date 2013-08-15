class Contact
  include Mongoid::Document
  include Mongo::Followable::Followed

  has_and_belongs_to_many :users
  field :name
  field :image
  field :_id, :type => Moped::BSON::ObjectId
  field :email
  # field :uid
  attr_accessible :name, :image, :email
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ _id: 1 }, { unique: true, background: true })
end