class SessionsController < Devise::SessionsController
  def create
    super
  end

  def destroy
  	super
  	puts ">>>>>>> reset_session"
  	reset_session
  end
end
