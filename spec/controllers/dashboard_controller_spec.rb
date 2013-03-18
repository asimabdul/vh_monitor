require "spec_helper"

describe DashboardController do
  render_views
  
  shared_examples_for "successful response" do
    it "status code should be a 200" do
      response.code.should == "200"
    end
  end
  
  context "#index" do
    before :each do
      get :index
    end
    it_behaves_like "successful response"
  end
end