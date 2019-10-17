package com.aeyrium.sensor;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.view.Surface;
import android.view.WindowManager;
import android.app.Activity;
import android.content.Context;

/** AeyriumSensorPlugin */
public class AeyriumSensorPlugin implements EventChannel.StreamHandler {

  private static final String SENSOR_CHANNEL_NAME =
          "plugins.aeyrium.com/sensor";
  private static final int SENSOR_DELAY_MICROS = 1000 * 1000;//16 * 1000;
  private WindowManager mWindowManager;
  private SensorEventListener sensorEventListener;
  private SensorManager sensorManager;
  private Sensor sensor;
  private int mLastAccuracy;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final EventChannel sensorChannel =
            new EventChannel(registrar.messenger(), SENSOR_CHANNEL_NAME);
    sensorChannel.setStreamHandler(
            new AeyriumSensorPlugin(registrar.context(), Sensor.TYPE_ORIENTATION, registrar));

  }

  private AeyriumSensorPlugin(Context context, int sensorType, Registrar registrar) {
    mWindowManager = registrar.activity().getWindow().getWindowManager();
    sensorManager = (SensorManager) context.getSystemService(context.SENSOR_SERVICE);
    sensor = sensorManager.getDefaultSensor(sensorType);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    sensorEventListener = createSensorEventListener(events);
    sensorManager.registerListener(sensorEventListener, sensor, sensorManager.SENSOR_DELAY_UI);
  }

  @Override
  public void onCancel(Object arguments) {
    if (sensorManager != null && sensorEventListener != null){
        sensorManager.unregisterListener(sensorEventListener);
    }
  }

  static double degrees(double radians) {
    return (180/ Math.PI) * radians;
  }

  SensorEventListener createSensorEventListener(final EventChannel.EventSink events) {
    return new SensorEventListener() {
      @Override
      public void onAccuracyChanged(Sensor sensor, int accuracy) {
        if (mLastAccuracy != accuracy) {
          mLastAccuracy = accuracy;
        }
      }

      @Override
      public void onSensorChanged(SensorEvent event) {
        if (mLastAccuracy == SensorManager.SENSOR_STATUS_UNRELIABLE) {
          return;
        }

        updateOrientation(event.values, events);
      }
    };
  }
  
  private void updateOrientation(float[] rotationVector, EventChannel.EventSink events) {
    double[] sensorValues = new double[3];
    sensorValues[0] = rotationVector[1];
    sensorValues[1] = rotationVector[2];
    sensorValues[2] = rotationVector[0];
    events.success(sensorValues);
  }
}