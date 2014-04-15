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
  field :distance, :type => Integer, :default => 0 #in miles
  field :road_type, :type => Integer #pavement, dirt-trail
  field :total_elevation_gain, :type => Float
 
  ##
  # Polyline, Array of geo coordinates
  # An array of arrays... [[37.71618004133281,-122.44663953781128],[37.71618004133281,-122.54543781128]...]
  field :polyline, :type => Array, :default => [[0,0]]
  field :altitude, :type => Array, :default => [0,0]

  attr_accessible :road_type, :pace, :terrain, :distance,:total_elevation_gain,:altitude,:polyline


  ##
  # Arrays
  # If changing the meaning of the words below, keep in mind
  # that the value (not the name) has been stored in the database.
  # Also, it's probably not a good idea to continue using this method
  # of storage for these values if you mean to change the values frequently.
  # PACE = [['Mellow',1],['Brisk',2],['Fast',3],['Hammerfest',4]]
  # TERRAIN = [['Flat',1],['Rollers',2],['Hilly',3],['Steep',4]]
  # ROAD_TYPE = [['Pavement',1],['Dirt Trail',2]]

end