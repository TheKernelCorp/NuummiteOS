class Exception
  def self.new(message) : NoReturn
    panic
  end
end

class TypeCastError < Exception
  def self.new(message) : NoReturn
    super message
  end
end
