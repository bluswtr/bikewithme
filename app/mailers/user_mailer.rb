class UserMailer < ActionMailer::Base
default from: 'notifications@bikewithme.com'
 
  def invite(message,user)
  	@user = user
    @url  = 'http://bikewithme.com/login'
	mail(to: message[:to],subject: message[:subject])
  end
end