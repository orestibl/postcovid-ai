import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:carp_core/carp_common/carp_core_common.dart';
import 'package:carp_core/carp_protocols/carp_core_protocols.dart';
import 'package:carp_core/carp_data/carp_core_data.dart';

part 'carp_core_test.g.dart';

void main() {
  StudyProtocol protocol;

  setUp(() {
    protocol = StudyProtocol(ownerId: 'xyz@dtu.dk');

    // Define which devices are used for data collection.
    Smartphone phone = Smartphone(roleName: 'masterphone');
    DeviceDescriptor eSense = DeviceDescriptor(
      roleName: 'eSense',
    );

    protocol
      ..addMasterDevice(phone)
      ..addConnectedDevice(eSense);

    // Define what needs to be measured, on which device, when.
    List<Measure> measures = [
      Measure(type: DataType(NameSpace.CARP, 'light').toString()),
      DataTypeMeasure(type: DataType(NameSpace.CARP, 'gps').toString()),
      PhoneSensorMeasure(
        type: DataType(NameSpace.CARP, 'steps').toString(),
        duration: 10,
      ),
    ];

    ConcurrentTask task = ConcurrentTask(name: 'Start measures')
      ..addMeasures(measures);
    protocol.addTriggeredTask(Trigger(), task, phone);
    protocol.addTriggeredTask(ManualTrigger(), task, phone);
  });

  test('StudyProtocol -> JSON', () async {
    print(protocol);
    print(toJsonString(protocol));
    expect(protocol.ownerId, 'xyz@dtu.dk');
    expect(protocol.triggers.length, 2);
    expect(protocol.triggers.keys.first, '0');
    expect(protocol.tasks.length, 1);
    expect(protocol.triggeredTasks.length, 2);
  });

  test('JSON -> StudyProtocol', () async {
    // Read the study protocol from json file
    String plainJson = File('test/json/study_protocol.json').readAsStringSync();

    StudyProtocol protocol =
        StudyProtocol.fromJson(json.decode(plainJson) as Map<String, dynamic>);

    expect(protocol.ownerId, 'xyz@dtu.dk');
    expect(protocol.masterDevices.first.roleName, 'masterphone');
    print(toJsonString(protocol));
  });

  test('JSON -> Custom StudyProtocol', () async {
    // Read the study protocol from json file
    String plainJson =
        File('test/json/custom_study_protocol.json').readAsStringSync();

    StudyProtocol protocol =
        StudyProtocol.fromJson(json.decode(plainJson) as Map<String, dynamic>);

    expect(protocol.ownerId, '979b408d-784e-4b1b-bb1e-ff9204e072f3');
    expect(protocol.masterDevices.first.roleName, 'Custom device');
    print(toJsonString(protocol));
  });

  test('DataPoint -> JSON', () async {
    DataPoint dataPoint = DataPoint(
      DataPointHeader(
        studyId: '1234',
        dataFormat: DataFormat(NameSpace.CARP, 'light'),
      ),
      Data(),
    );

    print(dataPoint);
    print(toJsonString(dataPoint));
    assert(dataPoint.carpBody != null);
  });
  test('A & B -> JSON', () async {
    A a = A();
    B b = B();
    a.index = 1;
    b.str = 'abc';

    print(toJsonString(a));
    print(toJsonString(b));
  });
}

/// An example class.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class A extends Serializable {
  int index;

  A() : super();

  Function get fromJsonFunction => _$AFromJson;
  factory A.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$AToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class B extends A {
  String str;

  B() : super();

  Function get fromJsonFunction => _$BFromJson;
  factory B.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$BToJson(this);
  String get jsonType => 'dk.cachet.$runtimeType';
}
