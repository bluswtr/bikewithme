class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Followable::Followed
  include Mongo::Joinable::Joined
  include Mongo::Invitable::Invited
  include Mongo::Invitable::Inviter

  include Geocoder::Model::Mongoid

  # TODO: error check if we hit Google's geocoding limit
  reverse_geocoded_by :coordinates, :skip_index =>true, :coordinates => :meeting_point
  after_validation :reverse_geocode#, if: ->(obj){ obj.address.present? and obj.address_changed? }  # auto-fetch address
  
  ##
  # BikeWithMe's definition of an Event:
  # An event is defined by any activity at a 
  # certain location and time. Time is a differentiator.
  # Currently, we are focusing on deploying with cyclists as our
  # clientbase, so the default activity is bicycle_ride
  #

  ##
  # Is followed by users but
  # Events don't follow anything

  field :title
  field :strava_activity_id, :type => Integer
  field :event_date, :type => Time

  ##
  # Geospatial 2dsphere 
  # Mongodb expects an array with two floats in it. 
  # Like so: [longitude,latitude]
  # Example: [37.71618004133281,-122.44663953781128]
  #field :coordinates, :type => Array
  field :meeting_point, :type => Array
  field :address

  ##
  # Polyline, Array of geo coordinates
  # An array of arrays... [[37.71618004133281,-122.44663953781128],[37.71618004133281,-122.54543781128]...]
  field :polyline, :type => Array, :default => [[0,0]]

  field :altitude, :type => Array, :default => [0,0]

  field :city

  field :state

  ##
  # To embed other types of activities add:
  # 
  # => embeds_one :activity_model
  #
  # Then in EventController, code the
  # activity in a switch statement  
  # for each create, read, update, delete
  #

  field :description
  field :activity_id, :type => Integer

  ##
  # When creating a new document, a field from bicycle_ride model needs to be filled
  embeds_one :bicycle_ride
  belongs_to :user
  field :is_private, :type => Boolean, :default => 0
  field :publishing_status, :default => 'false' # modes: published, draft, false (ie: downloaded from strava)

  attr_accessible :activity_id,:title,:date,:bicycle_ride,:activity,:description,:meeting_point,:event_date,:is_private,:polyline,:strava_activity_id, :publishing_status, :altitude,:address

  # example: index({ loc: "2d" }, { min: -200, max: 200 }).
  # chose 2dsphere over 2d because it has more features and 2d is largely a legacy index
  index({ meeting_point: '2dsphere' }, { unique: true, background: true })

  # Other Fields to Consider
  # has_many :tags #commute, training, fun, recovering
  # has_many :activities #eat, bike, swim #has pointer to activity-related details

  ACTIVITY = ['Bicycle Ride',1]

  def coordinates
    meeting_point
  end

  def self.private_only(lnglat,distance)
    Event.where(is_private: "1").desc.geo_near(lnglat).max_distance(distance).spherical
  end

  def self.public_only(lnglat,distance)
    Event.where(is_private: "0").geo_near(lnglat).max_distance(distance).spherical
  end

  def self.friends_only(lnglat,distance,user)
    # find friends aka: a user's follows who are also contacts

    @following = user.followees_by_type("user")
    @events = []
    no_results = ->(obj){ if obj == 0 || obj == nil then return true end }

    unless no_results.call(@followers)
      @following.each do |a_follow| # check if follower is friend/contact of current_user
        friend = user.contacts.find(a_follow)
        unless !friend
          @a_friends_events = a_follow.joinees_by_type("event") 
          @a_friends_events.each do |event|
            # push to @events, unless the event is private
            unless event.is_private
              @events.push(event);
            end
          end
        end
      end
      Event.desc.limit(query_limit).geo_near(lnglat).max_distance(distance).spherical.find(@events)
    end
  end

  def self.nearest(event_filter,lnglat,current_user)
    vicinity = 50 # miles
    query_limit = 10
    distance = vicinity.fdiv(111.12) # convert from degree to miles

    events = case
      when event_filter == "friends" then Event.friends_only(lnglat,distance,current_user)
      when event_filter == "public" then Event.public_only(lnglat,distance)
      when event_filter == "private" then Event.private_only(lnglat,distance)
    end
  end

  def self.update_time(event,year,month,day,hour,minute)
    event.event_date = Time.utc(year,month,day,hour,minute)
    event.save
    event
  end

  ## 
  # is_private -> true/false
  def self.update_is_private(event,is_private)
    event.is_private = is_private
    event.save
    event
  end

  def self.update_publishing_status(event,publishing_status)
    event.publishing_status = publishing_status
    event.save
    event
  end

  def self.create_custom(user,params)
    ##
    # About mongodb geospatial insertions: mongodb will take an array with two 
    # values, convert the first into longitude and the next into latitude.
    longitude = params["longitude"].to_f
    latitude = params["latitude"].to_f 
    date = Time.utc(params["event_date"]["year"],params["event_date"]["month"],params["event_date"]["day"],params["event_date"]["hour"],params["event_date"]["minute"])
    @event =  user.events.create( 
                title:params["event"]["title"],
                meeting_point:[longitude,latitude],
                event_date:date,
                is_private:params["event"]["is_private"],
                description:params["event"]["description"],
                activity_id:params["event"]["activity_id"],
                bicycle_ride:
                  {
                    pace:params["bicycle_ride"]["pace"],
                    terrain:params["bicycle_ride"]["terrain"],
                    distance:params["bicycle_ride"]["distance"],
                    road_type:params["bicycle_ride"]["road_type"]
                  }
              )
  end

  # strava stream hash
  # creating: name,activity_id,distance,elevation_gain
  def self.create_stream(params,user,polyline,altitude)
    @event =  user.events.create(
                strava_activity_id:params['id'],
                title:params['name'],
                event_date:params['start_date'],
                meeting_point:[polyline['data'][0][1].to_f,polyline['data'][0][0].to_f],
                polyline:polyline['data'],
                altitude:altitude['data'],
                bicycle_ride:
                  {
                    distance:(params['distance']/5280).floor,
                    elevation_gain:params['total_elevation_gain']
                  }
              )
  end

  def self.update_default(params)
    event = Event.find(params[:id])
    longitude = params["longitude"].to_f
    latitude = params["latitude"].to_f
    date = Time.utc(params["event_date"]["year"],params["event_date"]["month"],params["event_date"]["day"],params["event_date"]["hour"],params["event_date"]["minute"])
    
    event.title = params[:event][:title]
    event.description = params[:event][:description]
    event.meeting_point = [longitude,latitude]
    event.event_date = date
    event.is_private = params[:event][:is_private]
    event.bicycle_ride.distance = params[:bicycle_ride][:distance]
    event.bicycle_ride.pace = params[:bicycle_ride][:pace]
    event.bicycle_ride.terrain = params[:bicycle_ride][:terrain]
    event.bicycle_ride.road_type = params[:bicycle_ride][:road_type]

    if event.changed?
      event.save
    end
    event
  end
end