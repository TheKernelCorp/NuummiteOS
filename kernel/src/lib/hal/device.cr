enum DeviceType
  BlockDevice
  CharDevice
end

abstract class Device
  def initialize(@name : String, @type : DeviceType)
    DeviceManager.add_device self
  end

  abstract def write_byte(b : UInt8)
  abstract def read_byte : UInt8
  abstract def ioctl(code : Enum, data)

  def write_string(str : String)
    if @type == DeviceType::BlockDevice
      raise "Cannot write string to block device!"
    end
    ptr = pointerof(str.@c)
    (0...str.bytesize).each do |i|
      write_byte ptr[i]
    end
  end
end
