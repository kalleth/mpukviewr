require 'net/http'

class Event

  include DataMapper::Resource

  property :id,           Serial
  property :etype,        String
  property :uid,          Text   #unique identifier - for forum post/newspost, permalink, for tweet, id, etc.
  property :title,        Text
  property :description,  Text

  property :created_at,   DateTime  #alerted at, put in database at
  property :happened_at,  DateTime  #when the event actually occurred, used for sorting on initial display

  after :save, :alert

  def alert
    #nothing right now
    obj = {
      "etype" => etype,
      "uid" => uid,
      "title" => title,
      "description" => description,
      "happened_at" => happened_at.to_s,
      "secret" => ViewrSetting.instance.config[:secret]
    }

    msg = {
      :data => obj, 
      :channel => "/messages"
    }

    Net::HTTP.post_form(URI.parse("http://0.0.0.0:9292/faye"), :message => msg.to_json)

  end

end
