module Builtins
  extend self

  def mem(args : Array(String))
    heap_sys, heap_real = { Heap.size_sys, Heap.size_real }
    puts "Memory status"
    puts "Sys : #{heap_sys } (#{heap_sys  / 1024}k)"
    puts "Real: #{heap_real} (#{heap_real / 1024}k)"
  end
end
