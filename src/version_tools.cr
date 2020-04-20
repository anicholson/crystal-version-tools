module VersionTools
  macro define_version_checker!(name, my_version)
    {%
      equal_clauses = [:equal, :equals, :greater_or_equal, :greather_than_or_equal, :lesser_or_equal, :less_than_or_equal]
      lte_clauses = [:equal, :equals, :lesser, :less_than, :lesser_or_equal, :less_than_or_equal]
      gte_clauses = [:equal, :equals, :greater, :greater_than, :greater_or_equal, :greater_than_or_equal]
    %}

    macro {{name}}(compared_version, &block)
      \{% my_version_str = {{my_version.is_a?(Path) ? my_version.resolve : my_version}}

      all_known_clauses = ({{equal_clauses + lte_clauses + gte_clauses}}).uniq
      version_result = compare_versions(my_version_str, compared_version)

      to_evaluate = if (version_result == 0)
                      {{equal_clauses}}
                    elsif (version_result == 1)
                      {{gte_clauses}}
                    elsif (version_result == -1)
                      {{lte_clauses}}
                    else
                      raise "Invalid version result"
                    end

      expressions = block.body.is_a?(Expressions) ? block.body.expressions : [block.body] %}

      {% verbatim do %}
        {% for exp in expressions %}
          {% if exp.class_name == "Call" && to_evaluate.includes?(exp.name.symbolize) %}
            {% sub_block = exp.block.body.is_a?(Expressions) ? exp.block.body.expressions : [exp.block.body] %}
            {% for e in sub_block %}
              {{ e }}
            {% end %}
          {% elsif (exp.class_name == "Call") && all_known_clauses.includes?(exp.name.symbolize) %}
          {% elsif (exp.class_name == "Call") %}
            {% p! exp %}
            {% raise "Unknown clause: #{exp.name.symbolize}" %}
          {% else %}
            {% usage = <<-USAGE
The following code caused an error:

  #{exp}

Use a clause instead, for example:
  greater do
    # your code here
  end

The following clauses are supported:
  * lesser (or less_than)
  * lesser_or_equal (or less_than_or_equal)
  * equal (or equals)
  * greater_or equal (or greater_than_or_equal)
  * greater (or greater_than)
USAGE

               raise usage %}
          {% end %}
        {% end %}
      {% end %}
    end
  end
end

VersionTools.define_version_checker!(with_crystal_version, Crystal::VERSION)
