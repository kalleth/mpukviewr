require 'poller'
require 'event'
require 'autolink'
require 'sanitize'
require 'pollers/rss_poller'
require 'pollers/xml_poller'
require 'pollers/forum_poller'
require 'pollers/news_poller'
require 'pollers/twitter_poller'
require 'faye'

class Controller

  DataMapper.finalize

  def self.start_faye
    @bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
    Thread.new do
      @bayeux.listen(9292)
    end
  end

  def self.notify(event)
    event["secret"] = @config[:secret]
    @bayeux.get_client.publish("/messages", event)
  end

  def self.bclient
    @bayeux.get_client
  end

  def initialize
    load_config_and_create_pollers
    Controller.start_faye
    sleep 30
  end

  def load_config_and_create_pollers
    @config = YAML.load_file("../settings.yml")
    @config_mtime = File.mtime("../settings.yml")
    @pollers = []
    @config[:feeds].each do |feed|
      @pollers << feed[:type].classify.constantize.new(feed[:details])
    end
  end

  def check_if_config_needs_reloading
    if @config_mtime != File.mtime("../settings.yml")
      DaemonKit.logger.info("Settings modified, reloading pollers..")
      load_config_and_create_pollers
    end
  end

  def report
	DaemonKit.logger.info("Finished polling loop, remaining hits: #{Twitter.rate_limit_status.remaining_hits.to_s}")
  end

  def poll
    begin
      check_if_config_needs_reloading
      @pollers.each do |poller|
        poller.poll
      end
    rescue
      DaemonKit.logger.info("Error occurred: #{$!.message}")
    end
  end

end
