# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
  IncomingMessage.class_eval do
    # TODO: Remove after upgrade to 0.31.0.0+
    def parse_raw_email!(force = nil)
      # The following fields may be absent; we treat them as cached
      # values in case we want to regenerate them (due to mail
      # parsing bugs, etc).
      if self.raw_email.nil?
        raise "Incoming message id=#{id} has no raw_email"
      end
      if (!force.nil? || self.last_parsed.nil?)
        ActiveRecord::Base.transaction do
          self.extract_attachments!
          write_attribute(:sent_at, self.mail.date || self.created_at)
          write_attribute(:subject, convert_string_to_utf8(mail.subject.to_s).string)
          write_attribute(:mail_from, MailHandler.get_from_name(self.mail))
          if self.from_email
            self.mail_from_domain = PublicBody.extract_domain_from_email(self.from_email)
          else
            self.mail_from_domain = ""
          end
          write_attribute(:valid_to_reply_to, self._calculate_valid_to_reply_to)
          self.last_parsed = Time.now
          self.foi_attachments reload=true
          self.save!
        end
      end
    end
  end
end
