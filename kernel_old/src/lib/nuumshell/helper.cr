module ShellHelper
  extend self
  alias OptionArray = Array({String, String})

  def print_help(
    usage : String,
    description : String,
    options : OptionArray,
    epilogue : String? = nil)
    puts "#{usage}\n#{description}\n\nOptions:"
    options.each { |elem|
      puts "  #{elem[0].ljust(28)}#{elem[1]}"
    }
    puts "\n#{epilogue}" if epilogue
  end
end
