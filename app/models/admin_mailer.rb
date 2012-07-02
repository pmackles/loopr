class AdminMailer < ActionMailer::Base

  def invite(invite, sent_at = Time.now)
    @subject    = 'You\'ve been invited to join LOOPR'
    @body["invite"] = invite
    @body["url"] = invite.secure_url
    @recipients = invite.recipient
    @from       = invite.user.email
    @sent_on    = sent_at
#    @headers    = {}
  end
end