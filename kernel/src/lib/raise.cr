fun __crystal_personality : NoReturn
    panic
end

@[Raises]
fun __crystal_raise : NoReturn
    panic
end

fun __crystal_raise_string : NoReturn
    panic
end

def raise(file = __FILE__) : NoReturn
    panic file
end

def raise(ex : Exception, file = __FILE__) : NoReturn
    panic file
end