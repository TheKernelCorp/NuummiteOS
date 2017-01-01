class String::Builder
  def initialize(capacity : Int = 64)
  end

  def <<(other)
    String::Builder.new
  end

  def to_s
    String.new
  end
end
