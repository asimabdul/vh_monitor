require "spec_helper"

describe String do
  it "should return true if string is a JSON" do
    @test_string = ActiveSupport::JSON.encode({:a => "foo"})
    @test_string.is_json?.should be true
  end
  
  it "should return false if string is NOT json" do
    "foo".is_json?.should be false
  end
end