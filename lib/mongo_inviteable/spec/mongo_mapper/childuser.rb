class ChildUser
  include MongoMapper::Document
  include Mongo::Inviteable::Invited
  include Mongo::Inviteable::Inviter
  include Mongo::Inviteable::History
end