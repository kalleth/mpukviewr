require 'simple-rss'
require 'open-uri'
require 'time'

class ForumPoller < Poller

  def initialize(url)
    @url = url
    super
  end

  TYPE = "FORUM"

  def poll
    super
    return if @break
    DaemonKit.logger.info "Polling forums"
    @content = SimpleRSS.parse(open(@url))
    @content.items.each do |post|
      e = Event.first(:etype => TYPE, :uid => post.guid)
      if e.nil?
        e = Event.create({
          :uid => post.guid,  #can be used as html link
          :title => title_from_post_with_link(post),
          :description => content_from_post_with_link(post),
          :happened_at => post.pubDate,
          :etype => TYPE
        })
      end
      @next_poll_time = Time.now.to_i + 600 #10 minute intervals
    end
  end

  def title_from_post_with_link(post)
    "<a href=\"#{post.guid}\" target=\"_blank\">#{Sanitize.clean(post.title)}</a> - #{post.dc_creator}"
  end

  def content_from_post_with_link(post)
    content = Sanitize.clean(post.content_encoded.encode('utf-8'))
    if content.size > 155
      "#{content.slice(0,150)}..."
    else
      content
    end
  end

end
