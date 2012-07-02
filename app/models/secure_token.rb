class SecureToken

  # TODO: find better place to store this
  @@key = "alibabaandthe40thieves"

  attr_reader :id, :type, :signature
    
  def initialize(id, type)
    @type = type
    @id = id.to_s
    @signature = (@id +  type + @@key).crypt("sh")
  end
  
  def self.parse(type, str)
    parts = str.split("-")
    
    if parts.size != 2
      raise "invalid token (format): #{str}"
    end
    
    token = SecureToken.new(parts[0], type)
    
    if token.signature != parts[1]
      raise "invalid token (signature): #{str}"
    end
    
    return token
  end
  
  def to_s
    @id + "-" + @signature
  end
  
end
