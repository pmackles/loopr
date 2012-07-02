class AmchartController < ApplicationController
  def bar
    render :partial => 'bar', :object => nil, :locals => {
      :data_file => params[:data_file]
    }
  end
  
end
