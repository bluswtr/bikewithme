class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ##
  # An event is defined by any activity at a 
  # certain location and time. Time is a differentiator.
  # Currently, we are focusing on deploying with cyclists as our
  # clientbase, so the default activity is bicycle_ride
  #

  field :title
  field :date, :type => Time
  #field :meeting_point, :type => Point #longitude, latitude (an index)
  field :meeting_point, :type => Array 
  # field: address # a feature for later
  ##
  # To embed other types of activities add:
  # 
  # => embeds_one :activity_model
  #
  # Then in EventController, put the
  # activity in a switch statement  
  # for each create, read, update, delete
  #

  field :description
  field :activity, :type => Integer
  embeds_one :bicycle_ride

  #belongs_to :user #event organizer
  #has_and_belongs_to_many :users
  #has_many :contacts #followers
  attr_accessible :title, :date, :bicycle_ride, :activity, :description, :meeting_point

  # example: index({ loc: "2d" }, { min: -200, max: 200 }).
  index({ meeting_point: '2d' }, { background: true })
  # Other Fields to Consider
  # has_many :tags #commute, training, fun, recovering
  # has_many :activities #eat, bike, swim #has pointer to activity-related details

  ACTIVITY = ['Bicycle Ride',1]

end