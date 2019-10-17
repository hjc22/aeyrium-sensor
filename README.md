
# fork自aeyrium_sensor，修改为 Flutter 获取设备方向 在X，Y,Z 旋转的不同的角度的插件，同WEB标准

支持ios/android


```yaml
dependencies:
  aeyrium_sensor: 
       git: https://github.com/hjc22/aeyrium-sensor
```

## 使用

``` dart
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
    
    // 获取的是角度
    StreamSubscription sub = AeyriumSensor.sensorEvents.listen((SensorEvent event) {
      print("alpha ${event.alpha} and beta ${event.beta} and gamma ${event.gamma}")
      
    });
    
    // 取消监听
    sub.cancel();

```

