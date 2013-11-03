class Group
  include Mongoid::Document
  include Mongo::Inviteable::Invited
  include Mongo::Inviteable::History
end