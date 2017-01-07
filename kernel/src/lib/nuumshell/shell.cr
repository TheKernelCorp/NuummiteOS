require "./builtins"

class NuumShell
  def initialize
    @user = "root"
    @pass = "1234"
    @login = false
    @max_login = 3
  end

  def run
    banner
    until @login
      login
    end
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x0F
    loop do
      prompt = "#{@user}@Nuummite:/# "
      line, command, args = read_command prompt
      next unless command
      case command
      when "help"
        help
      when "echo"
        Builtins.echo args
      when "mem"
        Builtins.mem args
      when "shutdown"
        Builtins.shutdown args
      else
        puts "#{command}: command not found"
      end
    end
  end

  def login
    try = 0
    loop do
      user = Keyboard.gets("Username: ").chomp
      pass = Keyboard.gets("Password: ", :silent).chomp
      if pass == @pass && user == @user
        @login = true
        break
      end
      puts "User or password are incorrect"
      try += 1
      if try > @max_login
        puts "Maximum tries for login reached"
        break
      end
    end
  end

  def help
    apps = ["help", "echo", "mem", "shutdown"]
    puts "Available commands are"
    num = 1
    apps.each do |app|
      puts "#{num}) #{app}"
      num += 1
    end
  end

  def banner
    # The following is a mess
    # But it's a beautiful mess
    print "Hello from "
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x0A
    print "N"
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x0B
    print "u"
    print "u"
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x0C
    print "m"
    print "m"
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x0D
    print "i"
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x0E
    print "t"
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x0F
    print "e"
    ioctl tty0, TerminalDevice::IOControl::COLOR_SET, 0x08
    puts "!"
  end

  private def read_command(prompt : String) : {String, String?, Array(String)}
    line = Keyboard.gets(prompt).chomp
    arr = line.split
    com = arr[0].chomp(',') unless arr.empty?
    args = arr[1..(arr.size-1)] unless arr.size < 2
    { line, com, args || Array(String).new }
  end
end
