class ContactMailer < ActionMailer::Base
	default :from => "info@allforfunds.com"

	def contact_email(from, content, subject)
		@content = content

		mail(from: from, to: "622michael@gmail.com", content: content, subject: subject)
	end
end
