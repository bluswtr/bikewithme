if defined?(Mongoid) or defined?(MongoMapper)
  require File.join(File.dirname(__FILE__), "mongo_invitable/core_ext/string")
  require File.join(File.dirname(__FILE__), "mongo_invitable/invited")
  require File.join(File.dirname(__FILE__), "mongo_invitable/inviter")
  require File.join(File.dirname(__FILE__), "../app/models/invit")
  require File.join(File.dirname(__FILE__), "mongo_invitable/features/history")
end