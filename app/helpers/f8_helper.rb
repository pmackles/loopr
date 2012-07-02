module F8Helper
  
  def f8invite_url
  	invite_params = Hash.new
  	invite_params[:api_key] = FACEBOOK_API_KEY
  	invite_params[:content] = "<fb:req-choice url=\"http://www.facebook.com/add.php?api_key=#{FACEBOOK_API_KEY}\" label=\"Accept\" />Try Golf Game with me! Its almost as much fun as playing golf."
  	invite_params[:type] = "Golf Game"
  	invite_params[:action] = url_for(:action => '', :only_path => false)
  	invite_params[:actiontext] = "Invite Your Friends To Try Golf Game"
  	invite_params[:invite] = "true"
  
  	args = []
    	queryArgs = []
    	invite_params.each do |k,v|
        args << "#{k}=#{v}"
        queryArgs << "#{k}=#{CGI::escape(v)}"
    	end
    	
    	sig = Digest::MD5.hexdigest("#{args.sort.join("")}#{FACEBOOK_API_SECRET}")
  
  	"http://www.facebook.com/multi_friend_selector.php?" + queryArgs.join("&") + "&sig=#{sig}"
  end

#  def stat_leader_frag(options = {})
#  	sorter = options[:sorter]
#  	attr = options[:attr]
#  	best = sorter.best(attr)
#  	stat_label = options[:stat_label] || "Avg"
#  	stat_label += ":" unless stat_label == ""
#  	content_tag(:div, :class => "stat-leader") do
#  	 content_tag(:h4, options[:title]) <<
#  	 
#  	 if best.stats.nil?
#  	   na
#  	 else
#         link_to(username(best), "http://www.facebook.com/profile.php?id=#{best.facebook_id}")
#  	 end <<
#  
#  	 content_tag(:div, :class => "stat") do
#  	   "#{stat_label} #{f best.stats.send(attr)}, #{pluralize(best.stats.rounds_played, "round")}" unless best.stats.nil?
#  	 end			
#  	end
#  end
end