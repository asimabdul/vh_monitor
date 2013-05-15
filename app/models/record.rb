class Record
  attr_accessor :name
  def save
    key = "#{self.class.namespace}#{name}"
    $redis[key] = self.to_json
    $redis.expire(key, ttl)
  end

  def self.find(name)
    all.detect { |record| record.name.eql?(name)}
  end

  def self.last_updated
    all.sort_by {|j| j.timestamp.to_i }.last
  end

  def important_message
    nil
  end
end