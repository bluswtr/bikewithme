class Contact
  include Mongoid::Document
  include Mongo::Followable::Followed

  has_and_belongs_to_many :users
  field :name
  field :image
  field :_id
  # field :uid
  attr_accessible :name, :_id, :image
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ _id: 1 }, { unique: true, background: true })
end