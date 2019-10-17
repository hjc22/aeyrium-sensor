#import "AeyriumSensorPlugin.h"
#import <CoreMotion/CoreMotion.h>
#import <GLKit/GLKit.h>

@implementation AeyriumSensorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTSensorStreamHandler* sensorStreamHandler =
      [[FLTSensorStreamHandler alloc] init];
  FlutterEventChannel* sensorChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.aeyrium.com/sensor"
                                binaryMessenger:[registrar messenger]];
  [sensorChannel setStreamHandler:sensorStreamHandler];
}

@end

CMMotionManager* _motionManager;

void _initMotionManager() {
  if (!_motionManager) {
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 0.5;
  }
}

static void sendData(Float64 pitch, Float64 roll, Float64 yaw, FlutterEventSink sink) {
  NSMutableData* event = [NSMutableData dataWithCapacity:3 * sizeof(Float64)];
  [event appendBytes:&pitch length:sizeof(Float64)];
  [event appendBytes:&roll length:sizeof(Float64)];
    [event appendBytes:&yaw length:sizeof(Float64)];
  sink([FlutterStandardTypedData typedDataWithFloat64:event]);
}


@implementation FLTSensorStreamHandler

double degrees(double radians) {
  return (180/M_PI) * radians;
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
   [_motionManager
   startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:[[NSOperationQueue alloc] init]
   withHandler:^(CMDeviceMotion* data, NSError* error) {
      CMAttitude *attitude = data.attitude;
    
     double pitch = degrees(attitude.pitch);
     double roll =  degrees(attitude.roll);
       double yaw = degrees(attitude.yaw);
     sendData(pitch, roll , yaw, eventSink);
   }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopDeviceMotionUpdates];
  return nil;
}

@end
