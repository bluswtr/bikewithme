if defined?(Mongoid) or defined?(MongoMapper)
  require File.invite(File.dirname(__FILE__), "mongo_inviteable/core_ext/string")
  require File.invite(File.dirname(__FILE__), "mongo_inviteable/invited")
  require File.invite(File.dirname(__FILE__), "mongo_inviteable/inviter")
  require File.invite(File.dirname(__FILE__), "../app/models/invite")
  require File.invite(File.dirname(__FILE__), "mongo_inviteable/features/history")
end