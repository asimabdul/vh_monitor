class DashboardController < ApplicationController
  def index
    [:controller, :action].each {|key| params.delete(key) }

    if params.keys.present?
      jenkins_or_deployment_data = JSON.parse(params.keys.first)
      JobStatus.save_or_update!(jenkins_or_deployment_data)
    end

    @job_statuses = JobStatus.all
  end

  def create
    params[:announcements].each do |announcement|

      record = Announcement.new(announcement)
      record.save
    end

    render :json => {:status => "ok"}
  end

  def status
    message = Announcement.most_important || Announcement.last_updated || JobStatus.last_updated || 'TDD is your friend, procrastination is your enemy!'
    render :json => {:status => "ok", :job_statuses => JobStatus.all,
                     :message => message.try(:important_message, JobStatus.last_updated.try(:message)) || message.try(:message)}
  end
end