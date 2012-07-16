require 'singleton'
require 'faye'

class ViewrSetting
  
  attr_accessor :config

  include Singleton

  def initialize
    load_settings
  end

  def load_settings
    @config = YAML.load_file("#{Rails.root}/../settings.yml")
  end

end
