require "spec"
require "uuid"
require "file_utils"

require "../src/version_tools"

macro compile_time_test(name, should_build = true, &block)
  {% annotated_name = "[C] " + name %}
  describe {{annotated_name}} do
    test_id = UUID.random
    tempdir_path = Path.new("./spec").expand

    file_path = Path.new(tempdir_path, "#{test_id}_compile_time_spec.cr")

    at_exit do
      FileUtils.rm(file_path.to_s)
    end

    {% expressions = block.body.is_a?(Expressions) ? block.body.expressions : [block.body] %}
    {% spec_blocks = [] of Call %}
    {% source = "" %}
    {% for exp in expressions %}
      {% if exp.class_name == "Call" && ([:it, :describe, :pending, :context].includes?(exp.name.symbolize)) %}
        {% spec_blocks << exp %}
      {% elsif exp.class_name == "Call" && (exp.name.symbolize == :source) %}
        {% source = exp.block.body.stringify %}
      {% end %}
    {% end %}

    {% if source.empty? %}
      {% raise "Can't have an empty source block" %}
    {% else %}
        File.open(file_path, "w") do |f|
          f.write_utf8({{source}}.to_slice)
        end
    {% end %}

    output = String::Builder.new
    err = String::Builder.new
    result = Process.run("crystal", ["build", "--error-trace", "--no-color", file_path.expand.to_s], nil, false, true, Process::Redirect::Close, output, err, Dir.current)

    output = output.to_s
    err = err.to_s

    describe "basic checks" do
      it "creates output" do
        some_output = !(output.empty? && err.empty?)
        some_output.should eq(true)
      end

      {% if should_build %}
        it "succeeds" do
          result.success?.should eq(true)
        end
      {% else %}
        it "fails" do
          result.success?.should eq(false)
        end
      {% end %}
    end

    {% for spec in spec_blocks %}
      {{ spec }}
    {% end %}
  end
end
