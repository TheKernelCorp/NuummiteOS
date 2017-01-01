class Exception
  def self.new(message, __file__ = __FILE__, __line__ = __LINE__) : NoReturn
    panic message, __file__, __line__
  end
end

class TypeCastError < Exception
  def self.new(message, __file__ = __FILE__, __line__ = __LINE__) : NoReturn
    super message, __file__, __line__
  end
end
