require "./terminal.cr"
require "./multiboot.cr"

fun kmain(ptr : LibMultiboot::MultibootInfo)
  puts "Hello from Nuummite!"
end
