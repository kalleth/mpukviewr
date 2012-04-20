class AdminController < ApplicationController

  before_filter :authenticate_user!

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
      t = ViewrSetting.instance.config[:postable_types].detect{|p| p[:type] == params[:message_type]}
      Event.create(:etype => params[:message_type], :title => params[:message_title], :description => params[:message_data], :happened_at => Time.now)
      flash[:notice] = "Post sent successfully."
      redirect_to :action => :index
    end
  end

end
