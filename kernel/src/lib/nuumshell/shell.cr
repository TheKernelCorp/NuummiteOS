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
    apps = ["mem", "echo", "help", "poweroff"]
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
    #Terminal.set_color 0xA_u8, 0x0_u8
    print "N"
    #Terminal.set_color 0xB_u8, 0x0_u8
    print "u"
    print "u"
    #Terminal.set_color 0xC_u8, 0x0_u8
    print "m"
    print "m"
    #Terminal.set_color 0xD_u8, 0x0_u8
    print "i"
    #Terminal.set_color 0xE_u8, 0x0_u8
    print "t"
    #Terminal.set_color 0xF_u8, 0x0_u8
    print "e"
    #Terminal.set_color 0x8_u8, 0x0_u8
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
