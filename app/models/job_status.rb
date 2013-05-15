class JobStatus < Record
  attr_accessor :name, :phase, :color, :status, :branch, :updated_at, :timestamp, :deployed_at,
                :formatted_deployed_at, :author, :message, :priority, :fail_count, :last_succeeded_at

  def initialize(data = {})
    set_attributes(data)
  end

  def self.namespace
    "ci:monitor:jobs:"
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
    record_failures if phase == "FINISHED"

    super
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
    if status == "FAILURE"
      @fail_count = @fail_count.to_i + 1
    elsif status == "SUCCESS"
      @fail_count = 0
      @last_succeeded_at = Time.now.to_i
    end
  end

  def set_priority
    if (status == "FAILURE") && failing?
      "attention"
    else
      "normal"
    end
  end

  def failing?(grace_period=30.minutes)
    (fail_count.to_i >= 3) || (last_succeeded_at.nil? ? false : (Time.now - Time.at(last_succeeded_at) > grace_period))
  end

  def formatted_time(time)
    time ? Time.at(time.to_i).strftime('%a %b %d %I:%M%p') : "unknown"
  end

  def self.all
    $redis.keys("#{namespace}*").map { |k| JobStatus.new(JSON.parse($redis[k])) }
  end

  def ttl
    8 * 3600 #8 hours
  end
end