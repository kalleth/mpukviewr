class WelcomeController < ApplicationController

  def index
  end

  def popup
    @events = Event.all(:limit => 50, :order => [:happened_at.desc])
    render :layout => "popup"
  end

  def tech
  end

end
