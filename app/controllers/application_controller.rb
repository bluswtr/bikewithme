class ApplicationController < ActionController::Base
  protect_from_forgery

  def lnglat
  	return [session[:lng],session[:lat]]
  end

  def to_utc(params)
  	return Time.utc(params["event_date"]["year"],params["event_date"]["month"],params["event_date"]["day"],params["event_date"]["hour"],params["event_date"]["minute"])
  end
  
end
