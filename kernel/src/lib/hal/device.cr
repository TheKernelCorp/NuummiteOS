enum DeviceType
  BlockDevice
  CharDevice
end

abstract struct Device
  def initialize(@name : String, @type : DeviceType)
    DeviceManager.add_device self
  end
  abstract def write_byte(b : UInt8)
end