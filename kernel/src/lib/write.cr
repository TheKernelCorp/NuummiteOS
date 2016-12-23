macro write(device, data)
    %data = {{ data }}
    %ptr = pointerof(%data.@c)
    %data.@length.times do |i|
        {{ device }}.write_byte %ptr[i]
    end
end

macro writeln(device, data)
    write {{ device }}, {{ data }}
    write {{ device }}, "\r\n"
end