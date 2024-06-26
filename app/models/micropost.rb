class Micropost
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  validates_presence_of :content, length: { maximum: 200 }
  field :content
  field :created_at, :type => Time

  def self.create(user,content)
  	@micropost = user.microposts.create(
  		content: content,
  		created_at: Time.current.utc)
  	@micropost
  end

end
