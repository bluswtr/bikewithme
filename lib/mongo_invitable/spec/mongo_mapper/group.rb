class Group
  include MongoMapper::Document
  include Mongo::Invitable::Invited
  include Mongo::Invitable::History
end