macro run_tests(tests)
    {% for test_name in tests %}
        self.{{ test_name }}
    {% end %}
end

macro test(name, description, content, __file__ = __FILE__, __line__ = __LINE__)
    def self.{{ name.id }}
        __test_name = {{ description }}
        __test_panic_on_fail = false
        __test_file = {{ __file__ }}
        __test_line = {{ __line__ }}
        {{ content }}
        writeln ttys0, "[Test]  OK  {{ description.id }}"
    end
end

macro panic_on_fail!
    __test_panic_on_fail = true
end

macro assert(a)
  unless {{ a }}
    __test_fail(true, false)
  end
end

macro assert_not(a)
  if {{ a }}
    __test_fail(false, true)
  end
end

macro assert_eq(a, b)
  unless {{ a }} == {{ b }}
    __test_fail({{ a }}, {{ b }})
  end
end

macro assert_not_eq(a, b)
  if {{ a }} == {{ b }}
    __test_fail("not #{{{ a }}}", {{ b }})
  end
end

macro __test_fail(expected, actual)
  writeln! "[Test] FAIL #{__test_name}"
  writeln! "-----> Expect: #{{{ expected }}}"
  writeln! "-----> Actual: #{{{ actual }}}"
  if __test_panic_on_fail
    panic "Critical test failed", __test_file, __test_line
  end
  return
end
