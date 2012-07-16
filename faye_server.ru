require 'faye'
require 'yaml'
require 'dalli'

PATH = "#{File.dirname(__FILE__)}/settings.yml"
CONFIG = YAML.load_file(PATH)

class ServerAuth

  def incoming(message, callback)
    if message['channel'] == '/messages'
      puts "Message incoming on messages channel"
      if message['data'] && message['data']['secret'] != CONFIG[:secret]
        message['error'] = "You are not authorized to send to this stream."
      else
        #authorized
        message['data'].delete('secret')
      end
    end
    callback.call(message)
  end

end

$clients = 0
$cache = Dalli::Client.new('127.0.0.1:11211')

def report_users
  $cache.set('clients', $clients)
end

bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
bayeux.add_extension(ServerAuth.new)
bayeux.bind(:subscribe) do |client_id, channel|
  if channel == "/messages"
    $clients += 1
    report_users
  end
end
bayeux.bind(:unsubscribe) do |client_id, channel|
  if channel == "/messages"
    $clients -= 1
    report_users
  end
end

run bayeux
