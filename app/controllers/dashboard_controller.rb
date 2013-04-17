class DashboardController < ApplicationController
  def index
    if params.keys.size > 2
      [:controller, :action].each {|key| params.delete(key) }
      jenkins_data = JSON.parse(params.keys.first)
      $redis["#{jenkins_data["name"]}_status"] = parse_color(jenkins_data)
    end
  end
  
  def status
    job_statuses = []
    $redis.keys("*_status").each do |k|
      job_statuses << {:color => $redis[k], :name => k}
    end
    render :json => {:status => "ok", :job_statuses => job_statuses}  
  end
  
  
  private
  def parse_color(jenkins_data)
    case jenkins_data["build"]["phase"]
    when "STARTED" then "blue"
    when "COMPLETED"
      "green" if jenkins_data["build"]["status"] == "SUCCESS"
    when "FINISHED"
      case jenkins_data["build"]["status"]
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