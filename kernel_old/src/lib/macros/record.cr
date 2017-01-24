macro record(name, *properties)
  struct {{name.id}}
    {% for property in properties %}
      {% if property.is_a?(Assign) %}
        getter {{property.target.id}}
      {% elsif property.is_a?(TypeDeclaration) %}
        getter {{property.var}} : {{property.type}}
      {% else %}
        getter :{{property.id}}
      {% end %}
    {% end %}
    def initialize({{
      *properties.map do |field|
        "@#{field.id}".id
      end
    }})
    end
    {{yield}}
    def clone
      {{name.id}}.new({{
        *properties.map do |property|
          if property.is_a?(Assign)
            "@#{property.target.id}.clone".id
          elsif property.is_a?(TypeDeclaration)
            "@#{property.var.id}.clone".id
          else
            "@#{property.id}.clone".id
          end
        end
      }})
    end
  end
end
