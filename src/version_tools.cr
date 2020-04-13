module VersionTools
  macro define_version_checker!(name, my_version)
    macro {{name}}(compared_version, &block)
      \{% my_version_str = {{my_version.resolve}}
      
      version_result = compare_versions(my_version_str, compared_version)
      to_evaluate = if (version_result == 0)
                      [:equal, :greater_or_equal, :lesser_or_equal]
                    elsif (version_result == 1)
                      [:greater, :greater_or_equal]
                    elsif (version_result == -1)
                      [:lesser, :lesser_or_equal]
                    else
                      raise "Invalid version result"
                    end
      
      expressions = block.body.is_a?(Expressions) ? block.body.expressions : [block.body] %}

      \{{ *expressions.select do |x|
        (x.class_name == "Call" && to_evaluate.includes?(x.name.symbolize))
      end.map { |x| x.block.body } }}
    end
  end
end

VersionTools.define_version_checker!(with_crystal_version, Crystal::VERSION)
