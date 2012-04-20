require "#{Rails.root}/lib/autolink"

class AdminController < ApplicationController

  before_filter :authenticate_user!

  include Autolink

  def index
  end

  def post
    flash[:error] = "post"
  end

  def do_post
    if params[:message_data].blank? || params[:message_title].blank?
      flash[:error] = "You must provide both a message and a title"
      @message = params[:message_data]
      @msg_title = params[:message_title]
      render :action => :post
    else
      title = auto_link(Sanitize.clean(params[:message_title]))
      desc = auto_link(Sanitize.clean(params[:message_data]))
      t = ViewrSetting.instance.config[:postable_types].detect{|p| p[:type] == params[:message_type]}
      Event.create(:etype => params[:message_type], :title => title, :description => desc, :happened_at => Time.now)
      flash[:notice] = "Post sent successfully."
      redirect_to :action => :index
    end
  end

end
