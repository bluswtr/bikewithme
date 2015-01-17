module ApplicationHelper

  def readable_time(time, is_draft)
    total_seconds = (time - Time.now.utc).floor.to_i
    
    if is_draft == 1
      readable_begin = ""
    elsif total_seconds.abs < 60
      readable_time = "<b>Event Starts:</b>&nbsp;&nbsp;&nbsp; <i>Right Now</i>"
      return readable_time.html_safe
    elsif total_seconds < -7200
      readable_begin = "<b>Event Occurred:</b> "
    elsif total_seconds <= -60
      readable_begin = "<b>Event Started:</b>&nbsp;&nbsp; <span style='color:red;'>"
    else
      readable_begin = "<b>Event Starts In:</b> "
    end
    
    if total_seconds <= -60
      if total_seconds >= -7200 && is_draft == 0
        readable_end = " ago</span>"
      else 
        readable_end = " ago"
      end
      total_seconds = total_seconds.abs
    else 
      readable_end = ""
    end
    
    total_days = (total_seconds/86400).floor.to_i
    total_seconds = total_seconds - total_days * 86400
    total_hours = (total_seconds/3600).floor.to_i
    total_seconds = total_seconds - total_hours * 3600
    total_minutes = (total_seconds/60).floor.to_i
    if total_days == 0
      days_text = ""
    elsif total_days == 1
      days_text = "1 Day "
    else
      days_text = "#{total_days} Days "
    end
    
    if total_hours == 0 || total_days > 1
      hours_text = ""
    elsif total_hours == 1
      hours_text = "1 Hour "
    else
      hours_text = "#{total_hours} Hours "
    end
    
    if total_minutes == 0 || total_days > 0
      minutes_text = ""
    elsif total_minutes == 1
      minutes_text = "1 Minute "
    else
      minutes_text = "#{total_minutes} Minutes "
    end
    
    readable_time = "#{readable_begin}<i>#{days_text}#{hours_text}#{minutes_text}#{readable_end}</i>"
    return readable_time.html_safe
  end
end
