/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of carp_core_protocols;

/// A description of how a study is to be executed, defining the type(s) of
/// master device(s) ([MasterDeviceDescriptor]) responsible for aggregating data,
/// the optional devices ([DeviceDescriptor]) connected to them, and
/// the [Trigger]s which lead to data collection on said devices.
///
/// This is part of the [carp.protocols](https://github.com/cph-cachet/carp.core-kotlin/blob/develop/docs/carp-protocols.md) domain model.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class StudyProtocol {
  static const String PROTOCOL_NAMESPACE = 'dk.cachet.carp.protocols.domain';

  // maps a task's name and the task
  Map<String, TaskDescriptor> _taskMapProperty;
  Map<String, TaskDescriptor> get _taskMap {
    if (_taskMapProperty == null) {
      _taskMapProperty = {};
      tasks.forEach((task) => _taskMapProperty[task.name] = task);
    }
    return _taskMapProperty;
  }

  /// The owner id of this study.
  /// This property mainly used when the protocol is de-serialized from json.
  String ownerId;

  /// A unique descriptive name for the protocol assigned by the [ProtocolOwner].
  String name;

  /// A longer description of this study.
  String description;

  /// The timestamp of the creation of this protocol in Zulu time.
  DateTime creationDate;

  /// The master devices involved in this protocol.
  List<MasterDeviceDescriptor> masterDevices = [];

  /// The devices this device needs to connect to.
  List<DeviceDescriptor> connectedDevices = [];

  List<DeviceConnection> connections = [];

  /// The set of [Trigger]s which can trigger [TaskDescriptor]s in this study protocol.
  Map<String, Trigger> triggers = {};

  /// The set of tasks which can be triggered as part of this protocol.
  Set<TaskDescriptor> tasks = {};

  /// The tasks (and the devices they are triggered to) for the specified [trigger].
  List<TriggeredTask> triggeredTasks = [];

  List<Map<String, dynamic>> expectedParticipantData = [];

  /// Create a new [StudyProtocol].
  StudyProtocol({
    this.ownerId,
    this.name,
    this.description,
  }) : super() {
    creationDate = DateTime.now().toUtc();
  }

  /// Add a [masterDevice] which is responsible for aggregating and synchronizing
  /// incoming data. Its role name should be unique in the protocol.
  void addMasterDevice(MasterDeviceDescriptor masterDevice) =>
      masterDevices.add(masterDevice);

  /// Add a [device] which is connected to this [masterDevice].
  /// Its role name should be unique in the protocol.
  void addConnectedDevice(DeviceDescriptor device) =>
      connectedDevices.add(device);

  /// Add the [trigger] to this protocol.
  void addTrigger(Trigger trigger) {
    if (triggers.values.contains(trigger)) {
      return;
    } else {
      triggers['${triggers.length}'] = trigger;
    }
  }

  /// Returns the index of the [trigger] in the [triggers].
  /// Returns `-1` if not found.
  int indexOfTrigger(Trigger trigger) {
    // early out if not in the triggers
    if (!triggers.containsValue(trigger)) return -1;
    int index = -1;
    triggers.forEach((key, value) {
      if (trigger == value) index = int.parse(key);
    });
    return index;
    // for (int index = 0; index < triggers.length; index++)
    //   if (triggers.containsKey('$index')) return index;

    // return -1;
  }

  /// Add a [task] to be sent to a [targetDevice] once a [trigger] within this
  /// protocol is initiated.
  ///
  /// In case the [trigger] or [task] are not yet included in this study protocol,
  /// they will be added. Note that the [task.name] has to be unique within a protocol.
  /// The [targetDevice] needs to be added prior to this call since it needs to
  /// be set up as either a master device or connected device.
  void addTriggeredTask(
    Trigger trigger,
    TaskDescriptor task,
    DeviceDescriptor targetDevice,
  ) {
    // add trigger and task to ensure they are included in the protocol
    addTrigger(trigger);
    addTask(task);

    // create and add triggered task
    int triggerId = indexOfTrigger(trigger);

    if (triggerId >= 0) {
      triggeredTasks.add(TriggeredTask(
          triggerId: triggerId, task: task, targetDevice: targetDevice));
    }
  }

  /// Add a set of [tasks] to be sent to a [targetDevice] once a [trigger] within this
  /// protocol is initiated.
  /// In case the [trigger] or [tasks] are not yet included in this study protocol,
  /// they will be added.
  /// The [targetDevice] needs to be added prior to this call since it needs to
  /// be set up as either a master device or connected device.
  void addTriggeredTasks(
    Trigger trigger,
    List<TaskDescriptor> tasks,
    DeviceDescriptor targetDevice,
  ) =>
      tasks.forEach((task) => addTriggeredTask(trigger, task, targetDevice));

  /// Gets all the tasks (and the devices they are triggered to) for the
  /// specified [trigger].
  Set<TriggeredTask> getTriggeredTasks(Trigger trigger) {
    assert(triggers.values.contains(trigger),
        'The passed trigger is not part of this study protocol.');
    int triggerId = indexOfTrigger(trigger);

    Set<TriggeredTask> tt = {};
    // search the list of triggered tasks
    triggeredTasks.forEach((triggeredTask) {
      if (triggeredTask.triggerId == triggerId) {
        tt.add(triggeredTask);
      }
    });

    return tt;
  }

  /// Add the [task] to this protocol.
  void addTask(TaskDescriptor task) {
    tasks.add(task);
    _taskMap[task.name] = task;
  }

  /// Remove the [task] currently present in this configuration
  /// including removing it from any [Trigger]'s which initiate it.
  void removeTask(TaskDescriptor task) {
    // Remove task from triggered tasks
    triggeredTasks.forEach((triggeredTask) {
      if (triggeredTask.taskName == task.name) {
        triggeredTasks.remove(triggeredTask);
      }
    });

    // Remove task itself.
    tasks.remove(task);
    _taskMap?.remove(task.name);
  }

  /// Gets all the tasks triggered for the specified [device].
  /// The [device] must be part of either [masterDevices]
  /// or [connectedDevices].
  Set<TaskDescriptor> getTasksForDevice(DeviceDescriptor device) {
    assert(connectedDevices.contains(device) || masterDevices.contains(device),
        'The passed device is not part of this study protocol.');

    final Set<TaskDescriptor> deviceTasks = {};

    triggeredTasks.forEach((triggeredTask) {
      if (triggeredTask.targetDeviceRoleName == device.roleName) {
        deviceTasks.add(_taskMap[triggeredTask.taskName]);
      }
    });

    return deviceTasks;
  }

  /// Gets all the tasks triggered for the specified [deviceRoleName].
  ///
  /// Returns an empty set if the device is not part of [masterDevices]
  /// or [connectedDevices].
  Set<TaskDescriptor> getTasksForDeviceRoleName(String deviceRoleName) {
    final Set<TaskDescriptor> deviceTasks = {};

    triggeredTasks.forEach((triggeredTask) {
      if (triggeredTask.targetDeviceRoleName == deviceRoleName) {
        deviceTasks.add(_taskMap[triggeredTask.taskName]);
      }
    });
    return deviceTasks;
  }

  Map<String, dynamic> toJson() => _$StudyProtocolToJson(this);
  factory StudyProtocol.fromJson(Map<String, dynamic> json) =>
      _$StudyProtocolFromJson(json);

  String toString() => '$runtimeType - name: $name, ownerId: $ownerId';
}
