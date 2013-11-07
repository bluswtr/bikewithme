require "spec_helper"
require "benchmark"

users = []
1000.times { users << User.create! }
group = Group.create!

users.each { |u| u.invit(group) }

Benchmark.bmbm do |x|
  x.report("before") { group.inviters }
end

RSpec.configure do |c|
  c.before(:all)  { DatabaseCleaner.strategy = :truncation }
  c.before(:each) { DatabaseCleaner.clean }
end
