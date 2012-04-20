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

  def translate_feed(feed)
    case feed[:type]
    when "TwitterPoller"
      "Twitter account: <a href=\"https://twitter.com/#{feed[:details]}\" target=\"_blank\">#{feed[:details]}</a>"
    when "NewsPoller"
      "Multiplay UK Event News"
    when "ForumPoller"
      "Multiplay UK Event Forum"
    else
      feed[:type]
    end
  end
end
