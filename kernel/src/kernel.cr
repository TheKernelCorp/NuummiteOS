require "./heap.cr"
require "./terminal.cr"
require "./multiboot.cr"

fun kmain(mboot_ptr : MultibootPointer)
    mboot = MultibootHelper.load mboot_ptr
    heap = Heap.init mboot.end_of_kernel
    puts "Hello from Nuummite!"
end
