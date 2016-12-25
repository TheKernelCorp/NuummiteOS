class Node(T)
    @data = nil
    @next = nil

    def initialize
    end

    def initialize(@data : T)
    end

    def next
        @next
    end

    def next=(value : Node(T) | Nil)
        @next = value
    end

    def data
        @data
    end
end

class LinkedList(T)
    @head : Node(T)
    @tail : Node(T)

    def initialize
        @head = Node(T).new
        @tail = @head
        @count = 0
    end

    def push(value : T)
        node = Node(T).new value
        @tail.next = node
        @tail = node
        @count += 1
    end

    def pop : T | Nil
        return if @head == @tail
        last = @tail
        node = @head
        next_node = node.next
        while true
            break unless next_node
            break if next_node == last
            node = next_node.not_nil!
            next_node = node.next
        end
        node.next = nil
        @tail = node
        last.data
    end

    def count : Int
        @count
    end

    def [](offset : Int) : T | Nil
        if offset >= @count
            raise "Index out of range!"
        end
        head = @head
        i = 0
        node = head
        while i < offset + 1
            next_node = node.next
            return unless next_node
            node = next_node.not_nil!
            i += 1
        end
        node.data
    end
end

module LinkedListTests
    def self.run
        run_tests [
            push,
            pop,
            count,
            index,
        ]
    end

    test count, "LinkedList#count", begin
        list = LinkedList(Int32).new
        list.push 1
        list.push 2
        list.push 3
        assert_eq 3, list.count
    end

    test index, "LinkedList#[]", begin
        list = LinkedList(Int32).new
        list.push 1
        list.push 2
        a = list[0]
        b = list[1]
        assert a
        assert b
        assert_eq 1, a
        assert_eq 2, b
    end

    test push, "LinkedList#push", begin
        list = LinkedList(Int32).new
        list.push 1
        list.push 2
        a = list.@head
        assert a
        a = a.next
        assert a
        x = a.data
        assert x
        assert_eq 1, x
        a = a.next
        assert a
        x = a.data
        assert x
        assert_eq 2, x
    end

    test pop, "LinkedList#pop", begin
        list = LinkedList(Int32).new
        list.push 1
        list.push 2
        a = list.pop
        b = list.pop
        assert a
        assert b
        assert_eq 2, a
        assert_eq 1, b
    end
end