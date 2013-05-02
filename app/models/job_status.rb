class JobStatus
  attr_accessor :name, :phase, :color, :status, :branch, :updated_at, :timestamp, :deployed_at,
                :formatted_deployed_at, :author, :message, :priority, :fail_count, :last_succeeded_at

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
    @timestamp = data["timestamp"]
    @deployed_at = data["deployed_at"] || @deployed_at

    @updated_at = formatted_time(@timestamp)
    @formatted_deployed_at =  formatted_time(@deployed_at)

    @fail_count = data["fail_count"] || @fail_count
    @last_succeeded_at = data["last_succeeded_at"] || @last_succeeded_at

    @color = set_color
    @priority = set_priority

    @message = data["message"] || @message
    self
  end

  def save
    @timestamp = Time.now.to_i
    record_failures

    key = "#{NAMESPACE}#{name}"
    $redis[key] = self.to_json
    $redis.expire(key, 3600 * 8) #expire in 8 hours, you don;t use it - you lose it
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

  def self.last_updated
    all.sort_by {|j| j.timestamp.to_i }.last
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

  def record_failures
    if phase == "FAILURE"
      @fail_count = @fail_count.to_i + 1
    elsif phase == "SUCCESS"
      @fail_count = 0
      @last_succeeded_at = Time.now.to_i
    end
  end

  def set_priority
    if (phase == "FAILURE") && failing?
      "attention"
    else
      "normal"
    end
  end

  def failing?(grace_period=30.minutes)
    (fail_count >= 3) || (last_succeeded_at ? false : (Time.now - last_succeeded_at > grace_period))
  end

  def formatted_time(time)
    time ? Time.at(time.to_i).strftime('%a %b %d %I:%M%p') : "unknown"
  end
end