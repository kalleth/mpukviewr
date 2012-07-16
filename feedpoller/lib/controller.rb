require 'poller'
require 'event'
require 'batch_sender'
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

  CONFIG_FILE = "#{File.dirname(__FILE__)}/../../settings.yml"

  def self.config=(cfg)
    @config = cfg
  end
  
  def self.config
    @config
  end

  def self.notify(event)
    event["secret"] = config[:secret]
    bayeux_client.publish("/messages", event)
  end

  def self.bayeux_client
    # create faye client
    @client ||= Faye::Client.new('http://localhost:9292/faye')
  end

  def initialize
    load_config_and_create_pollers
    sleep 10
  end

  def load_config_and_create_pollers
    Controller.config = YAML.load_file(CONFIG_FILE)
    @config_mtime = File.mtime(CONFIG_FILE)
    @pollers = []
    Controller.config[:feeds].each do |feed|
      @pollers << feed[:type].classify.constantize.new(feed[:details])
    end
  end

  def check_if_config_needs_reloading
    if @config_mtime != File.mtime(CONFIG_FILE)
      DaemonKit.logger.info("Settings modified, reloading pollers..")
      load_config_and_create_pollers
    end
  end

  def report
    rem = Twitter.rate_limit_status.remaining_hits.to_s
    Feedpoller.tapirem = rem
    DaemonKit.logger.info("Finished polling loop, remaining hits: #{rem}")
  end

  def poll
    begin
      #Persist to cache # polls remaining etc
      Feedpoller.persist_info
      check_if_config_needs_reloading
      @pollers.each do |poller|
        poller.poll
      end
      BatchSender.instance.process_queue
    rescue
      DaemonKit.logger.info("Error occurred: #{$!.message}")
      DaemonKit.logger.info("Error occurred: #{$!.backtrace.join("\n")}")
    end
  end

end
