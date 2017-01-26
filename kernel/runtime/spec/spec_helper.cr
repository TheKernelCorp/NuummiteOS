require "spec"
require "../src/prelude"

def internal_bits(size : Int)
  native_size = 32
  {% if flag?(:x86_64) %}
    native_size = 64
  {% end %}
  if size == native_size
    yield
  end
end

def bits32
  internal_bits(32) { yield }
end

def bits64
  internal_bits(64) { yield }
end
