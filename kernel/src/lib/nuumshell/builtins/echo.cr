module Builtins
  extend self

  def echo(args : Array(String))
    i = 1
    args.each { |arg|
      print arg
      print " " if i < args.size
      i += 1
    }
    puts
  end
end
