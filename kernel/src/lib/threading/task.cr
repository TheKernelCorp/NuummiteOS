enum TaskState
  AwaitingExecution = 0,
  Suspended = 1,
  Active = 2,
  Exited = 3,
end

class Task
  @@pid : UInt16 = 0_u16

  getter pid : UInt16
  getter state : TaskState
  getter stack : UInt8*
  property frame : StackFrame

  def initialize(address : UInt32)
    IDT.disable_interrupts
    @state = TaskState::AwaitingExecution
    @stack = Pointer(UInt8).malloc(4096) + 4096
    @frame = create_frame address
    @pid = Task.assign_pid
    IDT.enable_interrupts
  end

  def self.create(proc : Proc)
    Task.new proc.pointer.address.to_u32
  end

  def get_stack_frame_ptr
    pointerof(@frame).address.to_u32
  end

  protected def create_frame(address : UInt32)
    frame = StackFrame.new
    frame.eflags = 0x202_u32 # enable interrupts
    # frame.cs = 0x18 | 0x03 # user_code
    # frame.ss = 0x20 | 0x03 # user_data
    frame.cs = 0x08
    frame.eip = address
    frame.esp = @stack.address.to_u32
    @frame = frame
  end

  protected def self.assign_pid
    pid = @@pid
    @@pid += 1
    pid
  end
end
