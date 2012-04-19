require 'rexml/document'
require 'net/http'

class XmlPoller < Poller

  def initialize(url)
    @url = url
    super
  end

  def poll
    super
    xml_data = Net::HTTP.get_response(URI.parse(@url)).body
    @content = REXML::Document.new(xml_data)
  end

end
