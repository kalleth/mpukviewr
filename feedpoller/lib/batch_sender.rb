require 'singleton'

class BatchSender

  include Singleton
  
  def initialize
    @queue = []
  end

  def add_to_queue(event)
    @queue << event
  end

  def process_queue
    sort_queue
    @queue.each do |event|
      event.alert
    end
    @queue = []
  end

  private
  
  def sort_queue
    @queue.sort! do |a,b|
      b.happened_at <=> a.happened_at
    end
  end

end
