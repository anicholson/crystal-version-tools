require "./spec_helper"

VersionTools.define_version_checker!(test_checker, "0.1.0")

def lesser_test
  test_checker("1.0.0") do
    lesser do
      "Matches lesser"
    end

    greater_than do
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

def equal_test
  test_checker("0.1.0") do
    lesser do
      puts "this won't print"
      "is not lesser"
    end

    greater do
      puts "this won't print"
      "is not greater"
    end

    equal do
      "Matches equal"
    end
  end
end

def lesser_or_equal_test
  test_checker("0.1.0") do
    lesser do
      puts "this won't print"
      "is not lesser"
    end

    lesser_or_equal do
      "Matches lesser_or_equal"
    end
  end
end

def greater_or_equal_test
  test_checker("0.1.0") do
    greater do
      puts "this won't print"
      "is not greater"
    end

    greater_or_equal do
      "Matches greater_or_equal"
    end
  end
end

describe "version checker" do
  describe "simple matchers" do
    it "lesser_test" do
      lesser_test.should eq("Matches lesser")
    end

    it "greater_test" do
      greater_test.should eq("Matches greater")
    end

    it "equal_test" do
      equal_test.should eq("Matches equal")
    end

    it "lesser_or_equal_test" do
      lesser_or_equal_test.should eq("Matches lesser_or_equal")
    end

    it "greater_or_equal_test" do
      greater_or_equal_test.should eq("Matches greater_or_equal")
    end
  end
end

def multiple_matchers_test
  matches = [] of String

  test_checker "0.1.0" do
    lesser_or_equal do
      matches << "lte"
    end
    equal do
      matches << "eq"
    end
    greater_or_equal do
      matches << "gte"
    end

    lesser { matches << "lt" }
    greater { matches << "gt" }
  end
  matches
end

describe "when multiple matches occur" do
  it "concatenates the contents in sequence" do
    multiple_matchers_test.should eq(["lte", "eq", "gte"])
  end
end

at_compile_time("When an Invalid clause is passed", should_build: false) do
  source do
    require "../src/version_tools"

    VersionTools.define_version_checker!(example_checker, "0.1.0")

    example_checker("1.0.0") do
      # ameba:disable Lint/UselessAssign
      x = 2.3 + 1.7
    end
  end

  it "raises a compile-time error" do
    (err.includes?("The following code caused an error")).should eq(true)
  end

  it "mentions the offending code" do
    (err.includes?("x = 2.3 + 1.7")).should eq(true)
  end
end
