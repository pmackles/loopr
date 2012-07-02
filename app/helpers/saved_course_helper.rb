module SavedCourseHelper
  def fffggg(user, sc)
  	if sc.rounds_played.to_i > 0
			username(user, :tense => true) + " posted " + pluralize(sc.rounds_played, " round") + " for this course." +
				" See <a href=\"" + stats_url(:id => user.id, "filter[course]" => sc.course_id) + "\">" + 
				username(user, :possessive => true).downcase + " course stats</a>."
		else
			username(user, :tense => true) + " not posted any rounds for this course"
		end
	end
end