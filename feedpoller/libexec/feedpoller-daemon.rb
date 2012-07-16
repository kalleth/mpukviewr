require 'rubygems'
require 'data_mapper'
require 'controller'
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://root@localhost/mpuk')
# Change this file to be a wrapper around your daemon code.

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
#  config.trap( 'TERM', Proc.new { puts 'Going down' } )
  config.trap('TERM') do
    #kill the faye server
    Controller.stop_faye
  end
end

controller = Controller.new
loop do
  controller.poll
  controller.report
  sleep 60
end
