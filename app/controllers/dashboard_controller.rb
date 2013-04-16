class DashboardController < ApplicationController
  def index
    if params.keys.size > 2
      [:controller, :action].each {|key| params.delete(key) }
      jenkins_data = JSON.parse(params.keys.first)
      $redis["job_name"] = jenkins_data["name"]
      $redis["ci-development-status"] = parse_color(jenkins_data)
    end
  end
  
  def status
    render :json => {:ci => $redis["ci-development-status"], :job_name => $redis["job_name"], :status => :ok}
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