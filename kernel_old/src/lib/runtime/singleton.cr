struct Singleton(T)
  @value : T?

  def get : T
    value = @value
    unless value
      value = T.new
      @value = value
    end
    value
  end
end
