class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  ##
  # Callbacks are triggered only when a new session is begun
  # ie: User needs to sign out and then sign back in to invoke these callbacks  
  def facebook
    auth = request.env["omniauth.auth"]
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(auth, current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?

      ##
      # if the user is NEW or a Facebook Realtime Update was initiated
      # 'update_fb_friends' in the user object will be set to true
      if @user.update_fb_friends
        FacebookWorker.perform_async(auth.credentials.token,auth.uid.to_s,@user.id.to_s)
      end
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def strava
    auth = request.env["omniauth.auth"]
    @user = User.find_for_strava_oauth(auth, current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Strava") if is_navigational_format?
      if @user.update_strava_objects
          StravaWorker.perform_async(auth.credentials.token,@user.id.to_s)
      end
    else
      session["devise.strava_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

end