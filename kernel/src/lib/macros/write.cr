macro write(device, data)
  %data = {{ data }}
  %ptr = pointerof(%data.@c)
  device = DeviceManager.get_device {{ device.stringify }}
  if device
      %data.size.times do |i|
          device.write_byte %ptr[i]
      end
  end
end

macro writeln(device, data)
  write {{ device }}, {{ data }}
  write {{ device }}, "\r\n"
end
