## Android Oreo MR1 Location Service 调用流程分析

### 摘要
本文的主要内容是分析Android App通过Location Service从GPS设备获取位置信息的一般流程，简述各功能模块的结构和组成，论证在HAL层实现虚拟位置服务不存在可行性，并提出一种可行的解决方案。

### Overview
```
[Application]
    |
[Location Manager]
    |
--binder--
    |
[Location Manager Service]
    |
[Location Provider] (gps only)
    |
--hwbinder--
    |
[HAL Implementation]
```

### HAL Implementation

GPS HAL在AOSP中的示例实现可参考qemu的gps HAL，此实现并没有从Linux设备节点获取NMEA数据，而是通过QEMU Pipe从模拟器中获取用户指定的虚拟位置数据的NMEA数据，通过epoll监听pipe，产生控制数据时，进行对应处理；产生位置数据时，解析后交由Location Provider处理。

文件位于：

```
device/generic/goldfish/gps/gps_qemu.c
```

由hw_module_t的定义HAL的名称、版本、作者，及方法集合等。入口点为gps_module_methods，类型为gps_module_methods。

```
struct hw_module_t HAL_MODULE_INFO_SYM = {
    .tag = HARDWARE_MODULE_TAG,
    .version_major = 1,
    .version_minor = 0,
    .id = GPS_HARDWARE_MODULE_ID,
    .name = "Goldfish GPS Module",
    .author = "The Android Open Source Project",
    .methods = &gps_module_methods,
};
```

在HAL中仅指定了open方法的实现。
```
static struct hw_module_methods_t gps_module_methods = {
    .open = open_gps
};
```

在open_gps方法中设置gps的方法集合。

```
static int open_gps(const struct hw_module_t* module,
                    char const* __unused name,
                    struct hw_device_t** device)
{
    ...
    dev->get_gps_interface = gps__get_gps_interface;
    ...
}
```
方法位于qemuGpsInterface结构体。

```
const GpsInterface* gps__get_gps_interface(struct gps_device_t* __unused dev)
{
    return &qemuGpsInterface;
}
```

qemuGpsInterface结构体中包含初始化、启动、关闭等操作。

```
static const GpsInterface  qemuGpsInterface = {
    sizeof(GpsInterface),
    qemu_gps_init,
    qemu_gps_start,
    qemu_gps_stop,
    qemu_gps_cleanup,
    qemu_gps_inject_time,
    qemu_gps_inject_location,
    qemu_gps_delete_aiding_data,
    qemu_gps_set_position_mode,
    qemu_gps_get_extension,
};
```

#### Init Process

初始化过程中qemu_gps_init方法调用了gps_state_init方法，并指定了callbacks成员的徽调函数。

```
typedef struct {
    int                     init;
    int                     fd;
    GpsCallbacks            callbacks;
    pthread_t               thread;
    int                     control[2];
} GpsState;
```

#### Thread 处理

回调函数中的线程处理，主要是通过epoll监听pipe文件节点，针对控制信息做对应的控制动作，对gps位置信息，进行解析后，经过libhardware，交给Location Provider处理。

```
static void
gps_state_thread( void*  arg )
{
    ...
    epoll_register( epoll_fd, control_fd );
    epoll_register( epoll_fd, gps_fd );
    ...
    for (;;) {
        ...
        nevents = epoll_wait( epoll_fd, events, 2, timeout );
        ...
        for (ne = 0; ne < nevents; ne++) {
            ...
            if ((events[ne].events & EPOLLIN) != 0) {
                ...
                if (fd == control_fd)
                {
                    ...
                    do {
                        ret = read( fd, &cmd, 1 );
                    } while (ret < 0 && errno == EINTR);

                    if (cmd == CMD_QUIT) {
                        ...
                    }
                    else if (cmd == CMD_START) {
                        ...
                    }
                    else if (cmd == CMD_STOP) {
                        ...
                    }
                }
                else if (fd == gps_fd)
                {
                    ...
                    for (;;) {
                        ...
                        ret = read( fd, buff, sizeof(buff) );
                        ...
                        for (nn = 0; nn < ret; nn++)
                            nmea_reader_addc( reader, buff[nn] );
                            ...
                    }
                }

}
```

### HAL Interface

GPS HAL接口的源码位于：

```
hardware/libhardware/include/hardware/gps.h
hardware/libhardware/include/hardware/gnss-base.h
```

定义了GpsLocation结构体。

```
/** Represents a location. */
typedef struct {
    /** set to sizeof(GpsLocation) */
    size_t          size;
    /** Contains GpsLocationFlags bits. */
    uint16_t        flags;
    /** Represents latitude in degrees. */
    double          latitude;
    /** Represents longitude in degrees. */
    double          longitude;
    /**
     * Represents altitude in meters above the WGS 84 reference ellipsoid.
     */
    double          altitude;
    /** Represents speed in meters per second. */
    float           speed;
    /** Represents heading in degrees. */
    float           bearing;
    /** Represents expected accuracy in meters. */
    float           accuracy;
    /** Timestamp for the location fix. */
    GpsUtcTime      timestamp;
} GpsLocation;
```

HAL接口位于：

```
interfaces/gnss/1.0/types.hal
```

定义了GnssLocation结构体。经由
NMEA -> GpsLocation(c++) -> GnssLocation(c++) -> Location(java)转换，最终由App获取。

```
/** Represents a location. */
struct GnssLocation {
    /** Contains GnssLocationFlags bits. */
    bitfield<GnssLocationFlags> gnssLocationFlags;

    /** Represents latitude in degrees. */
    double latitudeDegrees;

    /** Represents longitude in degrees. */
    double longitudeDegrees;

    /**
     * Represents altitude in meters above the WGS 84 reference ellipsoid.
     */
    double altitudeMeters;

    /** Represents speed in meters per second. */
    float speedMetersPerSec;

    /** Represents heading in degrees. */
    float bearingDegrees;

    /**
    * Represents expected horizontal position accuracy, radial, in meters
    * (68% confidence).
    */
    float horizontalAccuracyMeters;

    /**
    * Represents expected vertical position accuracy in meters
    * (68% confidence).
    */
    float verticalAccuracyMeters;

    /**
    * Represents expected speed accuracy in meter per seconds
    * (68% confidence).
    */
    float speedAccuracyMetersPerSecond;

    /**
    * Represents expected bearing accuracy in degrees
    * (68% confidence).
    */
    float bearingAccuracyDegrees;

    /** Timestamp for the location fix. */
    GnssUtcTime timestamp;
};
```

### Location Provider

应用程序可见三种provider：
* passive 转发其他Provider产生的Location。
* network 获取特定Package提供的Location。
* gps 获取GPS、AGPS的Location。

除此之外还有：
* mock

MockProvider是供应用开发者测试LocationManager提供的由App创建的测试Provider，源码位于：

```
services/core/java/com/android/server/location/MockProvider.java
```

继承于LocationProviderInterface，其Location数据由setLocation()方法指定。

```
public class MockProvider implements LocationProviderInterface {

    public MockProvider(String name, ILocationManager locationManager,
            ProviderProperties properties) { ... }

    @Override
    public String getName() { ... }

    @Override
    public ProviderProperties getProperties() { ... }

    @Override
    public void disable() { ... }

    @Override
    public void enable() { ... }

    @Override
    public boolean isEnabled() { ... }

    @Override
    public int getStatus(Bundle extras) { ... }

    @Override
    public long getStatusUpdateTime() { ... }

    public void setLocation(Location l) { ... }

    public void clearLocation() { ... }

    @Override
    public void setRequest(ProviderRequest request, WorkSource source) { }

    @Override
    public boolean sendExtraCommand(String command, Bundle extras) { ... }

    ...
}
```

GnssLocationProvider的源码位于：

```
frameworks/base/services/core/java/com/android/server/location/GnssLocationProvider.java
frameworks/base/services/core/jni/com_android_server_location_GnssLocationProvider.cpp
frameworks/base/location/java/android/location/Location.java
```

分为Java和JNI两部分，主要功能是从GPS HAL中获取数据，转化为Location实例，其结构比较复杂，对GPS设备和数据绝大部分功能进行了完整的实现，对于仅要求虚拟位置数据来说，没有修改GnssLocationProvider的必要。

### Location Manager Service

源码位于：

```
frameworks/base/services/core/java/com/android/server/LocationManagerService.java
```

Service启动时，依次初始化各Provider。

```
systemRunning -> applyAllProviderRequirementsLocked -> applyRequirementsLocked
systemRunning -> updateProvidersLocked -> updateProviderListenersLocked -> applyRequirementsLocked
```

响应binder另一侧客户端发来的请求。

```
requestLocationUpdates -> requestLocationUpdatesLocked -> applyRequirementsLocked
removeUpdates -> removeUpdatesLocked -> applyRequirementsLocked
LocationWorkerHandler.handleMessage -> handleLocationChanged -> handleLocationChangedLocked -> applyRequirementsLocked
```

### Location Manager

源码位于：

```
frameworks/base/location/java/android/location/ILocationManager.aidl
frameworks/base/location/java/android/location/LocationManager.java
```

主要作用是为APP提供访问接口，并交由Location Manager Service对应的方法执行。

```
[Location Manager]
   |
[Binder] <IPC>
   |
[Location Manager Service]
```

binder本身具备传递pid、uid、package name的接口，但是Location Manager传递给Location Manager Service时，其函数参数中并为包含package name，将package name加入参数即可。修改Location Manager Service的函数不会导致Android的碎片化，修改Location Manager会导致过不了CTS，及更大的App兼容性问题。

常见函数转发如下：

```
getProviders -> mService.getProviders

getBestProvider -> mService.getBestProvider

requestSingleUpdate or requestLocationUpdates -> mService.requestLocationUpdates

isProviderEnabled -> mService.isProviderEnabled

getLastLocation -> mService.getLastLocation
```

### APP

#### Get Location Manager
由getSystemService()函数获取Location Manager实例。

```
locationManager = (LocationManager)getSystemService(LOCATION_SERVICE);
```

#### Get Location Provider

应用程序成功获取Location Manager后，利用Location Manager对象，可以获取Location Provider，常见三种获取Location Provider的方式，测试程序包含这三种方式，可覆盖大多数Location Manager常规提供的接口。

类型一，普通青年风格。通过getProvider方法获取全部可用的provider。Android Location Manager返回的Provider实际上是provider的字符串，并非实际的provider对象的引用，在实现虚拟权限，此处额外的增加了处理的难度。

```
List<String> providers = locationManager.getProviders(true);
for (String provider : providers)
{
    ...
}
```

类型二，文艺青年风格。通过Criteria制定对Provider的期望要求，比如是否产生费用，耗电量高低，是否使用网络等需求，由getBestProvider分配最佳的provider。同样，并非实际的provider对象，只是字符串。

```
Criteria criteria = new Criteria();
criteria.setCostAllowed(false);
String provider = locationManager.getBestProvider(criteria, true);
```

类型三，XX青年风格。直接指定某个Provider，能用就用，不计后果。

```
if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
{
    ...
}
```

#### Get Location

应用程序获取Location的方式主要存在两种。

类型一，getLastKnownLocation()方法，可以从指定Provider获取最近一次缓存的Location。适用于一次定位的情形，比如机票，酒店，外卖应用获取一次位置信息。

```
Location location = locationManager.getLastKnownLocation(provider);
```

类型二，通过新建LocationListener实例，重写其onLocationChanged()方法，将LocationListener实例通过requestLocationUpdates提供给指定的Provider。指定的Provider有数据产生时，回调onLocationChanged()方法，使应用程序获取Location数据。适用于要求实时，持续的获取位置信息的应用，比如导航和地图应用。

```
LocationListener locationListener = new LocationListener() {
    @Override
    public void onLocationChanged(Location location) { ... }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) { ... }

    @Override
    public void onProviderEnabled(String provider) { ... }

    @Override
    public void onProviderDisabled(String provider){ ... }
};

locationManager.requestLocationUpdates(provider, 0, 0, locationListener);
```

### 虚拟权限解决方案



1. Composite GPS HAL
使用一个GPS HAL管理多个Linux 设备节点，通过访问/dev/ttyUSBX获取真实设备的NMEA数据，通过虚拟设备节点或者自有线程定时产生虚拟NMEA数据。虚拟NMEA包含的位置和时间信息可通过外部文件控制。在GPSLocation增加额外标记位，用以区分NMEA数据来自真实设备还是虚拟设备。

2. HAL Interface
修改对应的数据结构。

3. Location Provider
参照MockProvider实现一个FakeProvider。
GnssProvider同时获取真实和虚拟的GPSLocation数据，真实数据正常处理，虚拟数据转发给FakeProvider。

4. Location Manager Service
修改Location Manager与Location Manager Service的接口，在方法中增加packageName参数。利用packageName，调用鉴权接口（统一的虚拟权限管理接口），根据其权限，决定使用哪个provider。

对应关系如下：
虚拟设备权限：
```
gps : FakeProvider
network : FakeProvider
passive : FakeProvider
```
真实设备权限
```
gps : GnssProvider
network : NetworkProvider(*)
passive : PassiveProvider
```