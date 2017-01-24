lib LibSched
  $active_stack : UInt32
end

module Scheduler
  extend self

  TASK_LIMIT = 1024
  @@enabled = false
  @@list = Deque(Task).new TASK_LIMIT
  @@current_tid = -1
  @@current_pid = 0

  def enable
    IDT.add_fault_handler 13, ->handle_gp_fault(StackFrame)
    @@enabled = true
  end

  def update
    return unless @@enabled
    list_size = @@list.size
    return if list_size == 0
    tid = @@current_tid
    if tid >= 0
      @@list[tid].frame = Pointer(StackFrame).new(LibSched.active_stack.to_u64).value
    end
    next_tid = tid + 1
    next_tid %= list_size
    task = @@list[next_tid]
    LibSched.active_stack = task.get_stack_frame_ptr
    GDT.set_tss_esp0 task.stack.address.to_u32
    @@current_tid = next_tid
  end

  def schedule(task : Task)
    raise "Task limit reached!" if @@list.size >= TASK_LIMIT
    @@list.push task
  end

  def handle_gp_fault(frame : StackFrame)
    puts "*** GP FAULT!"
    IDT.halt
  end

  protected def switch_stack_frame(stack_address : UInt32)
    LibSched.active_stack = stack_address
  end
end
