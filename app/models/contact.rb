class Contact
  include Mongoid::Document

  has_and_belongs_to_many :users
  field :name
  field :image
  field :uid
  attr_accessible :name, :uid, :image
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ uid: 1 }, { unique: true, background: true })
end