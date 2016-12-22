require "./lib/pointer.cr"
require "./lib/int.cr"

private ALIGN = 8_u32
private GUARD1 = 0x4E69636F_u32
private GUARD2 = 0x42697574_u32

private alias USize = UInt32
private alias Block = LibHeap::Block

struct HeapAllocator(T)
    # This doesn't quite work yet
    def self.alloc(heap : Heap) : Pointer(T) | Nil
        data = heap.kalloc sizeof(T).to_u32
        return data.as(Pointer(T)) if !data.is_a? Nil
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
    @used_top : Pointer(Block)
    @free_top : Pointer(Block)
    @free_addr : Pointer(UInt8)

    def initialize(end_of_kernel : USize)
        addr = Pointer(UInt8).new align(end_of_kernel).to_u64
        @used_top = Pointer(Block).new 0_u64
        @free_top = Pointer(Block).new 0_u64
        @free_addr = addr
    end

    def kalloc(size : USize) : Pointer(UInt8) | Nil
        new_block = begin
            block = get_block size
            if get_block(size).is_a?(Nil)
                block = alloc(sizeof(Block).to_u32).as(Pointer(Block))
                return if block.nil?
                block.value.block_size = size
                block.value.block_chunk = alloc size
            end
            block
        end
        return if new_block.is_a?(Nil)
        new_block.value.block_next = @used_top
        @used_top = new_block
        # TODO: memset new_block.value.block_chunk, 0, size
        new_block.value.block_chunk.as(Pointer(UInt8))
    end

    private def alloc(size : USize) : Pointer(UInt8)
        guard_size = sizeof(USize) * 2
        aligned = guard_size + align size
        free_addr = @free_addr.as Pointer(USize)
        free_addr[0] = GUARD1
        free_addr[aligned + 4] = GUARD2
        @free_addr += aligned
        @free_addr + 4 - aligned
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