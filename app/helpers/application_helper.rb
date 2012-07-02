# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Localization

  @@guest_user = User.new

  @@frustration_quotes = [
    'Doh',
    'Ack',
    'Ugh',
    'Hoover Dam',
    'Grand Coulee Dam',
    'Shitake Mushrooms',
    'Sugar Honey Iced Tea',
    'Drat'
  ]

#  def remove_fb_params
#    h = Hash.new
#    h.merge(params)
#    params.keys.each do |k|
#      h[k] = nil if k.starts_with?("fb_")
#    end
#    h
#  end
      
  def link_to_or_span(condition, name, url)
    link_to_unless(condition, name, url) { |n| "<strong>#{n}</strong>" }
  end

  def supress_ads
    @supress_ads = true
  end
      
#  def path(page_path)
#    content_for(:path) { page_path }
#  end
  
  def rss(url_for_args)
    content_for(:rss) { auto_discovery_link_tag(:rss, url_for_args) }
  end

  def current_channel(current)
    content_for(:current_channel) { current }
  end
  
  def current_tab(current)
    content_for(:current_tab) { current }
  end
      
#  def breadcrumb(page_path)
#    link_last = page_path != request.path
#
#    components = page_path.split("/").reject { |c| c.blank? }
#    if components[0] == "f8"
#      components.delete_at(0)
#    end
#    
#    rtn = ""
#    components.each_with_index do |c,index|
#      name = CGI::unescape(c.gsub(/_/, ' '))
#      name.capitalize! unless name.match(/[A-Z]/)
#      if components.last == c && !link_last
#        rtn += name
#      else
#        rtn += content_tag(:a, name, :href => "/" + components[0..index].join("/"))
#      end
#      rtn += " / " unless components.last == c
#    end
#    rtn
#  end
   
  def title(page_title)
    content_for(:title) { page_title }
  end
  
  def description(description)
    if description
      content_for(:description) { "<meta name=\"description\" content=\"#{h(description)}\" />" }
    end
  end

  def robots(content)
    if content
      content_for(:robots) { "<meta name=\"robots\" content=\"#{h(content)}\" />" }
    end
  end

  def map_link(name, location=nil)
    link_to(name, map_url(location || name))
  end
    
  def link_to_function_if(condition, name, *args, &block)
    condition ? link_to_function(name, args, &block) : ""
  end
  
  # override as per http://greg.agiletortoise.com/2007/03/01/rails-content_tag-block-fix/
  def content_tag(name, content_or_options_with_block = nil, options = nil, &block)
    if block_given?
      options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
      content = block.call
    else
      content = content_or_options_with_block
    end
    content_tag_string(name, content, options)
  end
  
  def vcard(org, location)
    content_tag(:div, :class => "vcard") do
      content_tag(:div, org, :class => "org") +
      content_tag(:div, :class => "adr") do
        content_tag(:div, location.street, :class => "street-address") +
        content_tag(:span, location.city, :class => "locality") +
        content_tag(:span, location.state.blank? ? "" : ", #{location.state}", :class => "region") + " " +
        content_tag(:span, location.postal_code, :class => "postal-code") +
        content_tag(:div, location.country, :class => "country")
      end +
      content_tag(:div, location.phone, :class => "tel", :style => "margin-top: 5px; margin-bottom: 5px")
    end
  end
  
  def na
    "-"
  end
  
  def f(val)
    return na if val.nil?
	if val.class == Float && val <= 1
	 formattedVal = "#{(val * 100).to_i}%"
	elsif val.class == Float || val.class == BigDecimal
	 formattedVal = sprintf("%01.2f", val)      
    else
	 formattedVal = "#{val}"
	end
  end
  
  def random_frustration
    @@frustration_quotes[rand(@@frustration_quotes.size)] + '!'
  end
    
  def gmaps_javascript_include
    key = GMAPS_KEY
    src = "http://maps.google.com/maps?file=api&v=2&key=#{key}"
    content_tag("script", "", { "type" => "text/javascript", "src" => src })
  end
  
  def array_to_hash(arr)
    idx = -1
    arr.collect { |item| [item, idx += 1]}
  end
  
  def new_bug
    '<span style="background-color: yellow; color: #000">NEW</span>'
  end
  
  def checkmark
    image_tag('checkmark.gif', :width => 10, :height => 10)
  end
  
  def apostrophize(s)
    s[-1..-1] == "s" ? "#{s}'" : "#{s}'s"
  end
  
  def breadcrumb_link(word, options = {}, html_options = {})
    link_to_unless_current(word, options, html_options) { |n| "<b>#{n}</b>" }
  end
  
  def error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    if object && !object.errors.empty?
      content_tag("div",
        content_tag(
          options[:header_tag] || "h1",
          "Oops! Please try that again"
        ) +
        content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
          "id" => options[:id] || "errorBox", "class" => options[:class] || "errorBox"
        )
    else
      ""
    end
  end
end
