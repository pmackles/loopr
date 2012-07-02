module RoundsHelper
  def rounds_url(params)
  	url_for(:course => params[:course], :user => params[:user], :sort_by => params[:sort_by], :only_path => false)
  end
  
  def counts(rounds)
    total = rounds.total_entries
    bbegin = (total > 0 ? rounds.offset : -1)
    eend = rounds.current_page * rounds.per_page
    prefix = "Rounds "
    "#{prefix}<b>#{bbegin+1}</b> - <b>#{eend > total ? total : eend}</b> of <b>#{total}</b>" 
  end

  def link_to_stat(stats, metric)
		if stats
			if metric.options[:drill] == false
				stats.send(metric.name.to_s + "_formatted") || "-"
			else
				if !(val = stats.send(metric.name.to_s + "_formatted")).blank?
					link_to(val, user_rounds_stat_url(:id => stats.user_id, :metric => metric.name))
				else
					"-"
				end
			end
		else
			""
		end
  end
end
