class Exception
  def self.new(message, __file__ = __FILE__, __line__ = __LINE__)
    panic message, __file__, __line__
  end
end

class TypeCastError < Exception
  def self.new(message = "Type cast failed", __file__ = __FILE__, __line__ = __LINE__)
    super message, __file__, __line__
  end
end

class ArgumentError < Exception
  def self.new(message = "Invalid argument", __file__ = __FILE__, __line__ = __LINE__)
    super message, __file__, __line__
  end
end

class IndexError < Exception
  def self.new(message = "Invalid index", __file__ = __FILE__, __line__ = __LINE__)
    super message, __file__, __line__
  end
end

class DivisionByZero < Exception
  def self.new(message = "Division by zero", __file__ = __FILE__, __line__ = __LINE__)
    super message, __file__, __line__
  end
end
