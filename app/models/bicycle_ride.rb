class BicycleRide
  ##
  # A Bicycle Ride is one of many activities
  # 
  #
  include Mongoid::Document
  embedded_in :event
  #field :destination, :type => Point #longitude, latitude
  #field :loop
  field :pace, :type => Integer #1234, mellow, brisk, fast, throwdown
  field :terrain, :type => Integer #1234, flat, rollers, hilly, steep (overall)
  field :distance, :type => Integer #in miles
  field :road_type, :type => Integer #pavement, dirt-trail
  attr_accessible :road_type, :pace, :terrain, :distance, 

  ##
  # If changing the meaning of the words below, keep in mind
  # that the value (not the name) has been stored in the database.
  # Also, it's probably not a good idea to continue using this method
  # of storage for these values if you mean to change the values frequently.
  PACE = [['Mellow',1],['Brisk',2],['Fast',3],['Hammerfest',4]]
  TERRAIN = [['Flat',1],['Rollers',2],['Hilly',3],['Throwdown',4]]
  ROAD_TYPE = [['Pavement',1],['Dirt Trail',2]]

end