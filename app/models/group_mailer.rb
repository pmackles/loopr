class GroupMailer < ActionMailer::Base

  SUBJECT = 'Join my new group at Loopr'
  
  def invite(invite, sent_at = Time.now)
    @subject    = SUBJECT
    @body["invite"] = invite
    @body["url"] = invite.secure_url
    @recipients = invite.recipient
    @from       = invite.user.email
    @sent_on    = sent_at
#    @headers    = {}
  end
end
