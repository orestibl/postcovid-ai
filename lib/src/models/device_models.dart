part of postcovid_ai;

class DevicesModel {
  List<DeviceModel> _devices = [];

  List<DeviceModel> get devices => _devices;
}

class DeviceModel {
  DeviceManager deviceManager;

  String get type => deviceManager.type;

  DeviceStatus get status => deviceManager.status;

  Stream<DeviceStatus> get deviceEvents => deviceManager.deviceEvents;

  /// The device id.
  String get id => deviceManager.id;

  /// A printer-friendly name for this device.
  String get name => 'Phone';

  /// A printer-friendly description of this device.
  //String get description => deviceTypeDescription[type];
  String get description => (id == null)
      ? 'Device name will appear when the device is connected'
      : 'This phone - $statusString\n$batteryLevel% battery remaining.';

  String get statusString => status.toString().split('.').last;

  /// The battery level of this device.
  int get batteryLevel => deviceManager.batteryLevel;

  /// The icon for this type of device.
  Icon get icon => Icon(Icons.phone_android, size: 50, color: CACHET.GREY_4);

  /// The icon for the runtime state of this device.
  Icon get stateIcon => deviceStateIcon[status];

  DeviceModel(this.deviceManager)
      : assert(deviceManager != null,
            'A DeviceModel must be initialized with a real Device.'),
        super();

  static Map<DeviceStatus, Icon> get deviceStateIcon => {
        DeviceStatus.unknown: Icon(Icons.error_outline, color: CACHET.RED),
        DeviceStatus.error: Icon(Icons.error_outline, color: CACHET.RED),
        DeviceStatus.disconnected: Icon(Icons.close, color: CACHET.YELLOW),
        DeviceStatus.connected: Icon(Icons.check, color: CACHET.GREEN),
        DeviceStatus.sampling: Icon(Icons.save_alt, color: CACHET.ORANGE),
        DeviceStatus.paired:
            Icon(Icons.bluetooth_connected, color: CACHET.DARK_BLUE),
      };
}
