require 'dalli'

# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.
module Feedpoller
  
  class << self

    attr_accessor :memcache, :clients, :tapirem
      
    def persist_info
      cache.set('clients', @clients)
      cache.set('twitter_api_polls_remaining', @tapirem)
    end

    def cache
      @memcache ||= Dalli::Client.new('127.0.0.1:11211')
    end

  end

end
