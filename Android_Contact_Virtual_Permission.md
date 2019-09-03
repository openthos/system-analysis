# Android 联系人虚拟权限分析与设计

本文

## 应用程序访问联系人行为分析

1. 获取ContentResolver对象
```
contentResolver = getContentResolver();
```
2. 构造Uri对象
```
uri = Uri.parse("content://com.android.contacts/contacts");
```
3. 通过ContentResolver对象对联系人进行操作
```
cursor = contentResolver.query(uri, null, null, null, null);
StringBuilder sb = new StringBuilder();
while(cursor.moveToNext())
{
    sb.append(cursor.getString(cursor.getColumnIndex(android.provider.ContactsContract.Contacts._ID)));
    sb.append("\n");
    sb.append(cursor.getString(cursor.getColumnIndex(android.provider.ContactsContract.Contacts.DISPLAY_NAME)));
    sb.append("\n");
}
textView.setText(sb.toString());
```

## Android Framework处理流程



### ContentResolver的初始化

应用程序通过getContentResolver方法获取ContentResolver对象，利用ContentResolver进行对数据的相关操作。实际上是调用了ContextImpl类中的getContentResolver()方法，该方法的实现是返回mContentResolver变量。源码位于：
```
frameworks/base/core/java/android/app/ContextImpl.java
```
```
    @Override
    public ContentResolver getContentResolver() {
        return mContentResolver;
    }

```

mContentResolver变量在ContextImpl的构造方法中初始化，其类型是ApplicationContentResolver类。
```
    private ContextImpl(@Nullable ContextImpl container, @NonNull ActivityThread mainThread,
            @NonNull LoadedApk packageInfo, @Nullable String splitName,
            @Nullable IBinder activityToken, @Nullable UserHandle user, int flags,
            @Nullable ClassLoader classLoader) {
        mOuterContext = this;

        // If creator didn't specify which storage to use, use the default
        // location for application.
        if ((flags & (Context.CONTEXT_CREDENTIAL_PROTECTED_STORAGE
                | Context.CONTEXT_DEVICE_PROTECTED_STORAGE)) == 0) {
            final File dataDir = packageInfo.getDataDirFile();
            if (Objects.equals(dataDir, packageInfo.getCredentialProtectedDataDirFile())) {
                flags |= Context.CONTEXT_CREDENTIAL_PROTECTED_STORAGE;
            } else if (Objects.equals(dataDir, packageInfo.getDeviceProtectedDataDirFile())) {
                flags |= Context.CONTEXT_DEVICE_PROTECTED_STORAGE;
            }
        }

        mMainThread = mainThread;
        mActivityToken = activityToken;
        mFlags = flags;

        if (user == null) {
            user = Process.myUserHandle();
        }
        mUser = user;

        mPackageInfo = packageInfo;
        mSplitName = splitName;
        mClassLoader = classLoader;
        mResourcesManager = ResourcesManager.getInstance();

        if (container != null) {
            mBasePackageName = container.mBasePackageName;
            mOpPackageName = container.mOpPackageName;
            setResources(container.mResources);
            mDisplay = container.mDisplay;
        } else {
            mBasePackageName = packageInfo.mPackageName;
            ApplicationInfo ainfo = packageInfo.getApplicationInfo();
            if (ainfo.uid == Process.SYSTEM_UID && ainfo.uid != Process.myUid()) {
                // Special case: system components allow themselves to be loaded in to other
                // processes.  For purposes of app ops, we must then consider the context as
                // belonging to the package of this process, not the system itself, otherwise
                // the package+uid verifications in app ops will fail.
                mOpPackageName = ActivityThread.currentPackageName();
            } else {
                mOpPackageName = mBasePackageName;
            }
        }

        mContentResolver = new ApplicationContentResolver(this, mainThread, user);
    }
```

ApplicationContentResolver是ContextImpl内部定义的一个类，继承自ContentResolver。其定义了对ContentProvider的相关操作。

```
    private static final class ApplicationContentResolver extends ContentResolver {
        private final ActivityThread mMainThread;
        private final UserHandle mUser;

        public ApplicationContentResolver(
                Context context, ActivityThread mainThread, UserHandle user) {...}
        protected IContentProvider acquireProvider(Context context, String auth) {...}
        protected IContentProvider acquireExistingProvider(Context context, String auth) {...}
        public boolean releaseProvider(IContentProvider provider) {...}
        protected IContentProvider acquireUnstableProvider(Context c, String auth) {...}
        public boolean releaseUnstableProvider(IContentProvider icp) {...}
        public void unstableProviderDied(IContentProvider icp) {...}
        protected int resolveUserIdFromAuthority(String auth) {...}
    }
```

AMS中ContentProvider权限检查的关键代码，位于：
```
frameworks/base/services/core/java/com/android/server/am/ActivityManagerService.java
```

```
    /**
     * Check if {@link ProcessRecord} has a possible chance at accessing the
     * given {@link ProviderInfo}. Final permission checking is always done
     * in {@link ContentProvider}.
     */
    private final String checkContentProviderPermissionLocked(
            ProviderInfo cpi, ProcessRecord r, int userId, boolean checkUser) {
        final int callingPid = (r != null) ? r.pid : Binder.getCallingPid();
        final int callingUid = (r != null) ? r.uid : Binder.getCallingUid();
        boolean checkedGrants = false;
        if (checkUser) {
            // Looking for cross-user grants before enforcing the typical cross-users permissions
            int tmpTargetUserId = mUserController.unsafeConvertIncomingUserLocked(userId);
            if (tmpTargetUserId != UserHandle.getUserId(callingUid)) {
                if (checkAuthorityGrants(callingUid, cpi, tmpTargetUserId, checkUser)) {
                    return null;
                }
                checkedGrants = true;
            }
            userId = mUserController.handleIncomingUser(callingPid, callingUid, userId, false,
                    ALLOW_NON_FULL, "checkContentProviderPermissionLocked " + cpi.authority, null);
            if (userId != tmpTargetUserId) {
                // When we actually went to determine the final targer user ID, this ended
                // up different than our initial check for the authority.  This is because
                // they had asked for USER_CURRENT_OR_SELF and we ended up switching to
                // SELF.  So we need to re-check the grants again.
                checkedGrants = false;
            }
        }
        if (checkComponentPermission(cpi.readPermission, callingPid, callingUid,
                cpi.applicationInfo.uid, cpi.exported)
                == PackageManager.PERMISSION_GRANTED) {
            return null;
        }
        if (checkComponentPermission(cpi.writePermission, callingPid, callingUid,
                cpi.applicationInfo.uid, cpi.exported)
                == PackageManager.PERMISSION_GRANTED) {
            return null;
        }

        PathPermission[] pps = cpi.pathPermissions;
        if (pps != null) {
            int i = pps.length;
            while (i > 0) {
                i--;
                PathPermission pp = pps[i];
                String pprperm = pp.getReadPermission();
                if (pprperm != null && checkComponentPermission(pprperm, callingPid, callingUid,
                        cpi.applicationInfo.uid, cpi.exported)
                        == PackageManager.PERMISSION_GRANTED) {
                    return null;
                }
                String ppwperm = pp.getWritePermission();
                if (ppwperm != null && checkComponentPermission(ppwperm, callingPid, callingUid,
                        cpi.applicationInfo.uid, cpi.exported)
                        == PackageManager.PERMISSION_GRANTED) {
                    return null;
                }
            }
        }
        if (!checkedGrants && checkAuthorityGrants(callingUid, cpi, userId, checkUser)) {
            return null;
        }

        final String suffix;
        if (!cpi.exported) {
            suffix = " that is not exported from UID " + cpi.applicationInfo.uid;
        } else if (android.Manifest.permission.MANAGE_DOCUMENTS.equals(cpi.readPermission)) {
            suffix = " requires that you obtain access using ACTION_OPEN_DOCUMENT or related APIs";
        } else {
            suffix = " requires " + cpi.readPermission + " or " + cpi.writePermission;
        }
        final String msg = "Permission Denial: opening provider " + cpi.name
                + " from " + (r != null ? r : "(null)") + " (pid=" + callingPid
                + ", uid=" + callingUid + ")" + suffix;
        Slog.w(TAG, msg);
        return msg;
    }
```

## 联系人所需权限
* READ_CONTACTS

在 AndroidManifest.xml 中指定，使用\<uses-permission\>元素作为\<uses-permission android:name="android.permission.READ_CONTACTS"\>，声明在对一个或多个表的读取权限。
* WRITE_CONTACTS

在 AndroidManifest.xml 中指定，使用\<uses-permission\>元素作为\<uses-permission android:name="android.permission.WRITE_CONTACTS"\>，声明对对一个或多个表的写入权限。

## 研究方法

在packages/apps/ContactsDemo中创建测试项目。源码如下
```
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ContentResolver contentResolver = null;
        TextView textView = null;
        Uri uri = null;
        Cursor cursor = null;

        textView = (TextView)findViewById(R.id.textView);
        contentResolver = getContentResolver();
        uri = Uri.parse("content://com.android.contacts/contacts");

        cursor = contentResolver.query(uri, null, null, null, null);

        StringBuilder sb = new StringBuilder();
        while(cursor.moveToNext())
        {
            sb.append(cursor.getString(cursor.getColumnIndex(android.provider.ContactsContract.Contacts._ID)));
            sb.append("\n");
            sb.append(cursor.getString(cursor.getColumnIndex(android.provider.ContactsContract.Contacts.DISPLAY_NAME)));
            sb.append("\n");
        }

        textView.setText(sb.toString());

    }
}
```
通过
```
mmm packages/apps/ContactsDemo
```
进行编译。

将Android Fremawork代码导入至Android Studio，在getContentResolver()处和 cursor = contentResolver.query(uri, null, null, null, null)处设置断点。

分别在授予Runtime读写联系人权限和撤销Runtime读写联系人权限的情况下，跟踪程序的运行路径。对不同运行路径进行对比分析。

位于AMS的代码，可将Debugger Attach到system_process进程进行调试。命中断点后，对堆栈和变量进行分析。

## 有待解决的关键问题

### 找到适合注入虚拟权限鉴权代码的位置

目前的分析结果可见，由于Android实现了Runtime权限鉴权，所以具备联系人虚拟权限鉴权的可行性。获取ContentProvider的是通过AMS进行，AMS位于Binder的服务器端，可以获取客户端的Uid、Pid等信息。在AMS中调用PMS的鉴权接口，即可实现。
目前还需找到适合注入虚拟权限鉴权代码的位置。

### Uri伪造与识别

应用程序通过contentResolver.query方法对指定的ContentProvider进行查询，其重要的参数是Uri对象，Uri在Andriod中分为三个部分scheme、authority和path。其中authority又分为host和port。ContentResolver根据Uri选定合适的ContentProvider，每个scheme对应唯一的ContentProvider。当同时存在真实联系人的ContentProvider和虚拟联系人的ContentProvider时，一个scheme就要对应两个不同的ContentProvider。

### 虚拟联系人数据的实现

