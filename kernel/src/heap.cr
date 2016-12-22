require "./lib/int.cr"
require "./lib/types.cr"
require "./lib/pointer.cr"

private ALIGN = 8_u32
private GUARD1 = 0x4E69636F_u32
private GUARD2 = 0x42697574_u32

private alias Block = LibHeap::Block

struct HeapAllocator(T)
    def self.calloc(heap : Heap) : Pointer(T) | Nil
        data = heap.calloc sizeof(T).to_u32
        return data.as Pointer(T) if !data.is_a? Nil
    end
    def self.kalloc(heap : Heap) : Pointer(T) | Nil
        data = heap.kalloc sizeof(T).to_u32
        return data.as Pointer(T) if !data.is_a? Nil
    end
end

private lib LibHeap
    struct Block
        block_size : USize
        block_next : Pointer(Block)
        block_chunk : Pointer(UInt8)
    end
end

struct Heap
    @@instance : Heap?

    def self.init(end_of_kernel : USize)
        @@instance = Heap.new end_of_kernel
    end

    def initialize(end_of_kernel : USize)
        addr = Pointer(UInt8).new align(end_of_kernel).to_u64
        @used_top = Pointer(Block).null
        @free_top = Pointer(Block).null
        @free_addr = addr.as Pointer(UInt8)
    end

    def self.calloc(size : USize) : Pointer(UInt8) | Nil
        return if @@instance.nil?
        @@instance.calloc size
    end

    def self.kalloc(size : USize) : Pointer(UInt8) | Nil
        return if @@instance.nil?
        @@instance.kalloc size
    end

    def calloc(size : USize) : Pointer(UInt8) | Nil
        block = alloc size
        return if block.is_a? Nil
        memset block.value.block_chunk, 0_u8, size
        block.value.block_chunk.as Pointer(UInt8)
    end

    def kalloc(size : USize) : Pointer(UInt8) | Nil
        block = alloc size
        return if block.is_a? Nil
        block.value.block_chunk.as Pointer(UInt8)
    end

    private def alloc(size : USize) : Pointer(Block) | Nil
        new_block = get_or_alloc_block size
        return if new_block.is_a? Nil
        new_block.value.block_next = @used_top
        @used_top = new_block
        new_block
    end

    private def get_or_alloc_block(size : USize) : Pointer(Block) | Nil
        block = get_block size
        if get_block(size).is_a? Nil
            block = alloc_block(sizeof(Block).to_u32).as Pointer(Block)
            return if block.is_a? Nil
            block.value.block_size = size
            block.value.block_chunk = alloc_block size
        end
        block
    end

    private def alloc_block(size : USize) : Pointer(UInt8)
        guard_size = sizeof(USize) * 2
        aligned = guard_size + align size
        free_addr = @free_addr.as Pointer(USize)
        free_addr[0] = GUARD1
        free_addr[aligned + 4] = GUARD2
        @free_addr += aligned
        @free_addr + (4_i32 - aligned.to_i32)
    end

    private def get_block(size : USize) : Pointer(Block) | Nil
        i = @free_top
        p = @free_top
        while !i.null?
            i_val = i.value
            p_val = p.value
            return if i_val.nil?
            return if p_val.nil?
            if i_val.block_size > size
                if i == p
                    @free_top = i_val.block_next
                else
                    p_val.block_next = i_val.block_next
                end
                return i
            end
            p = i
            i = i_val.block_next
        end
    end

    private def align(addr : USize)
        (addr % ALIGN) + addr
    end
end