module IO
  class Error < Exception
  end
  
  class EOFError < Error
    def initialize(message = "End of file reached", __file__ = __FILE__, __line__ = __LINE__)
      super message, __file__, __line__
    end
  end
end
