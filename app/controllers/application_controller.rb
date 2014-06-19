class ApplicationController < ActionController::Base
  protect_from_forgery

  def lnglat
  	return [session[:lng],session[:lat]]
  end

  def save_latlng(lat,lng)
    session[:lat] = lat.to_f
    session[:lng] = lng.to_f
  end

  # def to_utc(params)
  # 	return Time.utc(params["event_date"]["year"],params["event_date"]["month"],params["event_date"]["day"],params["event_date"]["hour"],params["event_date"]["minute"])
  # end
  
  def no_results
  	->(obj){ if obj == 0 || obj == nil then return true end }
  end

  def mongo_save(object)
    if object.changed?
      object.save
    end
    object
  end

  def bikewithme_log(string)
    puts "@@@@@@@@@@@@@@@@@@ #{string}"
  end

  def save_utc_offset(offset)
    session[:timezone_offset_in_minutes] = offset.to_i * -1
    bikewithme_log(session[:timezone_offset_in_minutes])
  end

  def local_time
    return Time.now.utc + (session[:timezone_offset_in_minutes].to_i * 60)
  end

end
