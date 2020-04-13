require "spec"
require "../src/version_tools"

VersionTools.define_version_checker!(test_checker, "0.1.0")

def lesser_test
  test_checker("1.0.0") do
    lesser do
      "Matches lesser"
    end

    greater do
      puts "this won't print"
      "doesn't match"
    end
  end
end

def greater_test
  test_checker("0.0.1") do
    lesser do
      puts "this won't print"
      "doesn't match"
    end

    greater do
      "Matches greater"
    end
  end
end

describe "version checker" do
  it "lesser_test" do
    lesser_test.should eq("Matches lesser")
  end

  it "greater_test" do
    greater_test.should eq("Matches greater")
  end
end
