def loop
  i = 0
  while true
    yield i
    i += 1
  end
end
