class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Followable::Followed
  include Mongo::Joinable::Joined
  include Mongo::Invitable::Invited
  include Mongo::Invitable::Inviter
  
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
  field :event_date, :type => Time

  ##
  # Geospatial 2dsphere 
  # Mongodb expects an array with two floats in it. 
  # Like so: [longitude,latitude]
  field :meeting_point, :type => Array 

  # field: address # a feature for later

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
  embeds_one :bicycle_ride
  belongs_to :user
  field :make_private, :type => Boolean, :default => 0

  attr_accessible :activity_id,:title,:date,:bicycle_ride,:activity,:description,:meeting_point,:event_date,:make_private

  # example: index({ loc: "2d" }, { min: -200, max: 200 }).
  # chose 2dsphere over 2d because it has more features and 2d is largely a legacy index
  index({ meeting_point: '2dsphere' }, { unique: true, background: true })

  # Other Fields to Consider
  # has_many :tags #commute, training, fun, recovering
  # has_many :activities #eat, bike, swim #has pointer to activity-related details

  ACTIVITY = ['Bicycle Ride',1]

  def self.private_only(lnglat,distance,query_limit)
    Event.where(make_private: "1").desc.limit(query_limit).geo_near(lnglat).max_distance(distance)
  end

  def self.public_only(lnglat,distance,query_limit)
    Event.where(make_private: "0").desc.limit(query_limit).geo_near(lnglat).max_distance(distance)
  end

  def self.friends_only(lnglat,distance,user,query_limit)
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
            unless event.make_private
              @events.push(event);
            end
          end
        end
      end
      Event.desc.limit(query_limit).geo_near(lnglat).max_distance(distance).find(@events)
    end
  end

  def self.nearest(event_filter,lnglat,current_user)

    # initialize
    event_data = Hash.new
    nearest_events = Hash.new
    options = Array.new
    vicinity = 50 # miles
    query_limit = 10
    distance = vicinity.fdiv(111.12) # convert from degree to miles
    no_results = ->(obj){ if obj == 0 || obj == nil then return true end }

    # switch statement for filter
    events = case
      when event_filter == "friends" then Event.friends_only(lnglat,distance,current_user,query_limit)
      when event_filter == "public" then Event.public_only(lnglat,distance,query_limit)
      when event_filter == "private" then Event.private_only(lnglat,distance,query_limit)
    end

    # return the event's organizer info and the event info unless the query yeields no results
    unless no_results.call(events)
      i = 0
      events.each do |event|
        temp = Array.new

        # return name, userid, 
        temp = User.find(event.user_id)

        # REVISE return only necessary user data
        nearest_events[i] = {user:temp, event: event}
        i+=1
      end

      options = Descriptor.get_options
      event_data["nearest_events"] = nearest_events
      event_data["options"] = options
      return event_data
    end
  end

end