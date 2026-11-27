module ApplicationHelper
  def delivery_timer(timing)
    return "No deadline" unless timing

    time_tag(timing, timing.strftime("%b %d, %Y %l:%M %p %Z"), data: { delivery: true })
  end
end
