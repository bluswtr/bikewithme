class ChildUser
  include MongoMapper::Document
  include Mongo::Invitable::Invited
  include Mongo::Invitable::Inviter
  include Mongo::Invitable::History
end