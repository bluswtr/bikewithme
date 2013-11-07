class Group
  include Mongoid::Document
  include Mongo::Invitable::Invited
  include Mongo::Invitable::History
end