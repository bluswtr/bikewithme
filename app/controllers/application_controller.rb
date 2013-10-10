class ApplicationController < ActionController::Base
  protect_from_forgery

  def lnglat
  	return [session[:lng],session[:lat]]
  end

end
