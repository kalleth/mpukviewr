require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class RSSPoller < Poller

  def initialize(feed_url)
    @url = feed_url
    super
  end

  def poll
    super
    content = ""
    open(@url) {|s| content = s.read}
    @content = RSS::Parser.parse(content, false, false)
  end

end
