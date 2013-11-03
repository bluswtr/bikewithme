class User
  include Mongoid::Document
  include Mongo::Inviteable::Invited
  include Mongo::Inviteable::Inviter
  include Mongo::Inviteable::History
end