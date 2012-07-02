class Quote < ActiveRecord::Base
  def self.random
    #TODO: probably need to filter this a bit or cache
    quotes = Quote.find(:all)
    today = Date.today
    quotes[(today.yday + today.year) % quotes.size]
  end
  
end