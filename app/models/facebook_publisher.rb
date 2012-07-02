require "digest/md5"
require "cgi"
require "hpricot"

class FacebookPublisher

  def logger
      RAILS_DEFAULT_LOGGER
  end
  
  def self.update_profile(user)
    if user.facebook_id && user.facebook_session_key
      fbsession = FacebookSession.new(FACEBOOK_API_KEY, FACEBOOK_API_SECRET)
      fbsession.activate_with_previous_session(user.facebook_session_key, user.facebook_id)
      begin
        box = render_to_string(:partial => 'f8/profile_box', :locals => { :user => user })
        fbsession.profile_set_fbml(
          :uid => user.facebook_id,
          :markup => box,
          :profile_main => box
        )
      rescue FacebookSession::ClientException => goboom
        RAILS_DEFAULT_LOGGER.info("non-fatal exception in profile_set_fbml #{goboom}")
      end
    end
  end
  
  def self.xxx(round)
    user = round.user
    if user.facebook_id && user.facebook_session_key
      fbsession = FacebookSession.new(FACEBOOK_API_KEY, FACEBOOK_API_SECRET)
      fbsession.activate_with_previous_session(user.facebook_session_key, user.facebook_id)
      begin
        
        fbsession.stream_publish(
          :message => "message: I played golf",
          :attachment => {
            :name => "name: I played golf",
            :href => "http://#{FACEBOOK_DEFAULT_URL_OPTIONS[:host]}/round/show/#{round.id}",
            :caption => "{*actor*} played golf",
            :descripton => round.comments.blank? ? "" : round.comments
          }.to_json
        ) 
      rescue FacebookSession::ClientException => goboom
        RAILS_DEFAULT_LOGGER.info("non-fatal exception in publish_new_round #{goboom}")
      end
    end    
  end
  
  def self.publish_new_round(round)
    user = round.user
    if user.facebook_id && user.facebook_session_key
      fbsession = FacebookSession.new(FACEBOOK_API_KEY, FACEBOOK_API_SECRET)
      fbsession.activate_with_previous_session(user.facebook_session_key, user.facebook_id)
      begin
        template_data = {
          :round_article => (80..89).include?(round.total_score) ? "an" : "a",
          :round_href => "http://#{FACEBOOK_DEFAULT_URL_OPTIONS[:host]}/round/show/#{round.id}",
          :round_score => round.total_score,
          :round_course => round.course.short_name,
          :round_notes => round.comments.blank? ? "" : round.comments
        }
        
        fbsession.feed_publish_user_action(
          :template_bundle_id => FACEBOOK_TEMPLATE_BUNDLES[:new_round], 
          :template_data => template_data.to_json,
          :target_ids => "",
          :body_general => ""
        )  
      rescue FacebookSession::ClientException => goboom
        RAILS_DEFAULT_LOGGER.info("non-fatal exception in publish_new_round #{goboom}")
      end
    end
  end

  def self.register_template_bundle(fbclient)
    response = fbclient.feed_register_template_bundle(
      :one_line_story_templates => [
        "{*actor*} just shot {*round_article*} <a href=\"{*round_href*}\">{*round_score*}</a> at {*round_course*}",
        "{*actor*} just posted a new round from {*round_course*}",
        "{*actor*} just posted a new round"
      ].to_json,
      :short_story_templates => [ 
        { 
          :template_title => "{*actor*} just shot {*round_article*} <a href=\"{*round_href*}\">{*round_score*}</a> at {*round_course*}", 
          :template_body => "{*round_notes*}"
        },
        { 
          :template_title => "{*actor*} just posted a new round from {*round_course*}", 
          :template_body => "{*round_notes*}"
        },
        { 
          :template_title => "{*actor*} just posted a new round", 
          :template_body => "{*round_notes*}"
        }
      ].to_json    
    )
    response.to_s
  end
  
  private
  
  def self.render_to_string(opts)
    template_root = "#{RAILS_ROOT}/app/views"
    ActionView::Base.new(template_root, {}, FacebookPublisher.new).render(opts)
  end
end
