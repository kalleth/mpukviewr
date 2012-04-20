require 'dm-rails/middleware/identity_map'
require "#{Rails.root}/lib/viewr_setting"

class ApplicationController < ActionController::Base

  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  before_filter :viewr_settings

  private

  def viewr_settings
    @viewr_settings = ViewrSetting.instance.config
  end

end
