ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :user_name            => "622michael@gmail.com",
  :password             => "secret",
  :authentication       => "plain",
  :enable_starttls_auto => true
}