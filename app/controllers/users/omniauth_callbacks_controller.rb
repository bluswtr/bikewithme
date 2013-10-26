class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(auth, current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      #User.create_friendlist(request.env["omniauth.auth"])
      #@db_user = User.where(:provider => auth.provider, :uid => fb_uid).first

      ##
      # if the user is NEW or a Facebook Realtime Update was initiated
      # the flag 'update_fb_friends' in the user object will be raised
      if(@user.update_fb_friends && defined? @user.uid)
        FacebookWorker.perform_async(auth.credentials.token,auth.uid.to_s,@user.id.to_s)
      end
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end