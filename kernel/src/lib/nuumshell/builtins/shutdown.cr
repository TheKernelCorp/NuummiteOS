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
        puts "Usage: shutdown [OPTION]... TIME"
        puts "Options:"
        puts "-r      reboot"
        puts "-h      halt"
        puts "If no option is specified, `-h` is assumed."
        return
      else
        if time.nil?
          case arg
          when "0", "now"
            time = 0
          else
            puts "Invalid time! Supported: [0 | now]"
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
    case action
    when ShutdownOptions::Halt
      Async::Timeout.register time, ->{
        puts "It's now safe to turn off the computer."
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
