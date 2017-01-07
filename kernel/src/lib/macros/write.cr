macro write(device, data)
  %device = DeviceManager.get_device? {{ device.stringify }}
  %device.write_string({{ data }}) if %device
end

macro write!(data)
  RESCUE_TERM.write_string({{ data }})
end

macro writeln(device, data)
  write {{ device }}, {{ data }}
  write {{ device }}, "\r\n"
end

macro writeln!(data)
  write! {{ data }}
  write! "\r\n"
end
