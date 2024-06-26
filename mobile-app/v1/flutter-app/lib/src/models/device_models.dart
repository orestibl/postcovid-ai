part of postcovid_ai;

class DevicesModel {
  List<DeviceModel> _devices = [];
  List<DeviceModel> get devices => _devices;
}

class DeviceModel {
  DeviceManager deviceManager;
  String get type => deviceManager.type;
  DeviceStatus get status => deviceManager.status;
  Stream<DeviceStatus> get deviceEvents => deviceManager.statusEvents;

  /// The device id.
  String get id => deviceManager.id;

  /// A printer-friendly name for this device.
  String get name => deviceTypeName[type];

  /// A printer-friendly description of this device.
  //String get description => deviceTypeDescription[type];
  String get description => (id == null)
      ? 'Device name will appear when the device is connected'
      : '${deviceTypeDescription[type]} - $statusString\n$batteryLevel% battery remaining.';

  String get statusString => status.toString().split('.').last;

  /// The battery level of this device.
  int get batteryLevel => deviceManager.batteryLevel;

  /// The icon for this type of device.
  Icon get icon => deviceTypeIcon[type];

  /// The icon for the runtime state of this device.
  Icon get stateIcon => deviceStateIcon[status];

  DeviceModel(this.deviceManager)
      : assert(deviceManager != null,
            'A DeviceModel must be initialized with a real Device.'),
        super();

  static Map<String, String> get deviceTypeName => {
    Smartphone.DEVICE_TYPE: 'Phone',
  };

  static Map<String, String> get deviceTypeDescription => {
    Smartphone.DEVICE_TYPE: 'This phone',
  };

  static Map<String, Icon> get deviceTypeIcon => {
    Smartphone.DEVICE_TYPE:
      Icon(Icons.phone_android, size: 50, color: Colors.grey),
  };

  static Map<DeviceStatus, Icon> get deviceStateIcon => {
        DeviceStatus.unknown: Icon(Icons.error_outline, color: Colors.red),
        DeviceStatus.error: Icon(Icons.error_outline, color: Colors.red),
        DeviceStatus.disconnected: Icon(Icons.close, color: Colors.yellow),
        DeviceStatus.connected: Icon(Icons.check, color: Colors.green),
        DeviceStatus.sampling: Icon(Icons.save_alt, color: Colors.orange),
        DeviceStatus.paired:
            Icon(Icons.bluetooth_connected, color: Colors.blue),
      };
}
