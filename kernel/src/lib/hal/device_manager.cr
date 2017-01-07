class DeviceManager
  @@instance = Singleton(DeviceManager).new
  @devices = LinkedList(Device).new

  def self.add_device(device : Device)
    @@instance.get.add_device device
  end

  def self.get_device?(name : String) : Device?
    @@instance.get.get_device? name
  end

  def self.get_device(name : String) : Device
    @@instance.get.get_device name
  end

  def add_device(device : Device)
    @devices.push device
  end

  def get_device?(name : String) : Device?
    get_device(name) { nil }
  end

  def get_device(name : String) : Device
    get_device(name) { raise "Device not found" }
  end

  def get_device(name : String)
    @devices.each { |dev|
      next unless dev
      return dev if dev.@name == name
    }
    yield
  end
end
