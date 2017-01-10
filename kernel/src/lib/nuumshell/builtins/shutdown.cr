module Builtins
  extend self

  def shutdown(args : Array(String))
    if args.empty?
      puts "shutdown: time expected"
      puts "Try `shutdown --help` for more information."
      return
    end
    time = nil
    action = ShutdownOptions::Halt
    args.each { |arg|
      case arg
      when "-r"
        action = ShutdownOptions::Reboot
      when "-h"
        action = ShutdownOptions::Halt
      when "--help"
        ShellHelper.print_help(
          "Usage: shutdown [OPTION]... TIME",
          "Bring the system down.", [
            { "-r", "reboot" },
            { "-h", "halt" },
            { "--help", "display this help and exit" },
          ], "Valid TIME formats: 'now' || +m"
        )
        return
      else
        if time.nil?
          if arg == "now"
            time = 0
          elsif arg.starts_with? '+'
            time = arg.lchomp('+').to_i?
            time *= 60 * 1000 if time # minutes -> milliseconds
          end
          if time.nil?
            puts "shutdown: illegal time value"
            puts "Try `shutdown --help` for more information."
            return
          end
        end
      end
    }
    if time.nil?
      puts "shutdown: time expected"
      puts "Try `shutdown --help` for more information."
      return
    end
    if time > 0
      total_minutes = time / 1000 / 60
      if total_minutes > 1
        Async::Timeout.register (time - 60000), ->{
          puts "\nThe system is going DOWN for system halt in 1 minute !!"
          nil
        }
      end
      puts "The system is going DOWN for system halt in #{total_minutes} minute#{total_minutes > 1 ? "s" : ""} !!"
    end
    case action
    when ShutdownOptions::Halt
      Async::Timeout.register time, ->{
        print "\nIt's now safe to turn off the computer."
        asm("cli; hlt")
        nil
      }
    when ShutdownOptions::Reboot
      Async::Timeout.register time, ->{
        PM.reboot
        nil
      }
    end
  end

  private enum ShutdownOptions
    Halt,
    Reboot,
  end
end
