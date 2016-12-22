require "./terminal.cr"
require "./multiboot.cr"
require "./heap.cr"

fun kmain(mboot_ptr : MultibootPointer)
    mboot = MultibootHelper.load mboot_ptr
    heap = Heap.new mboot.end_of_kernel
    puts "Hello from Nuummite!"
end
