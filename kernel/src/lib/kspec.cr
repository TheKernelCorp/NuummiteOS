macro run_tests(test_module, tests)
    {% for test_name in tests %}
        {{ test_module }}.{{ test_name }}
    {% end %}
end

macro test(name, description, content)
    def self.{{ name }}
        __test_name = {{ description }}
        {{ content }}
        __test_ok
    end
end

macro assert(a)
    __test_fail unless {{ a }}
end

macro assert_not(a)
    __test_fail if {{ a }}
end

macro assert_eq(a, b)
    __test_fail unless {{ a }} == {{ b }}
end

macro assert_not_eq(a, b)
    __test_fail if {{ a }} == {{ b }}
end

macro __test_fail
    print "[Test] Failed: "
    print __test_name
    print "\n"
    return
end

macro __test_ok
    print "[Test] Succeeded: "
    print __test_name
    print "\n"
end