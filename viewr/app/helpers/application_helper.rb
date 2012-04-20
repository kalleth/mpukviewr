module ApplicationHelper
  def twitterized_type(type)
    case type
    when :alert
      "warning"
    when :error
      "error"
    when :notice
      "info"
    when :success
      "success"
    else
      type.to_s
    end
  end

  def shorter_time_ago_in_words(time)
    t = time_ago_in_words(time)
    sh = t.gsub("about ", "").
      gsub(" seconds", "s").
      gsub(" second", "s").
      gsub(" minutes", "m").
      gsub(" minute", "m").
      gsub(" hours", "h").
      gsub(" hour", "h").
      gsub(" days", "d").
      gsub(" day", "d").
      gsub(" months", "m").
      gsub(" month", "m")
    "#{sh}"
  rescue
    "unknown"
  end
end
