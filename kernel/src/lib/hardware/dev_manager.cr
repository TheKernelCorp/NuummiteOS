module Dev
  struct DeviceManager
    @@instance : DeviceManager?

    #@devices = LinkedList(Device).new

    def self.init()
      @@instance = DeviceManager.new
    end

    def self.add_device(device : Device)
      instance = @@instance
      return unless instance
      #instance.add_device device
    end

    def self.get_device(name : String) : Device?
      instance = @@instance
      return unless instance
      #instance.get_device name
    end

    def add_device(device : Device)
      #@devices << device
    end

    def get_device(name : String) : Device?
      #@devices.each { |dev|
      #  next if dev.nil?
      #  return dev if dev.@name == name
      #}
      return nil
    end
  end
end