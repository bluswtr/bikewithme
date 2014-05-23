module ApplicationHelper

  def readable_time(time)
    diff = Time.now - time
    fiveminutes = 300
    onehour = 3600
    oneday = 86400
    twodays = 2 * oneday
    oneweek = 604800
    twoweeks = 2 * oneweek

    if diff < onehour
      if ((diff/60).round) <= 2
        readable_time = "Just Now"
      else
        readable_time = "#{(diff/60).round} minutes ago"
      end
    elsif diff < oneday
      readable_time = "Today"
    elsif diff > oneday && diff < twodays
       readable_time = "Yesterday"
    elsif diff > oneweek && diff < twoweeks
      readable_time = "Last Week"
    elsif diff < 7 * oneday
      readable_time = "#{(diff/oneday).round} days ago"
    elsif time.month == Time.now.month - 1
      readable_time = "Last Month"
    end

    return readable_time
  end
end
