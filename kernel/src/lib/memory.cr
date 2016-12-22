require "./types.cr"

def memcpy(dst : Pointer(_), src : Pointer(_), n : USize) : Pointer
    dst_sig = dst
    dst = dst.to_byte_ptr
    src = src.to_byte_ptr
    i = 0
    while i < n
        dst[i] = src[i]
        i += 1
    end
    dst_sig
end

def memmove(dst : Pointer(_), src : Pointer(_), n : USize) : Pointer
    dst_sig = dst
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
    dst_sig
end

def memset(dst : Pointer(_), c : UInt8, n : USize) : Pointer
    ptr = dst.to_byte_ptr
    i = 0
    while i < n
        ptr[i] = c
    end
    dst
end

def memcmp(ptr_a : Pointer(_), ptr_b : Pointer(_), n : USize)
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