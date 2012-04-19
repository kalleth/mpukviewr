class Poller

  def initialize(*args)
    @next_poll_time = 0 #make sure it polls immediately
  end

  def poll
    @break = false
    #@next_poll_time is set by the subclasses 
    if (@next_poll_time > Time.now.to_i)
      DaemonKit.logger.info("Skipping poll for #{self.class.name} - #{@next_poll_time.to_i - Time.now.to_i} seconds remaining")
      @break = true
    else
      #poll
      @last_poll_time = Time.now.to_i
    end
  end

end
