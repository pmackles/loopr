class RoundTable
  
  DEFAULT_SORT_ORDER = { "date_played" => "desc" }
  def initialize(users, options)
    @sort = %w(date_played name login total_score total_holes).find { |s| s == options[:sort] } || "date_played"
    @order = %w(desc asc).find { |s| s == options[:order] } || default_sort_order(@sort)
    @page = options[:page] || 1
    @users = users
  end
  
  def sort
    @sort
  end
  
  def order
    @order
  end
  
  def current_sort?(sort)
    @sort == sort
  end
  
  def order_for(sort)
    if current_sort?(sort)
      return (@order == "desc" ? "asc" : "desc")
    else
      return default_sort_order(sort)
    end
  end
  
  def current_order_for(sort)
    current_sort?(sort) ? @order : nil
  end
  
  def rounds
    @rounds ||= Round.paginate(
      :conditions => ['user_id in (?)', @users],
      :order => "#{@sort} #{@order}", 
      :page => @page, 
      :per_page => 100,
      :finder => :list
    )  
  end
  
  def default_sort_order(sort)
    DEFAULT_SORT_ORDER[sort] || "asc"
  end
end
