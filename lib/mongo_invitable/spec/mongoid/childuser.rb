class ChildUser
  include Mongoid::Document
  include Mongo::Invitable::Invited
  include Mongo::Invitable::Inviter
  include Mongo::Invitable::History
end