import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_health_package/health_package.dart';
import 'package:health/health.dart';

/// This is a very simple example of how this sampling package is used with
/// CARP Mobile Sensing (CAMS).
/// NOTE, however, that the code below will not run.
/// See the documentation on how to use CAMS: https://github.com/cph-cachet/carp.sensing-flutter/wiki
void main() async {
  // register this sampling package before using its measures
  SamplingPackageRegistry().register(HealthSamplingPackage());

  // Create a study protocol using a local file to store data
  CAMSStudyProtocol protocol = CAMSStudyProtocol()
    ..name = 'Track patient movement'
    ..owner = ProtocolOwner(
      id: 'AB',
      name: 'Alex Boyon',
      email: 'alex@uni.dk',
    );

  // define which devices are used for data collection
  // in this case, its only this smartphone
  Smartphone phone = Smartphone();
  protocol.addMasterDevice(phone);

  protocol.addTriggeredTask(
      // collect every hour
      PeriodicTrigger(period: Duration(minutes: 60)),
      AutomaticTask()
        ..measures.add(HealthMeasure(
          type: HealthSamplingPackage.HEALTH,
          healthDataType: HealthDataType.BLOOD_GLUCOSE,
        ))
        ..measures.add(HealthMeasure(
          type: HealthSamplingPackage.HEALTH,
          healthDataType: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        ))
        ..measures.add(HealthMeasure(
          type: HealthSamplingPackage.HEALTH,
          healthDataType: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        ))
        ..measures.add(HealthMeasure(
          type: HealthSamplingPackage.HEALTH,
          healthDataType: HealthDataType.HEART_RATE,
        ))
        ..measures.add(HealthMeasure(
          type: HealthSamplingPackage.HEALTH,
          name: 'Step Counts',
          description:
              "Collects the step counts from Apple Health / Google Fit",
          healthDataType: HealthDataType.STEPS,
        )),
      phone);

  protocol.addTriggeredTask(
      // collect every day at 23:00
      RecurrentScheduledTrigger(
          type: RecurrentType.daily, time: Time(hour: 23, minute: 00)),
      AutomaticTask()
        ..measures.add(HealthMeasure(
          type: HealthSamplingPackage.HEALTH,
          healthDataType: HealthDataType.WEIGHT,
        )),
      phone);

  // deploy this protocol using the on-phone deployment service
  StudyDeploymentStatus status =
      await SmartphoneDeploymentService().createStudyDeployment(protocol);

  String studyDeploymentId = status.studyDeploymentId;
  String deviceRolename = status.masterDeviceStatus.device.roleName;

  // create and configure a client manager for this phone
  SmartPhoneClientManager client = SmartPhoneClientManager();
  await client.configure();

  // create a study runtime to control this deployment
  StudyDeploymentController controller =
      await client.addStudy(studyDeploymentId, deviceRolename);

  // configure the controller and resume sampling
  await controller.configure();
  controller.resume();

  // listening and print all data events from the study
  controller.data.forEach(print);
}
