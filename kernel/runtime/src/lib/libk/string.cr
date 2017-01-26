module LibK
  extend self

  def memcpy(dst : _*, src : _*, n : USize) : Void*
    dst = dst.to_byte_ptr
    src = src.to_byte_ptr
    i = 0
    while i < n
      dst[i] = src[i]
      i += 1
    end
    dst.to_void_ptr
  end

  def memmove(dst : _*, src : _*, n : USize) : Void*
    dst = dst.to_byte_ptr
    src = src.to_byte_ptr
    if src < dst
      i = n
      while i != 0
        i -= 1
        dst[i] = src[i]
      end
    else
      i = 0
      while i < n
        dst[i] = src[i]
        i += 1
      end
    end
    dst.to_void_ptr
  end

  def memset(dst : _*, c : UInt8, n : USize) : Void*
    dst = dst.to_byte_ptr
    i = 0
    while i < n
      dst[i] = c
      i += 1
    end
    dst.to_void_ptr
  end

  def memcmp(ptr_a : _*, ptr_b : _*, n : USize) : Int32
    ptr_a = ptr_a.to_byte_ptr
    ptr_b = ptr_b.to_byte_ptr
    i = 0
    while i < n
      a = ptr_a[i]
      b = ptr_b[i]
      i += 1
      return a.to_i32 - b.to_i32 if a != b
    end
    0
  end
end
