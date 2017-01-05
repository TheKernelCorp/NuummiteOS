require "./apps/*"

class NuumShell
  def initialize
    @user = "root"
    @pass = "1234"
    @login = false
    @max_login = 3
  end

  def run
    banner
    while !@login
      login
    end
    loop do
      print "\n#{@user}@nuumsh#: "
      command = Keyboard.gets.chomp.split 2
      next unless command.size > 0
      case command[0]
      when "echo"
        if command.size > 1
          Echo.echo(command[1])
        end
      when "help"
        help
      when "mem"
        Mem.stats
      when "poweroff"
        Power.off
      else
        puts "Unrecognized command: #{command[0]}"
      end
    end
  end

  def login
    try = 0
    loop do
      print "Login: "
      user = Keyboard.gets.chomp
      print "Password: "
      pass = Keyboard.gets(:silent).chomp
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
    puts "Avilable commands are"
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
    Terminal.set_color 0xA_u8, 0x0_u8
    print "N"
    Terminal.set_color 0xB_u8, 0x0_u8
    print "u"
    print "u"
    Terminal.set_color 0xC_u8, 0x0_u8
    print "m"
    print "m"
    Terminal.set_color 0xD_u8, 0x0_u8
    print "i"
    Terminal.set_color 0xE_u8, 0x0_u8
    print "t"
    Terminal.set_color 0xF_u8, 0x0_u8
    print "e"
    Terminal.set_color 0x8_u8, 0x0_u8
    puts "!"
  end
end
