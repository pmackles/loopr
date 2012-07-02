module UserHelper

  def css_style_for_score (score)
    style = "par"

    return style if score.score.nil?

    style = "birdie" if score.over_under_par < 0
    style = "bogey" if score.over_under_par > 0
    style
  end
  
  ALLOWED_TAGS = %w(b p br i)
  
  def whitelist(html)
    # only do this if absolutely necessary
    if html.index("<")
      tokenizer = HTML::Tokenizer.new(html)
      new_text = "" 

      while token = tokenizer.next
          node = HTML::Node.parse(nil, 0, 0, token, false)
          new_text << case node when HTML::Tag
            if ALLOWED_TAGS.include?(node.name) && (node.attributes.nil? || node.attributes.empty?)
              node.to_s
            else
              node.to_s.gsub(/</, "&LT;")
            end
          else
            node.to_s.gsub(/</, "&LT;") 
          end
      end

      html = new_text
    end
    html
  end

  def display_name(user)
    if user.is_a?(Hash)
      user[:source] == "fb" && user[:login][0,2] == "fb" ? user[:facebook_name].capitalize : user[:login].capitalize
    else
      user.source == "fb" && user.login[0,2] == "fb" ? user.facebook_name.capitalize : user.login.capitalize
    end
  end
  
  def username(user, options = {})
    curr_user = options.has_key?(:current_user) ? options[:current_user] : current_user
    if options[:possessive] == true
      user == curr_user ? "Your" : apostrophize(display_name(user))
    else
      user == curr_user ? "You#{options[:tense] ? ' have' : ''}" : display_name(user) + (options[:tense] ? ' has' : '')
    end
  end
  
  def user_icon_path(path, default = "/images/default_user_icon.jpg")
    path || "/images/default_user_icon.jpg"
  end
  
  def user_icon_small(icon_url)
    "<img src=\"#{user_icon_path(icon_url)}\" width=\"24\" height=\"24\" />"
  end

  def user_icon_medium(icon_url)
    "<img src=\"#{user_icon_path(icon_url)}\" width=\"48\" height=\"48\" />"
  end

  def user_icon_large(icon_url)
    "<img src=\"#{user_icon_path(icon_url)}\" width=\"96\" height=\"96\" />"
  end
        
  def profile_table_row(label, data, options = {})
    data = whitelist(data.to_s) unless options[:filter] == false
    "<tr><th>#{label}:</th><td>#{data.blank? ? na : data}</td></tr>"
  end
  
  def gender(user)
    User::GENDER_LABELS[user.gender]
  end
  
  def age(user)
    user.age.blank? ? nil : "#{user.age}ish"
  end
  
  def handedness(user)
    User::HANDEDNESS_LABELS[user.handedness]
  end
  
  def playing_since(user)
    user.playing_since && user.playing_since > 0  ? user.playing_since : "Not Saying"
  end
  
  def handicap(statable, url=nil)
    if url
      statable && statable.handicap ? link_to(statable.handicap, url) : na
    else
      statable && statable.handicap ? statable.handicap : na
    end
    
  end
  
  def round_link(id, total_score)
    link_to(total_score, round_url(:id => id))
  end
  
  def low_round(user)
    user.rounds.best ? round_link(user.rounds.best, user.rounds.best.total_score) : na
  end

  def high_round(statable)
    statable && statable.high_round ? round_link(statable.high_round.id, statable.high_round.total_score) : na
  end

  def last_round(statable)
    statable && statable.last_round ? round_link(statable.last_round.id, statable.last_round.total_score) : na
  end
    
  def rounds_posted(statable)
    statable && statable.rounds_played ? statable.rounds_played : 0
  end
  
  def course_map_image_tag(courses)
    markers = courses.select { |c| c.mappable? }.collect { |c| "#{c.latitude},#{c.longitude},tinyred" }
    # &center=40.714728,-73.998672&zoom=0
    "<img src=\"http://maps.google.com/staticmap?zoom=0&" +
      (markers.empty? ? "center=0,0" : "markers=#{markers.join("|")}") +
      "&size=240x125&key=#{GMAPS_KEY}\" />"
  end
  
#  def gender_label(gender)
#    User::GENDER_LABELS[gender]
#  end
#
#  def handedness_label(handedness)
#    User::HANDEDNESS_LABELS[handedness]
#  end
#
#  def age_label(age)
#    age ? "#{age}ish" : "Not Saying"
#  end
#
#  def playing_since_label(playing_since)
#    playing_since || "Not Saying"
#  end
#
#  def location_label(location)
#    location || "Not Saying"
#  end
          
end
