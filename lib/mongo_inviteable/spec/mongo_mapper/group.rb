class Group
  include MongoMapper::Document
  include Mongo::Inviteable::Invited
  include Mongo::Inviteable::History
end