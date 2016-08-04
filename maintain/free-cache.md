
频繁的文件访问会导致系统的Cache使用量大增
```
$ free -m
total used free shared buffers cached
Mem: 3955 3926 28 0 55 3459
-/+ buffers/cache: 411 3544
Swap: 5726 0 5726
```
free内存减少到几十兆，系统运行缓慢

运行sync将dirty的内容写回硬盘
```
$sync
```
通过修改proc系统的drop_caches清理free的cache
```
$echo 3 > /proc/sys/vm/drop_caches
```

drop_caches的详细文档如下：
```
Writing to this will cause the kernel to drop clean caches, dentries and inodes from memory, causing that memory to become free.
To free pagecache:
* echo 1 > /proc/sys/vm/drop_caches
To free dentries and inodes:
* echo 2 > /proc/sys/vm/drop_caches
To free pagecache, dentries and inodes:
* echo 3 > /proc/sys/vm/drop_caches
As this is a non-destructive operation, and dirty objects are notfreeable, the user should run "sync" first in order to make sure allcached objects are freed.
This tunable was added in 2.6.16.
```

修改/etc/sysctl.conf 添加如下选项后就不会内存持续增加
```
vm.dirty_ratio = 1
vm.dirty_background_ratio=1
vm.dirty_writeback_centisecs=2
vm.dirty_expire_centisecs=3
vm.drop_caches=3
vm.swappiness =100
vm.vfs_cache_pressure=163
vm.overcommit_memory=2
vm.lowmem_reserve_ratio=32 32 8
kern.maxvnodes=3
```

上面的设置比较粗暴，使cache的作用基本无法发挥。需要根据机器的状况进行适当的调节寻找最佳的折衷。


# From [Linux下清理内存和Cache方法 /proc/sys/vm/drop_caches](http://www.linuxidc.com/Linux/2010-03/24939.htm)


