class Micropost
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  field :content
  field :created_at, :type => Time

  def self.create(user,content)
  	@micropost = user.microposts.create(
  		content: content,
  		created_at: Time.current.utc)
  	@micropost
  end

  def self.delete(user,micropost)
  	user.micropost.delete(micropost)
  end
end
