macro run_tests(tests)
    {% for test_name in tests %}
        self.{{ test_name }}
    {% end %}
end

macro test(name, description, content)
    def self.{{ name }}
        __test_name = {{ description }}
        __test_panic_on_fail = false
        {{ content }}
        __test_ok
    end
end

macro panic_on_fail!
    __test_panic_on_fail = true
end

macro assert(a)
    __test_fail(true, false) unless {{ a }}
end

macro assert_not(a)
    __test_fail(false, true) if {{ a }}
end

macro assert_eq(a, b)
    __test_fail({{ a }}, {{ b }}) unless {{ a }} == {{ b }}
end

macro assert_not_eq(a, b)
    __test_fail({{ a }}, {{ b }}) if {{ a }} == {{ b }}
end

macro __test_fail(expected, actual)
    print "[Test] FAIL "
    puts __test_name
    print "-----> Expect: "
    puts {{ expected.stringify }}
    print "-----> Actual: "
    puts {{ actual.stringify }}
    __test_fail_and_panic if __test_panic_on_fail
    return
end

macro __test_fail_and_panic
    panic
end

macro __test_ok
    write ttys0, "[Test]  OK  "
    writeln ttys0, __test_name
end
