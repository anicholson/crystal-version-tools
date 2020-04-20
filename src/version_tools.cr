module VersionTools
  macro define_version_checker!(name, my_version)
    macro {{name}}(compared_version, &block)
      \{% my_version_str = {{my_version.is_a?(Path) ? my_version.resolve : my_version}}

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

      \{% for exp in expressions %}
        \{% if exp.class_name == "Call" && to_evaluate.includes?(exp.name.symbolize) %}
          \{% sub_block = exp.block.body.is_a?(Expressions) ? exp.block.body.expressions : [exp.block.body] %}
          \{% for e in sub_block %}
            \{{ e }}
          \{% end %}
        \{% end %}
      \{% end %}
    end
  end
end

VersionTools.define_version_checker!(with_crystal_version, Crystal::VERSION)
