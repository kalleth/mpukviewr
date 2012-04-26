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

class ServerAuth

  def incoming(message, callback)
    if message['channel'] == '/messages'
      puts "Message incoming on messages channel"
      if message['data'] && message['data']['secret'] != Controller.config[:secret]
        message['error'] = "You are not authorized to send to this stream."
      else
        #authorized
        message['data'].delete('secret')
      end
    end
    callback.call(message)
  end

end

class Controller

  DataMapper.finalize

  CONFIG_FILE = "/data/mpuk/settings.yml"

  def self.start_faye
    @bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
    @bayeux.add_extension(ServerAuth.new)
    @bayeux.bind(:subscribe) do |client_id, channel|
      if channel == "/messages"
        Feedpoller.clients += 1
      end
    end
    @bayeux.bind(:unsubscribe) do |client_id, channel|
      if channel == "/messages"
        Feedpoller.clients -= 1
      end
    end
    Thread.new do
      @bayeux.listen(9292)
    end
  end

  def self.stop_faye
    @bayeux.stop
  end

  def self.config=(cfg)
    @config = cfg
  end
  
  def self.config
    @config
  end

  def self.notify(event)
    event["secret"] = config[:secret]
    @bayeux.get_client.publish("/messages", event)
  end

  def self.bclient
    @bayeux.get_client
  end

  def initialize
    Feedpoller.clients = 0
    load_config_and_create_pollers
    Controller.start_faye
    sleep 30
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
