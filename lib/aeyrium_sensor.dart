import 'dart:async';

import 'package:flutter/services.dart';

const EventChannel _sensorEventChannel =
    EventChannel('plugins.aeyrium.com/sensor');

class SensorEvent {
  /// Pitch from the device in radians
  /// A pitch is a rotation around a lateral (X) axis that passes through the device from side to side
  final double beta;

  ///Roll value from the device in radians
  ///A roll is a rotation around a longitudinal (Y) axis that passes through the device from its top to bottom
  final double gamma;

  // A yaw is a rotation around a Z
  final double alpha;

  SensorEvent(this.beta, this.gamma, this.alpha);

  @override
  String toString() => '[Event: (beta: $beta, gamma: $gamma,alpha: $alpha)]';
}

class AeyriumSensor {
  static Stream<SensorEvent> _sensorEvents;

  AeyriumSensor._();

  /// A broadcast stream of events from the device rotation sensor.
  static Stream<SensorEvent> get sensorEvents {
    if (_sensorEvents == null) {
      _sensorEvents = _sensorEventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _listToSensorEvent(event.cast<double>()));
    }
    return _sensorEvents;
  }

  static SensorEvent _listToSensorEvent(List<double> list) {
    return SensorEvent(list[0], list[1], list[2]);
  }
}
