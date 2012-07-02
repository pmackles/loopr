class Invite < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :url
  
  validates_presence_of :recipient, :body
          
  validates_format_of :recipient ,
          :with => EMAIL_REGEX,
          :message => 'invalid email format'
          
  TOKEN_TYPE = "invite"
  
  def secure_id
    SecureToken.new(self.id, TOKEN_TYPE).to_s
  end
  
  def secure_url
    url + "invite/accept/?xyz=" + URI.escape(secure_id, /[\.\/\+&=\?]/)
  end
  
  def accept(user)
    true
  end
  
  def send_email
    GroupMailer.deliver_invite(self)
  end

#  def success_msg
#    "Welcome! You are now a member."
#  end
#  
#  def success_url
#    {:controller => 'group', :action => 'show', :id => self.group}
#  end
    
end
