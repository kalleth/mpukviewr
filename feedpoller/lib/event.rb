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
    obj = {
      "etype" => etype,
      "uid" => uid,
      "title" => title,
      "description" => description,
      "happened_at" => happened_at
    }
    Controller.notify(obj)
  end

end
