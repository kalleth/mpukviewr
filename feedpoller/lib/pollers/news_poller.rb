class NewsPoller < RSSPoller

  TYPE = "NEWS"

  def poll
    super
    return if @break
    DaemonKit.logger.info "Polling mplay news"
    items = @content.channel.items.reverse  #reverse order
    @content.channel.items.each do |item|
      #first see if it already exists in the db
      e = Event.first(:etype => TYPE, :uid => item.link)
      if e.nil?
        #only if it doesn't already exist
        e = Event.create({
          :uid => item.link,
          :title => Sanitize.clean(item.title),
          :description => content_from_desc(Sanitize.clean(item.description)),
          :happened_at => item.pubDate,
          :etype => TYPE
        })
      end
    end
    @next_poll_time = Time.now.to_i + 300
  end

  def content_from_desc(desc)
    if desc.size > 155
      "#{desc.slice(0,150)}..."
    else
      desc
    end
  end

  def time_from_url(link)
    #We can only guess at the time the post was done without sending a request to it; this data isn't
    #included in the RSS feed.
    link.gsub!("http://iseries.multiplay.co.uk/","")
    tmp = link.split("/")
    year = tmp[0]
    month = tmp[1]
    day = tmp[2]
    Time.new(year,month,day)
  end

end
