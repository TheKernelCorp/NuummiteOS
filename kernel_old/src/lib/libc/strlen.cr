module LibC
  extend self

  def strlen(ptr : UInt8*) : Int
    i = 0
    while ptr[i] != 0
      i += 1
    end
    i
  end
end
