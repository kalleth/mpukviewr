require 'twitter'

class TwitterPoller < Poller

  include Autolink

  TYPE = "TWEET"

  def initialize(user, prefix=nil)
    @user = user
    @prefix = prefix
    super
  end

  def poll
    super
    return if @break
    begin
      DaemonKit.logger.info "Polling twitter for #{@user}"
      tweets = Twitter.user_timeline(@user, :include_rts => true)
      tweets.each do |tweet|
        #skip replies
        e = Event.first(:etype => TYPE, :uid => tweet['id'])
        if e.nil? && tweet['in_reply_to_screen_name'].nil?
          msg = tweet['text']
          if @prefix
            #If prefix given, do not report tweets
            next if msg[0..@prefix.size-1] != @prefix
          end
          e = Event.create({
            :uid => tweet['id'],
            :etype => TYPE,
            :title => user_to_twitter_link(@user),
            :description => auto_link(Sanitize.clean(msg)),
            :happened_at => tweet['created_at']
          })
        end
      end
    rescue
      DaemonKit.logger.error($!.message)
      DaemonKit.logger.error($!.backtrace.join("\n"))
    end
    @next_poll_time = Time.now.to_i + 360 #6 minutes
  end

  private

  def user_to_twitter_link(user)
	"<a href=\"https://twitter.com/#{user}\" target=\"_blank\">#{user}</a>"
  end

end
