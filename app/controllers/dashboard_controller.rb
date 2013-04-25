class DashboardController < ApplicationController
  def index
    [:controller, :action].each {|key| params.delete(key) }

    if params.keys.present?
      jenkins_or_deployment_data = JSON.parse(params.keys.first)
      JobStatus.save_or_update!(jenkins_or_deployment_data)
    end

    @job_statuses = JobStatus.all
  end
  
  def status
    render :json => {:status => "ok", :job_statuses => JobStatus.all}
  end
end