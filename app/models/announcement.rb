class Announcement <  Record
  attr_accessor :name, :from, :timestamp, :message, :tags

  def initialize(data = {})
    set_attributes(data)
  end

  def self.namespace
    "ci:monitor:announcements:"
  end

  def set_attributes(data = {})
    raise 'Message of the announcement required!' if data["message"].blank?

    @name = data["name"]

    @from = data["from"]["name"] || data["from"]


    @message = data["message"] || @message
    @timestamp = data["date"] || data["timestamp"] || @timestamp
    @tags = data["tags"]

    @color = set_color
    self
  end

  def set_color
    "orange"
  end

  def formatted_time(time)
    time ? Time.at(time.to_i).strftime('%a %b %d %I:%M%p') : "unknown"
  end

  def self.all
    $redis.keys("#{namespace}*").map { |k| Announcement.new(JSON.parse($redis[k])) }
  end

  def self.most_important
    all.detect {|a| a.tags & ['@demo','@important']}
  end

  def important_message(additional_message=nil)
    msg = ""
    msg << "<b>[#{tags.join(',')}] : </b><b>#{message}</b> from #{from} sent at <b>#{Time.parse(timestamp)}</b>."
    msg << " #2:#{additional_message}" if additional_message
    msg
  end

  def ttl
    1800 # 30 minutes
  end
end