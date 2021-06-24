part of postcovid_ai;

class ProbeDescription {
  static Map<String, String> get probeTypeDescription => {
    DataType.UNKNOWN.toString(): 'Unknown Probe',
    DeviceSamplingPackage.MEMORY:
      'Collecting free physical and virtual memory.',
    DeviceSamplingPackage.DEVICE: 'Basic Device (Phone) Information.',
    DeviceSamplingPackage.BATTERY:
      'Collecting battery level and charging status.',
    SensorSamplingPackage.PEDOMETER:
      'Collecting step counts on a regular basis.',
    SensorSamplingPackage.ACCELEROMETER:
      "Collecting sensor data from the phone's onboard accelerometer.",
    SensorSamplingPackage.GYROSCOPE:
      "Collecting sensor data from the phone's onboard gyroscope.",
    SensorSamplingPackage.LIGHT:
      'Measures ambient light in lux on a regular basis.',
    // ConnectivitySamplingPackage.BLUETOOTH:
    //     'Collecting nearby bluetooth devices on a regular basis.',
    // ConnectivitySamplingPackage.WIFI:
    //     'Collecting names of connected wifi networks (SSID and BSSID)',
    // ConnectivitySamplingPackage.CONNECTIVITY:
    //     'Collecting information on connectivity status and mode.',
    AudioSamplingPackage.AUDIO:
      'Records ambient sound on a regular basis.',
    AudioSamplingPackage.NOISE:
      'Measures noise level in decibel on a regular basis.',
    //AppsSamplingPackage.APPS: 'Collecting a list of installed apps.',
    //AppsSamplingPackage.APP_USAGE: 'Collects app usage statistics.',
    //CommunicationSamplingPackage.TEXT_MESSAGE_LOG: 'Collects the SMS message log.',
    //CommunicationSamplingPackage.TEXT_MESSAGE: 'Collecting in/out-going SMS text messages.',
    //CommunicationSamplingPackage.PHONE_LOG: 'Collects the phone call log.',
    //CommunicationSamplingPackage.CALENDAR: 'Collects entries from phone calendars.',
    DeviceSamplingPackage.SCREEN:
      'Collecting screen events (on/off/unlock).',
    ContextSamplingPackage.LOCATION:
      'Collecting location information.',
    ContextSamplingPackage.GEOLOCATION:
      "Listening to changes in the phone's geo-location.",
    ContextSamplingPackage.ACTIVITY:
      'Recognize physical activity, e.g. sitting, walking, biking.',
    ContextSamplingPackage.WEATHER:
      'Collects local weather.',
    ContextSamplingPackage.AIR_QUALITY:
      'Collects local air quality.',
    ContextSamplingPackage.GEOFENCE:
      'Track movement in/out of this geofence.',
    ContextSamplingPackage.MOBILITY:
      'Mobility features calculated from location data.',
    //ESenseSamplingPackage.ESENSE_BUTTON: 'eSense button events.',
    //ESenseSamplingPackage.ESENSE_SENSOR: 'eSense IMU sensor events.',
  };

  static Map<String, Icon> get probeTypeIcon => {
    DataType.UNKNOWN.toString():
      Icon(Icons.error, size: 50, color: Colors.grey),
    DeviceSamplingPackage.MEMORY:
      Icon(Icons.memory, size: 50, color: Colors.grey),
    DeviceSamplingPackage.DEVICE:
      Icon(Icons.phone_android, size: 50, color: Colors.grey),
    DeviceSamplingPackage.BATTERY:
      Icon(Icons.battery_charging_full, size: 50, color: Colors.green),
    SensorSamplingPackage.PEDOMETER:
      Icon(Icons.directions_walk, size: 50, color: Colors.purple),
    SensorSamplingPackage.ACCELEROMETER:
      Icon(Icons.adb, size: 50, color: Colors.grey),
    SensorSamplingPackage.GYROSCOPE:
      Icon(Icons.adb, size: 50, color: Colors.grey),
    SensorSamplingPackage.LIGHT:
      Icon(Icons.highlight, size: 50, color: Colors.yellow),
    // ConnectivitySamplingPackage.BLUETOOTH:
    //     Icon(Icons.bluetooth_searching, size: 50, color: Colors.DARK_BLUE),
    // ConnectivitySamplingPackage.WIFI:
    //     Icon(Icons.wifi, size: 50, color: Colors.purple),
    // ConnectivitySamplingPackage.CONNECTIVITY:
    //     Icon(Icons.cast_connected, size: 50, color: Colors.green),
    AudioSamplingPackage.AUDIO:
      Icon(Icons.mic, size: 50, color: Colors.orange),
    AudioSamplingPackage.NOISE:
      Icon(Icons.hearing, size: 50, color: Colors.yellow),
    //AppsSamplingPackage.APPS: Icon(Icons.apps, size: 50, color: Colors.LIGHT_green),
    //AppsSamplingPackage.APP_USAGE: Icon(Icons.get_app, size: 50, color: Colors.LIGHT_green),
    //CommunicationSamplingPackage.TEXT_MESSAGE_LOG: Icon(Icons.textsms, size: 50, color: Colors.purple),
    //CommunicationSamplingPackage.TEXT_MESSAGE: Icon(Icons.text_fields, size: 50, color: Colors.purple),
    //CommunicationSamplingPackage.PHONE_LOG: Icon(Icons.phone_in_talk, size: 50, color: Colors.orange),
    //CommunicationSamplingPackage.CALENDAR: Icon(Icons.event, size: 50, color: Colors.cyan),
    DeviceSamplingPackage.SCREEN: Icon(Icons.screen_lock_portrait,
        size: 50, color: Colors.purple),
    ContextSamplingPackage.LOCATION:
      Icon(Icons.location_searching, size: 50, color: Colors.cyan),
    ContextSamplingPackage.GEOLOCATION:
      Icon(Icons.my_location, size: 50, color: Colors.yellow),
    ContextSamplingPackage.ACTIVITY:
      Icon(Icons.directions_bike, size: 50, color: Colors.orange),
    ContextSamplingPackage.WEATHER:
      Icon(Icons.cloud, size: 50, color: Colors.lightBlue),
    ContextSamplingPackage.AIR_QUALITY:
      Icon(Icons.warning, size: 50, color: Colors.grey),
    ContextSamplingPackage.GEOFENCE:
      Icon(Icons.location_on, size: 50, color: Colors.cyan),
    ContextSamplingPackage.MOBILITY:
      Icon(Icons.location_on, size: 50, color: Colors.orange),
    //ESenseSamplingPackage.ESENSE_BUTTON:
    //Icon(Icons.radio_button_checked, size: 50, color: Colors.DARK_BLUE),
    //ESenseSamplingPackage.ESENSE_SENSOR:
    //Icon(Icons.headset, size: 50, color: Colors.DARK_BLUE),
  };

  static Map<ProbeState, Icon> get probeStateIcon => {
    ProbeState.created: Icon(Icons.child_care, color: Colors.grey),
    ProbeState.initialized: Icon(Icons.check, color: Colors.purple),
    ProbeState.resumed:
      Icon(Icons.radio_button_checked, color: Colors.green),
    ProbeState.paused:
      Icon(Icons.radio_button_unchecked, color: Colors.green),
    ProbeState.stopped: Icon(Icons.close, color: Colors.grey),
    ProbeState.undefined: Icon(Icons.error_outline, color: Colors.red),
  };
}