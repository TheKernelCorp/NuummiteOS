{% if flag?(:x86_64) %}
  # An unsigned integer of native size.
  alias USize = UInt64
{% else %}
  # An unsigned pointer of native size.
  alias USize = UInt32
{% end %}
