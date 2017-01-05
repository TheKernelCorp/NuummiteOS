class Mem
  def self.stats
    puts "######-Memory Status-#####"
    puts "Sys: #{Heap.size_sys}"
    puts "Real: #{Heap.size_real}"
  end
end
