class ZombieMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome_email(zombie)
    @zombie = zombie    
    @site_name = "localhost"
    mail(:to => zombie.email, :subject => "Welcome to my website.")
  end

  def reset_password_email(zombie)
    @zombie = zombie
    @password_reset_url = 'http://localhost:3000/password_reset?' + @zombie.password_reset_token
    mail(:to => zombie.email, :subject => 'Password Reset Instructions.')
  end

end
