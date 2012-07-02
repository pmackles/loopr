class CourseStatSummary < StatSummary
    
  def summarize
    rs = SqlRoundSummarizer.new(
      :course => entity_id
    ).summary
    map_round_summary_to_stat_summary(rs)  
  end
  
end