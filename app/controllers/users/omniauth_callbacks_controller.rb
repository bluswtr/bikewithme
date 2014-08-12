class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  ##
  # Callbacks are triggered only when a new session is begun
  # ie: User needs to sign out and then sign back in to invoke these callbacks  
  def facebook
    auth = request.env["omniauth.auth"]
    bikewithme_log("devise auth: #{auth}")

    # if logged in as a bwm or strava user, don't create fb login credentials, just download their friendlist
    if user_signed_in? && (is_bwm_user(current_user) || is_strava_user(current_user))
        bikewithme_log("authorized fb user and is currently logged in as bwm or strava user")
        if current_user.update_fb_friends
            Contact.update_new_user_contact(auth.uid.to_s,"",user_url(current_user.id))
            FacebookWorker.perform_async(auth.credentials.token,auth.uid.to_s,current_user.id.to_s)
            redirect_to to_app_invite_index_url
        end
    else
        bikewithme_log("authorized fb user but is not currently logged in as bwm or strava user")
        @user = User.find_for_facebook_oauth(auth,current_user)
        if @user.persisted? #if is a facebook user
            bikewithme_log("user persisted")
            sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
            set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?

            # if the user is NEW or a Facebook Realtime Update was initiated
            # 'update_fb_friends' (in the user object) will be set to true
            # create new Contact for new User
            if @user.update_fb_friends
                bikewithme_log("updating user's contacts and downloading friendlist")
                # indicate to users who know this new user by flagging the new user's contact records
                Contact.update_new_user_contact(auth.uid.to_s,"",user_url(@user.id))
                FacebookWorker.perform_async(auth.credentials.token,auth.uid.to_s,@user.id.to_s)
            end
        else
            session["devise.facebook_data"] = request.env["omniauth.auth"]
            redirect_to new_user_registration_url
        end
    end
  end

  def is_bwm_user(user)
    user.strava_uid.blank? && user.uid.blank?
  end

  def is_strava_user(user)
    !user.strava_uid.blank?
  end

  def is_fb_user(user)
    !user.uid.blank?
  end

  def strava
    auth = request.env["omniauth.auth"]
    bikewithme_log("devise auth: #{auth}")

    if user_signed_in? && (is_bwm_user(current_user) || is_fb_user(current_user))# otherwise just download their ridelist
        if current_user.update_strava_objects
            Contact.update_new_user_contact("",auth.strava_uid,user_url(current_user.id))
            StravaWorker.perform_async(auth.credentials.token,current_user.id.to_s)
            redirect_to eventpost_index_url
        end
    # if logged in as a bwm or facebook user, don't create strava login credentials
    else
        @user = User.find_for_strava_oauth(auth,current_user)
        
        if @user.persisted?
          sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
          set_flash_message(:notice, :success, :kind => "Strava") if is_navigational_format?
          if @user.update_strava_objects
                Contact.update_new_user_contact("",auth.strava_uid,user_url(@user.id))
                StravaWorker.perform_async(auth.credentials.token,@user.id.to_s)
          end
        else 
          session["devise.strava_data"] = request.env["omniauth.auth"]
          redirect_to new_user_registration_url
        end

    end
  end

end