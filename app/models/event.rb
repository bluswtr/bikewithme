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

  attr_accessible :activity_id,:title,:date,:bicycle_ride,:activity,:description,:meeting_point,:event_date,:is_private,:strava_activity_id, :publishing_status,:address

  # example: index({ loc: "2d" }, { min: -200, max: 200 }).
  # chose 2dsphere over 2d because it has more features and 2d is largely a legacy index
  # compound index because it is possible to clone events such that the meeting point is the same
  index({ meeting_point: '2dsphere', event_date: 1 }, { sparse: true, unique: true, background: true })

  # Other Fields to Consider
  # has_many :tags #commute, training, fun, recovering
  # has_many :activities #eat, bike, swim #has pointer to activity-related details

  ACTIVITY = ['Bicycle Ride',1]


  ##
  # Scopes
  ############################################
  scope :published, -> { where(:publishing_status => 'published') }
  scope :drafts, -> { where(:publishing_status => 'draft').order_by(:updated_at.desc) }
  # scope :published_and_drafts, -> { where(:publishing_status => 'published').union.in(:publishing_status => 'draft')}
  scope :future_events, -> { where(:event_date.gte => Time.now) }
  scope :past_events, -> { where(:event_date.lt => Time.now) }
  scope :from_strava, -> { where(:strava_activity_id.gt => 0)}


  ##
  # Class Methods
  ############################################

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
    vicinity = 0.2 # miles
    query_limit = 10
    distance = vicinity.fdiv(111.12) # convert from degree to miles

    events = case
      when event_filter == "friends" then Event.friends_only(lnglat,distance,current_user)
      when event_filter == "public" then Event.public_only(lnglat,distance)
      when event_filter == "private" then Event.private_only(lnglat,distance)
    end
  end

  def self.geocoder_search(ip_latlng_address)
    address = Geocoder.search(ip_latlng_address)
  end

  def self.create_custom(user,params)
    ##
    # About mongodb geospatial insertions: mongodb will take an array with two 
    # values, convert the first into longitude and the next into latitude.
    longitude = params["longitude"].to_f
    latitude = params["latitude"].to_f 

    date = DateTime.new(params[:event_date][:year].to_i,params[:event_date][:month].to_i,params[:event_date][:day].to_i,params[:event_date][:hour].to_i,params[:event_date][:minute].to_i,0)
    publishing_status = ''
    if params[:publish]
      publishing_status = 'published'
    elsif params[:draft]
      publishing_status = 'draft'
    end

    @event =  user.events.create( 
                title:params["event"]["title"],
                meeting_point:[longitude,latitude],
                address:params["address"],
                event_date:date,
                is_private:params["event"]["is_private"],
                description:params["event"]["description"],
                activity_id:params["event"]["activity_id"],
                publishing_status:publishing_status,
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
                bicycle_ride:
                  {
                    polyline:polyline['data'],
                    altitude:altitude['data'],
                    distance:(params['distance']/5280).floor,
                    total_elevation_gain:params['total_elevation_gain']
                  }
              )
  end

  def self.update_default(params)
    event = Event.find(params[:id])
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f

    date = DateTime.new(params[:event_date][:year].to_i,params[:event_date][:month].to_i,params[:event_date][:day].to_i,params[:event_date][:hour].to_i,params[:event_date][:minute].to_i,0)
    
    event.title = params[:event][:title]
    event.description = params[:event][:description]
    event.meeting_point = [longitude,latitude]
    event.event_date = date
    event.address = params[:address]
    event.is_private = params[:event][:is_private]
    event.bicycle_ride.distance = params[:bicycle_ride][:distance]
    event.bicycle_ride.pace = params[:bicycle_ride][:pace]
    event.bicycle_ride.terrain = params[:bicycle_ride][:terrain]
    event.bicycle_ride.road_type = params[:bicycle_ride][:road_type]
    event.publishing_status = params[:publishing_status]

    if event.changed?
      event.save
    end
    event
  end

  ##
  # Instance Methods
  ############################################

  def coordinates
    meeting_point
  end

  def update_time(year,month,day,hour,minute)
    self.event_date = DateTime.new(year.to_i,month.to_i,day.to_i,hour.to_i,minute.to_i,0)
    self.save
    self
  end

  ## 
  # is_private -> true/false
  def update_privacy(privacy)
    self.is_private = privacy
    self.save
    self
  end

  def update_publishing_status(publishing_status)
    self.publishing_status = publishing_status
    self.save
    self
  end

  def update_title(title)
    self.title = title
    self.save
    self
  end

  def update_bicycle_ride(bicycle_ride)
    self.bicycle_ride = bicycle_ride
    self.save
    self
  end

  def update_description(description)
    self.description = description
    self.save
    self
  end

  def create_from_object(user)
    @event_mod_obj = user.events.create(
                title:self.title,
                meeting_point:self.meeting_point,
                address:self.address,
                event_date:self.event_date,
                is_private:self.is_private,
                description:self.description,
                activity_id:self.activity_id,
                publishing_status:self.publishing_status,
                bicycle_ride:
                    {
                        pace:self.bicycle_ride.pace,
                        terrain:self.bicycle_ride.terrain,
                        distance:self.bicycle_ride.distance,
                        road_type:self.bicycle_ride.road_type
                    }
            )
  end
end