/*
 * Copyright 2018-2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of runtime;

/// Returns the relevant [TriggerExecutor] based on the type of [trigger].
TriggerExecutor getTriggerExecutor(Trigger trigger) {
  switch (trigger.runtimeType) {
    // actually, the base Trigger and CAMSTrigger classes is not supposed to be used
    // but if used, treat them as an ImmediateTrigger
    case Trigger:
    case CAMSTrigger:
    case ImmediateTrigger:
      return ImmediateTriggerExecutor(trigger);
    case DelayedTrigger:
      return DelayedTriggerExecutor(trigger);
    case PeriodicTrigger:
      return PeriodicTriggerExecutor(trigger);
    case DateTimeTrigger:
      return DateTimeTriggerExecutor(trigger);
    case RecurrentScheduledTrigger:
      return RecurrentScheduledTriggerExecutor(trigger);
    case CronScheduledTrigger:
      return CronScheduledTriggerExecutor(trigger);
    case SamplingEventTrigger:
      return SamplingEventTriggerExecutor(trigger);
    case ConditionalSamplingEventTrigger:
      return ConditionalSamplingEventTriggerExecutor(trigger);
    case RandomRecurrentTrigger:
      return RandomRecurrentTriggerExecutor(trigger);
    case ManualTrigger:
      return PassiveTriggerExecutor(trigger);
    default:
      return ImmediateTriggerExecutor(trigger);
  }
}

// ---------------------------------------------------------------------------------------------------------
// TRIGGER EXECUTORS
// ---------------------------------------------------------------------------------------------------------

/// Responsible for handling the execution of a [Trigger].
///
/// This is an abstract class. For each specific type of [Trigger],
/// a corresponding implementation of this class exists.
abstract class TriggerExecutor extends Executor {
  CAMSTrigger trigger;
  TriggerExecutor(this.trigger);

  /// Returns a list of the running probes in this [TriggerExecutor].
  /// This is a combination of the running probes in all task executors.
  List<Probe> get probes {
    List<Probe> _probes = [];
    executors.forEach((executor) {
      if (executor is TaskExecutor) {
        executor.probes.forEach((probe) {
          _probes.add(probe);
        });
      }
    });
    return _probes;
  }
}

/// Executes a [ImmediateTrigger], i.e. starts sampling immediately.
class ImmediateTriggerExecutor extends TriggerExecutor {
  ImmediateTriggerExecutor(CAMSTrigger trigger) : super(trigger);
}

/// Executes a [PassiveTrigger].
class PassiveTriggerExecutor extends TriggerExecutor {
  PassiveTriggerExecutor(PassiveTrigger trigger) : super(trigger) {
    trigger.executor = ImmediateTriggerExecutor(trigger);
    _group.add(trigger.executor.data);
  }

  // Forward to the embedded trigger executor
  void onInitialize(Measure measure) =>
      (trigger as PassiveTrigger).executor.initialize(measure);

  // A no-op methods since a ManualTrigger can only be resumed/paused
  // using the resume/pause methods on the ManualTrigger.
  Future onResume() async {}
  Future onPause() async {}

  // Forward to the embedded trigger executor
  Future onRestart({Measure measure}) async =>
      (trigger as PassiveTrigger).executor.restart();
  Future onStop() async => (trigger as PassiveTrigger).executor.stop();

  List<Probe> get probes => (trigger as PassiveTrigger).executor.probes;
}

/// Executes a [DelayedTrigger], i.e. resumes sampling after the specified delay.
/// Once started, it can be paused / resumed as any other [Executor].
class DelayedTriggerExecutor extends TriggerExecutor {
  DelayedTriggerExecutor(DelayedTrigger trigger) : super(trigger);

  Future onResume() async {
    Timer((trigger as DelayedTrigger).delay, () {
      // after a delay, resume this trigger and its tasks
      super.onResume();
    });
  }
}

/// Executes a [PeriodicTrigger], i.e. resumes sampling on a regular basis for a given period of time.
///
/// It is required that both the [period] and the [duration] of the [PeriodicTrigger] is specified
/// to make sure that this executor is properly resumed and paused again.
class PeriodicTriggerExecutor extends TriggerExecutor {
  Duration period, duration;
  Timer timer;

  PeriodicTriggerExecutor(PeriodicTrigger trigger) : super(trigger) {
    assert(trigger.period != null,
        'The period in a PeriodicTrigger must be specified.');
    assert(trigger.duration != null,
        'The duration in a PeriodicTrigger must be specified.');
    period = trigger.period;
    duration = trigger.duration;
  }

  Future onResume() async {
    // resume first time, and pause after the specified duration.
    await super.onResume();
    Timer(duration, () {
      super.onPause();
    });

    // then create a recurrent timer that resume periodically.
    timer = Timer.periodic(period, (t) {
      super.onResume();
      // create a timer that pause the sampling after the specified duration.
      Timer(duration, () {
        super.onPause();
      });
    });
  }

  Future onPause() async {
    timer.cancel();
    await super.onPause();
  }
}

/// Executes a [DateTimeTrigger] on the specified [DateTimeTrigger.schedule]
/// date and time.
class DateTimeTriggerExecutor extends TriggerExecutor {
  Duration delay, duration;
  Timer timer;

  DateTimeTriggerExecutor(DateTimeTrigger trigger) : super(trigger) {
    assert(trigger.schedule != null,
        'The schedule of a ScheduledTrigger must be specified.');
    assert(trigger.schedule.isAfter(DateTime.now()),
        'The schedule of the ScheduledTrigger cannot be in the past.');
    delay = trigger.schedule.difference(DateTime.now());
    duration = trigger.duration;
  }

  Future onResume() async {
    timer = Timer(delay, () {
      // after the waiting time (delay) is over, resume this trigger
      super.onResume();
      if (duration != null) {
        // create a timer that stop the sampling after the specified duration.
        // if the duration is null, the sampling never stops, i.e. runs forever.
        Timer(duration, () {
          stop();
        });
      }
    });
  }

  Future onPause() async {
    timer.cancel();
    await super.onPause();
  }
}

/// Executes a [RecurrentScheduledTrigger].
class RecurrentScheduledTriggerExecutor extends PeriodicTriggerExecutor {
  RecurrentScheduledTrigger _myTrigger;

  RecurrentScheduledTriggerExecutor(RecurrentScheduledTrigger trigger)
      : super(trigger) {
    _myTrigger = trigger;
  }

  Future onResume() async {
    // check if there is a remembered trigger date
    if (_myTrigger.remember) {
      String _savedFirstOccurrence =
          Settings().preferences.get(_myTrigger.triggerId);
      debug('savedFirstOccurrence : $_savedFirstOccurrence');

      if (_savedFirstOccurrence != null) {
        DateTime savedDate = DateTime.tryParse(_savedFirstOccurrence);
        if (savedDate.isBefore(DateTime.now())) {
          debug(
              'There is a saved timestamp in the past - resuming this trigger now: ${DateTime.now().toString()}.');
          executors.forEach((executor) => executor.resume());
          // create a timer that pause the sampling after the specified duration.
          Timer(duration, () {
            executors.forEach((executor) => executor.pause());
          });
        }
      }

      // save the day of the first occurrence for later use
      await Settings().preferences.setString(
          _myTrigger.triggerId, _myTrigger.firstOccurrence.toUtc().toString());
      debug(
          'saving firstOccurrence : ${_myTrigger.firstOccurrence.toUtc().toString()}');
    }

    // below is 'normal' (i.e., non-remember) behavior
    Duration _delay = _myTrigger.firstOccurrence.difference(DateTime.now());
    debug('delay: $_delay');
    if (_myTrigger.end == null || _myTrigger.end.isAfter(DateTime.now())) {
      Timer(_delay, () async {
        debug('delay finished, now resuming...');
        if (_myTrigger.remember) {
          // replace the entry of the first occurrence to the next occurrence date
          DateTime nextOccurrence = DateTime.now().add(period);
          Settings().preferences.setString(
              _myTrigger.triggerId, nextOccurrence.toUtc().toString());
          debug('saving nextOccurrence: $nextOccurrence');
        }
        await super.onResume();
      });
    }
  }
}

/// Executes a [CronScheduledTrigger] based on the specified cron job.
class CronScheduledTriggerExecutor extends TriggerExecutor {
  cron.Cron _cron;
  cron.Schedule _schedule;
  cron.ScheduledTask _scheduledTask;

  CronScheduledTriggerExecutor(CronScheduledTrigger trigger) : super(trigger) {
    _schedule = cron.Schedule.parse(trigger.cronExpression);
    _cron = cron.Cron();
  }

  Future onResume() async {
    debug(
        'creating cron job : ${(trigger as CronScheduledTrigger).toString()}');
    _scheduledTask = _cron.schedule(_schedule, () async {
      debug('resuming cron job : ${DateTime.now().toString()}');
      await super.onResume();
      Timer((trigger as CronScheduledTrigger).duration, () => super.onPause());
    });
  }

  Future onPause() async {
    await _scheduledTask.cancel();
    await super.onPause();
  }
}

/// Executes a [SamplingEventTrigger] based on the specified
/// [SamplingEventTrigger.measureType] and [SamplingEventTrigger.resumeCondition].
class SamplingEventTriggerExecutor extends TriggerExecutor {
  SamplingEventTriggerExecutor(SamplingEventTrigger trigger) : super(trigger);

  StreamSubscription<DataPoint> _subscription;

  Future onResume() async {
    SamplingEventTrigger eventTrigger = trigger as SamplingEventTrigger;
    // start listen for events of the specified type
    _subscription = ProbeRegistry()
        .eventsByType(eventTrigger?.measureType?.toString())
        .listen((dataPoint) {
      if ((eventTrigger?.resumeCondition == null) ||
          (dataPoint.carpBody as Datum)
              .equivalentTo(eventTrigger?.resumeCondition)) super.onResume();
      if (eventTrigger?.pauseCondition != null &&
          (dataPoint.carpBody as Datum)
              .equivalentTo(eventTrigger?.pauseCondition)) super.onPause();
    });
  }

  Future onPause() async {
    await _subscription.cancel();
    await super.onPause();
  }
}

/// Executes a [ConditionalSamplingEventTrigger] based on the specified
/// [ConditionalSamplingEventTrigger.measureType] and their
/// [ConditionalSamplingEventTrigger.resumeCondition] and
/// [ConditionalSamplingEventTrigger.pauseCondition].
class ConditionalSamplingEventTriggerExecutor extends TriggerExecutor {
  ConditionalSamplingEventTriggerExecutor(
      ConditionalSamplingEventTrigger trigger)
      : super(trigger);

  StreamSubscription<DataPoint> _subscription;

  Future onResume() async {
    ConditionalSamplingEventTrigger eventTrigger =
        trigger as ConditionalSamplingEventTrigger;

    // listen for event of the specified type
    _subscription = ProbeRegistry()
        .eventsByType(eventTrigger?.measureType.toString())
        .listen((dataPoint) {
      if (eventTrigger?.resumeCondition != null &&
          eventTrigger?.resumeCondition(dataPoint)) super.onResume();
      if (eventTrigger?.pauseCondition != null &&
          eventTrigger?.pauseCondition(dataPoint)) super.onPause();
    });
  }

  Future onPause() async {
    await _subscription.cancel();
    await super.onPause();
  }
}

/// Executes a [RandomRecurrentTrigger] triggering N times per day within a
/// defined period of time.
class RandomRecurrentTriggerExecutor extends TriggerExecutor {
  cron.Cron _cron = cron.Cron();
  cron.ScheduledTask _scheduledTask;
  List<Timer> _timers = [];

  RandomRecurrentTriggerExecutor(RandomRecurrentTrigger trigger)
      : super(trigger);

  Time get startTime => (trigger as RandomRecurrentTrigger).startTime;
  Time get endTime => (trigger as RandomRecurrentTrigger).endTime;
  int get minNumberOfTriggers =>
      (trigger as RandomRecurrentTrigger).minNumberOfTriggers;
  int get maxNumberOfTriggers =>
      (trigger as RandomRecurrentTrigger).maxNumberOfTriggers;
  Duration get duration => (trigger as RandomRecurrentTrigger).duration;

  /// Get a random number of samples for the day
  int get numberOfSampling =>
      Random().nextInt(maxNumberOfTriggers) + minNumberOfTriggers;

  /// Generate N random times between startTime and endTime
  List<Time> get samplingTimes {
    List<Time> _samplingTimes = [];
    for (int i = 0; i <= numberOfSampling; i++) {
      int randomHour =
          Random().nextInt(endTime.hour - startTime.hour) + startTime.hour;
      int randomMinutes = Random().nextInt(60);
      Time randomTime = Time(hour: randomHour, minute: randomMinutes);

      // check edge-cases
      randomTime = (randomTime.isAfter(endTime))
          ? Time(hour: randomHour - 1, minute: randomMinutes)
          : randomTime;
      randomTime = (randomTime.isBefore(startTime))
          ? Time(hour: randomHour + 1, minute: randomMinutes)
          : randomTime;

      _samplingTimes.add(randomTime);
    }
    return _samplingTimes;
  }

  Future onResume() async {
    // set up a cron job that generates the random triggers once pr day at [startTime]
    final String cronJob = '${startTime.minute} ${startTime.hour} * * *';
    debug('$runtimeType - creating cron job : $cronJob');

    _scheduledTask = _cron.schedule(cron.Schedule.parse(cronJob), () async {
      debug('$runtimeType - resuming cron job : ${DateTime.now().toString()}');

      // empty the list of timers.
      _timers = [];

      // get a random number of trigger time for today, and for each set up a
      // timer that triggers the super.onResum() method.
      samplingTimes.forEach((time) {
        // find the delay - note, that none of the delays can be negative,
        // since we are at [startTime]
        Duration delay = time.difference(startTime);
        Timer timer = Timer(delay, () async {
          await super.onResume();
          // now set up a timer that waits until the sampling duration ends
          Timer(duration, () => super.onPause());
        });
        _timers.add(timer);
      });
    });
  }

  Future onPause() async {
    // cancel all the timer that might have been started
    for (var timer in _timers) timer.cancel();
    // cancel the daily cronn job
    await _scheduledTask.cancel();
    await super.onPause();
  }
}
