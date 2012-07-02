class EmailController < ApplicationController
  def index

  end
  
  def deliver

    item_type = params[:item_type]
    item_id = params[:item_id]
    to = params[:to] || ""
    from = params[:from] || ""
    
    if !to.match(EMAIL_REGEX) || !from.match(EMAIL_REGEX)  || item_type.blank? || item_id.blank?
      render :text => { 
        :saved => false, 
      }.to_json
      return
    end
    
    base_url = url_for(:only_path => false, :controller => '/')
    item = Object.const_get(item_type).find(item_id.to_i)
    SendThisMailer.send("deliver_#{item_type.downcase}", to, from, params[:msg], item, base_url)
    render :text => { :saved => true }.to_json
  end
end
