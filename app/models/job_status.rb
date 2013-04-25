class JobStatus
  attr_accessor :name, :phase, :color, :status, :branch, :updated_at, :author

  NAMESPACE = "ci:monitor:"

  def initialize(data = {})
    set_attributes(data)
  end

  def set_attributes(data = {})
    raise 'Name of the job required!' if data["name"].blank?

    @name = data["name"]

    if data["build"]
      @phase = data["build"]["phase"]
      @status = data["build"]["status"]
    else
      @phase = data["phase"]
      @status = data["status"]
    end

    @branch = data["branch"] || @branch || 'unknown'
    @author = data["author"] || @author || 'unknown'

    @updated_at = data["updated_at"]
    @color = set_color
    self
  end

  def save
    @updated_at = Time.now.strftime('%a %b %d %I:%M%p')
    $redis["#{NAMESPACE}#{name}"] = self.to_json
  end

  def self.save_or_update!(data ={})
    existing = JobStatus.find(data["name"])

    record = if existing
               existing.set_attributes(data)
             else
               JobStatus.new(data)
             end

    record.save
  end

  def self.find(name)
    all.detect { |record| record.name.eql?(name)}
  end

  def self.all
    $redis.keys("#{NAMESPACE}*").map { |k| JobStatus.new(JSON.parse($redis[k])) }
  end

  def set_color
    case phase
      when "DEPLOYED" then "orange"
      when "STARTED" then "blue"
      when "COMPLETED"
        "green" if status == "SUCCESS"
      when "FINISHED"
        case status
          when "SUCCESS" then "green"
          when "FAILURE" then "red"
          else
            "gray"
        end
      else
        "gray"
    end
  end
end