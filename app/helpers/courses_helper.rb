module CoursesHelper

  class CoursesBrowseLinkRenderer < WillPaginate::LinkRenderer
    def page_link(page, text, attributes = {})
      @template.link_to text, @template.courses_browse_url(:page => page), attributes
    end
  end

  class CoursesSearchLinkRenderer < WillPaginate::LinkRenderer
    def page_link(page, text, attributes = {})
      @template.link_to text, @template.courses_search_url(:page => page, :q => @template.params[:q]), attributes
    end
  end
    
  def quick_facts(course)
    facts = []
    facts.push Course::CLUB_TYPES.index(course.club_type) if course.club_type
    facts.push "#{course.number_of_holes} holes" if  course.number_of_holes
    facts.push "par #{course.par}" if course.par
    facts.push "#{course.yards} yards" if course.yards
    facts.any? ? facts.join(", ") + "<br />" : ""
  end
  
  def counts(courses, map = nil, q = nil)
    total = courses.total_entries
    bbegin = (total > 0 ? courses.offset : -1)
    eend = courses.current_page * courses.per_page
    prefix = "Results "
    "#{prefix}<b>#{bbegin+1}</b> - <b>#{eend > total ? total : eend}</b> of <b>#{total}</b> for <b>#{h q}</b>" 
  end
  
  def course_highlight_with_image(c)
    content = link_to(image_tag("courses/#{c.id}.jpg"), course_url(c))
		content += "<div style=\"margin-left: 210px\">"
		content += "<h4 style=\"margin-top: 0px; margin-bottom: 3px; padding-top: 0px\">"
		content += link_to(c.name, course_url(c))
		content += "<br /><span style=\"font-size: 10px; font-weight: normal\"> #{c.address.city}, #{c.address.country}</span>"
		content += "</h4>"
		content += "<p style=\"margin-top: 0px; padding-top: 0px\">"
		content += "Par #{c.par}, #{c.yards} #{c.length_units}<br />"
		content += "Designed by #{c.designer}<br />"
		content += "Opened #{c.year_built}"
		content += "</p>"
		content += "</div>"
		content += "<br clear=\"all\" />"
		content
  end
end
