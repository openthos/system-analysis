# Openthos加载文件系统的一般路数  
Openthos派生自AOSP,因此同AOSP一样，Openthos的android部分总是从init.rc开始的。  
也同AOSP一样init.rc是一个公式起始。对于Openthos还有一个面向平台的init.android_x86_64.rc。  
具体init.android_x86_64.rc是在init.rc中导入的：  
```bash
  7 import /init.environ.rc
  8 import /init.usb.rc
  9 import /init.${ro.hardware}.rc
 10 import /init.${ro.zygote}.rc
 11 import /init.trace.rc
```
对于Openthos来说${ro.hardware}，即为android_x86_64。这一点定义于device/generic/common/BoardConfig.mk
```Makefile
75 BOARD_EGL_CFG ?= device/generic/common/gpu/egl_mesa.cfg
76 endif
77 
78 :BOARD_KERNEL_CMDLINE := root=/dev/ram0 androidboot.hardware=$(TARGET_PRODUCT)
79 
80 COMPATIBILITY_ENHANCEMENT_PACKAGE := true
81 PRC_COMPATIBILITY_PACKAGE := true
```  
androidboot.hardware项在编译时被强制指定成了$(TARGET_PRODUCT)，对当前的OPENTHOS来说，也即是android_x86_64  
在init.android_x86_64.rc，由device/generic/common/device.mk在编译时由init.x86.rc复制而成。
```Makefile
37　     $(if $(wildcard $(PRODUCT_DIR)fstab.$(TARGET_PRODUCT)),$(PRODUCT_DIR)fstab.$(TARGET_PRODUCT),$(LOCAL_PATH)/fstab.x86):root/fstab.$(TARGET_PRODUCT) \
38　     $(if $(wildcard $(PRODUCT_DIR)wpa_supplicant.conf),$(PRODUCT_DIR),$(LOCAL_PATH)/)wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
39    　 $(if $(wildcard $(PRODUCT_DIR)excluded-input-devices.xml),$(PRODUCT_DIR),$(LOCAL_PATH)/)excluded-input-devices.xml:system/etc/excluded-input-devices.xml \
40　     $(if $(wildcard $(PRODUCT_DIR)init.$(TARGET_PRODUCT).rc),$(PRODUCT_DIR)init.$(TARGET_PRODUCT).rc,$(LOCAL_PATH)/init.x86.rc):root/init.$(TARGET_PRODUCT).rc \
41　     $(if $(wildcard $(PRODUCT_DIR)ueventd.$(TARGET_PRODUCT).rc),$(PRODUCT_DIR)ueventd.$(TARGET_PRODUCT).rc,$(LOCAL_PATH)/ueventd.x86.rc):root/ueventd.$(TARGET_PRODUCT).rc \

```  
init.android_x86_64.rc中，在触发fs事件时，mount_all /fs.${ro.hardware}
```bash
 84 
 85 on fs
 86     mount_all /fstab.${ro.hardware}
 87     setprop ro.crypto.fuse_sdcard true
 88 
```  
mount_all命令将根据fstab.${ro.hardware}亦即fstab.android_x86_64来挂载相关文件系统。  
```bash
  1 none    /cache          tmpfs   nosuid,nodev,noatime    defaults
  2 
  3 auto    /storage/usb0   vfat    defaults        wait,voldmanaged=usb0:auto
  4 auto    /storage/usb1   vfat    defaults        wait,voldmanaged=usb1:auto
  5 auto    /storage/usb2   vfat    defaults        wait,voldmanaged=usb2:auto
  6 auto    /storage/usb3   vfat    defaults        wait,voldmanaged=usb3:auto
```  
# 文件系统加载的细节  
源码system/core/init/keywords.h文件中，指明了mount_all命令由函数do_mount_all实现  
```c
 74     KEYWORD(mkdir,       COMMAND, 1, do_mkdir)
 75     KEYWORD(mount_all,   COMMAND, 1, do_mount_all)
 76     KEYWORD(mount,       COMMAND, 3, do_mount)
```  
函数do_mount_all定义于system/core/init/builtins.c 中  
```c
 682 /*
 683  * This function might request a reboot, in which case it will
 684  * not return.
 685  */
 686 int do_mount_all(int nargs, char **args)
 687 {
 688     pid_t pid;
 689     int ret = -1;
 690     int child_ret = -1;
 691     int status;
 692     const char *prop;
 693     struct fstab *fstab;
 694 
 695     if (nargs != 2) {
 696         return -1;
 697     }
 698 
 699     /*
 700      * Call fs_mgr_mount_all() to mount all filesystems.  We fork(2) and
 701      * do the call in the child to provide protection to the main init
 702      * process if anything goes wrong (crash or memory leak), and wait for
 703      * the child to finish in the parent.
 704      */
 705     pid = fork();
 706     if (pid > 0) {
 707         /* Parent.  Wait for the child to return */
 708         int wp_ret = TEMP_FAILURE_RETRY(waitpid(pid, &status, 0));
 709         if (wp_ret < 0) {
 710             /* Unexpected error code. We will continue anyway. */
 711             NOTICE("waitpid failed rc=%d, errno=%d\n", wp_ret, errno);
 712         }
 713 
 714         if (WIFEXITED(status)) {
 715             ret = WEXITSTATUS(status);
 716         } else {
 717             ret = -1;
 718         }
 719     } else if (pid == 0) {
 720         char *prop_val;
 721         /* child, call fs_mgr_mount_all() */
 722         klog_set_level(6);  /* So we can see what fs_mgr_mount_all() does */
 723         prop_val = expand_references(args[1]);
 724         if (!prop_val) {
 725             ERROR("cannot expand '%s'\n", args[1]);
 726             return -1;
 727         }
 728         fstab = fs_mgr_read_fstab(prop_val);
 729         free(prop_val);
 730         child_ret = fs_mgr_mount_all(fstab);
 731         fs_mgr_free_fstab(fstab);
 732         if (child_ret == -1) {
 733             ERROR("fs_mgr_mount_all returned an error\n");
 734         }
 735         _exit(child_ret);
 736     } else {
 737         /* fork failed, return an error */
 738         return -1;
 739     }
 740 
 741     if (ret == FS_MGR_MNTALL_DEV_NEEDS_ENCRYPTION) {
 742         property_set("vold.decrypt", "trigger_encryption");
 743     } else if (ret == FS_MGR_MNTALL_DEV_MIGHT_BE_ENCRYPTED) {
 744         property_set("ro.crypto.state", "encrypted");
 745         property_set("vold.decrypt", "trigger_default_encryption");
 746     } else if (ret == FS_MGR_MNTALL_DEV_NOT_ENCRYPTED) {
 747         property_set("ro.crypto.state", "unencrypted");
 748         /* If fs_mgr determined this is an unencrypted device, then trigger
 749          * that action.
 750          */
 751         action_for_each_trigger("nonencrypted", action_add_queue_tail);
 752     } else if (ret == FS_MGR_MNTALL_DEV_NEEDS_RECOVERY) {
 753         /* Setup a wipe via recovery, and reboot into recovery */
 754         ERROR("fs_mgr_mount_all suggested recovery, so wiping data via recovery.\n");
 755         ret = wipe_data_via_recovery();
 756         /* If reboot worked, there is no return. */
 757     } else if (ret > 0) {
 758         ERROR("fs_mgr_mount_all returned unexpected error %d\n", ret);
 759     }
 760     /* else ... < 0: error */
 761 
 762     return ret;
 763 }
```  
原始代码如何通过fork（）来做防卸性编程以防止具体的挂载过程崩溃而导致init进程崩溃，我们不作分析。  
args[1]是传入的参数/fstab.android_x86_64,是一个文件，生成的位置在/out/target/product/x86_64/root/fstab.android_x86_64,生成这个文件的源文件位于/device/generci/common/fstab.x86。

在do_mount_all()函数中，比较重要的两个函数如下:  
`fstab = fs_mgr_read_fstab(args[1]);   `  
`child_ret = fs_mgr_mount_all(fstab);  `  
首先我们看下fstab结构体和fstab.mt6797文件，fstab结构提要存储fstab.android_x86文件中的挂载信息，
```c
struct fstab {
    int num_entries;
    struct fstab_rec *recs;
    char *fstab_filename;
};

struct fstab_rec {
    char *blk_device;
    char *mount_point;
    char *fs_type;
    unsigned long flags;
    char *fs_options;
    int fs_mgr_flags;
    char *key_loc;
    char *verity_loc;
    long long length;
    char *label;
    int partnum;
    int swap_prio;
    unsigned int zram_size;
};
```  
system/core/fs_mgr/fs_mgr_fstab.c中定义了fs_mgr_read_fstab():  
```c
180 struct fstab *fs_mgr_read_fstab(const char *fstab_path)
181 {
182     FILE *fstab_file;
183     int cnt, entries;
184     ssize_t len;
185     size_t alloc_len = 0;
186     char *line = NULL;
187     const char *delim = " \t";
188     char *save_ptr, *p;
189     struct fstab *fstab = NULL;
190     struct fs_mgr_flag_values flag_vals;
191 #define FS_OPTIONS_LEN 1024
192     char tmp_fs_options[FS_OPTIONS_LEN];
193 
194     fstab_file = fopen(fstab_path, "r");
195     if (!fstab_file) {
196         ERROR("Cannot open file %s\n", fstab_path);
197         return 0;
198     }
199 
200     entries = 0;
201     while ((len = getline(&line, &alloc_len, fstab_file)) != -1) {
202         /* if the last character is a newline, shorten the string by 1 byte */
203         if (line[len - 1] == '\n') {
204             line[len - 1] = '\0';
205         }
206         /* Skip any leading whitespace */
207         p = line;
208         while (isspace(*p)) {
209             p++;
210         }
211         /* ignore comments or empty lines */
212         if (*p == '#' || *p == '\0')
213             continue;
214         entries++;
215     }
216 
217     if (!entries) {
218         ERROR("No entries found in fstab\n");
219         goto err;
220     }
221 
222     /* Allocate and init the fstab structure */
223     fstab = calloc(1, sizeof(struct fstab));
224     fstab->num_entries = entries;
225     fstab->fstab_filename = strdup(fstab_path);
226     fstab->recs = calloc(fstab->num_entries, sizeof(struct fstab_rec));
227 
228     fseek(fstab_file, 0, SEEK_SET);
229 
230     cnt = 0;
231     while ((len = getline(&line, &alloc_len, fstab_file)) != -1) {
232         /* if the last character is a newline, shorten the string by 1 byte */
233         if (line[len - 1] == '\n') {
234             line[len - 1] = '\0';
235         }
236 
237         /* Skip any leading whitespace */
238         p = line;
239         while (isspace(*p)) {
240             p++;
241         }
242         /* ignore comments or empty lines */
243         if (*p == '#' || *p == '\0')
244             continue;
245 
246         /* If a non-comment entry is greater than the size we allocated, give an
247          * error and quit.  This can happen in the unlikely case the file changes
248          * between the two reads.
249          */
250         if (cnt >= entries) {
251             ERROR("Tried to process more entries than counted\n");
252             break;
253         }
254 
255         if (!(p = strtok_r(line, delim, &save_ptr))) {
256             ERROR("Error parsing mount source\n");
257             goto err;
258         }
259         fstab->recs[cnt].blk_device = strdup(p);
260 
261         if (!(p = strtok_r(NULL, delim, &save_ptr))) {
262             ERROR("Error parsing mount_point\n");
263             goto err;
264         }
265         fstab->recs[cnt].mount_point = strdup(p);
266 
267         if (!(p = strtok_r(NULL, delim, &save_ptr))) {
268             ERROR("Error parsing fs_type\n");
269             goto err;
270         }
271         fstab->recs[cnt].fs_type = strdup(p);
272 
273         if (!(p = strtok_r(NULL, delim, &save_ptr))) {
274             ERROR("Error parsing mount_flags\n");
275             goto err;
276         }
277         tmp_fs_options[0] = '\0';
278         fstab->recs[cnt].flags = parse_flags(p, mount_flags, NULL,
279                                        tmp_fs_options, FS_OPTIONS_LEN);
280 
281         /* fs_options are optional */
282         if (tmp_fs_options[0]) {
283             fstab->recs[cnt].fs_options = strdup(tmp_fs_options);
284         } else {
285             fstab->recs[cnt].fs_options = NULL;
286         }
287 
288         if (!(p = strtok_r(NULL, delim, &save_ptr))) {
289             ERROR("Error parsing fs_mgr_options\n");
290             goto err;
291         }
292         fstab->recs[cnt].fs_mgr_flags = parse_flags(p, fs_mgr_flags,
293                                                     &flag_vals, NULL, 0);
294         fstab->recs[cnt].key_loc = flag_vals.key_loc;
295         fstab->recs[cnt].length = flag_vals.part_length;
296         fstab->recs[cnt].label = flag_vals.label;
297         fstab->recs[cnt].partnum = flag_vals.partnum;
298         fstab->recs[cnt].swap_prio = flag_vals.swap_prio;
299         fstab->recs[cnt].zram_size = flag_vals.zram_size;
300         cnt++;
301     }
302     fclose(fstab_file);
303     free(line);
304     return fstab;
305 
306 err:
307     fclose(fstab_file);
308     free(line);
309     if (fstab)
310         fs_mgr_free_fstab(fstab);
311     return NULL;
312 }
313 
```  
这个过程中要涉及到两个重要的结构体mount_flags和fs_mgr_flags：  
```c
static struct flag_list mount_flags[] = {
    { "noatime",    MS_NOATIME },
    { "noexec",     MS_NOEXEC },
    { "nosuid",     MS_NOSUID },
    { "nodev",      MS_NODEV },
    { "nodiratime", MS_NODIRATIME },
    { "ro",         MS_RDONLY },
    { "rw",         0 },
    { "remount",    MS_REMOUNT },
    { "bind",       MS_BIND },
    { "rec",        MS_REC },
    { "unbindable", MS_UNBINDABLE },
    { "private",    MS_PRIVATE },
    { "slave",      MS_SLAVE },
    { "shared",     MS_SHARED },
    { "defaults",   0 },
    { 0,            0 },
};

static struct flag_list fs_mgr_flags[] = {
    { "wait",        MF_WAIT },
    { "check",       MF_CHECK },
    { "encryptable=",MF_CRYPT },
    { "forceencrypt=",MF_FORCECRYPT },
    { "fileencryption",MF_FILEENCRYPTION },
    { "nonremovable",MF_NONREMOVABLE },
    { "voldmanaged=",MF_VOLDMANAGED},
    { "length=",     MF_LENGTH },
    { "recoveryonly",MF_RECOVERYONLY },
    { "swapprio=",   MF_SWAPPRIO },
    { "zramsize=",   MF_ZRAMSIZE },
    { "verify",      MF_VERIFY },
    { "noemulatedsd", MF_NOEMULATEDSD },
    { "notrim",       MF_NOTRIM },
    { "formattable", MF_FORMATTABLE },
#ifdef MTK_FSTAB_FLAGS
    { "resize",      MF_RESIZE },
#endif
    { "defaults",    0 },
    { 0,             0 },
};
```  
fstab.android_x86_64文件的内容将被fs_mgr_read_fstab()提取到fstab结构体中。  
下一步将通过fs_mgr_mount_all()函数来挂载fstab.android_x86_64中全部列到的文件系统：  
```c
system/core/fs_mgr/fs_mgr.c
341 /* When multiple fstab records share the same mount_point, it will
342  * try to mount each one in turn, and ignore any duplicates after a
343  * first successful mount.
344  * Returns -1 on error, and  FS_MGR_MNTALL_* otherwise.
345  */
346 int fs_mgr_mount_all(struct fstab *fstab)
347 {
348     int i = 0;
349     int encryptable = FS_MGR_MNTALL_DEV_NOT_ENCRYPTED;
350     int error_count = 0;
351     int mret = -1;
352     int mount_errno = 0;
353     int attempted_idx = -1;
354 
355     if (!fstab) {
356         return -1;
357     }
358 
359     for (i = 0; i < fstab->num_entries; i++) {
360         /* Don't mount entries that are managed by vold */
361         if (fstab->recs[i].fs_mgr_flags & (MF_VOLDMANAGED | MF_RECOVERYONLY)) {
362             continue;
363         }
364 
365         /* Skip swap and raw partition entries such as boot, recovery, etc */
366         if (!strcmp(fstab->recs[i].fs_type, "swap") ||
367             !strcmp(fstab->recs[i].fs_type, "emmc") ||
368             !strcmp(fstab->recs[i].fs_type, "mtd")) {
369             continue;
370         }
371 
372         if (fstab->recs[i].fs_mgr_flags & MF_WAIT) {
373             wait_for_file(fstab->recs[i].blk_device, WAIT_TIMEOUT);
374         }
375 
376         if ((fstab->recs[i].fs_mgr_flags & MF_VERIFY) && device_is_secure()) {
377             int rc = fs_mgr_setup_verity(&fstab->recs[i]);
378             if (device_is_debuggable() && rc == FS_MGR_SETUP_VERITY_DISABLED) {
379                 INFO("Verity disabled");
380             } else if (rc != FS_MGR_SETUP_VERITY_SUCCESS) {
381                 ERROR("Could not set up verified partition, skipping!\n");
382                 continue;
383             }
384         }
385         int last_idx_inspected;
386         int top_idx = i;
387 
388         mret = mount_with_alternatives(fstab, i, &last_idx_inspected, &attempted_idx);
389         i = last_idx_inspected;
390         mount_errno = errno;
391 
392         /* Deal with encryptability. */
393         if (!mret) {
394             /* If this is encryptable, need to trigger encryption */
395             if (   (fstab->recs[attempted_idx].fs_mgr_flags & MF_FORCECRYPT)
396                 || (device_is_force_encrypted()
397                     && fs_mgr_is_encryptable(&fstab->recs[attempted_idx]))) {
398                 if (umount(fstab->recs[attempted_idx].mount_point) == 0) {
399                     if (encryptable == FS_MGR_MNTALL_DEV_NOT_ENCRYPTED) {
400                         ERROR("Will try to encrypt %s %s\n", fstab->recs[attempted_idx].mount_poi    nt,
401                               fstab->recs[attempted_idx].fs_type);
402                         encryptable = FS_MGR_MNTALL_DEV_NEEDS_ENCRYPTION;
403                     } else {
404                         ERROR("Only one encryptable/encrypted partition supported\n");
405                         encryptable = FS_MGR_MNTALL_DEV_MIGHT_BE_ENCRYPTED;
406                     }
407                 } else {
408                     INFO("Could not umount %s - allow continue unencrypted\n",
409                          fstab->recs[attempted_idx].mount_point);
410                     continue;
411                 }
412             }
413             /* Success!  Go get the next one */
414             continue;
415         }
416 
417         /* mount(2) returned an error, handle the encryptable/formattable case */
418         bool wiped = partition_wiped(fstab->recs[top_idx].blk_device);
419         if (mret && mount_errno != EBUSY && mount_errno != EACCES &&
420             fs_mgr_is_formattable(&fstab->recs[top_idx]) && wiped) {
421             /* top_idx and attempted_idx point at the same partition, but sometimes
422              * at two different lines in the fstab.  Use the top one for formatting
423              * as that is the preferred one.
424              */
425             ERROR("%s(): %s is wiped and %s %s is formattable. Format it.\n", __func__,
426                   fstab->recs[top_idx].blk_device, fstab->recs[top_idx].mount_point,
427                   fstab->recs[top_idx].fs_type);
428             if (fs_mgr_is_encryptable(&fstab->recs[top_idx]) &&
429                 strcmp(fstab->recs[top_idx].key_loc, KEY_IN_FOOTER)) {
430                 int fd = open(fstab->recs[top_idx].key_loc, O_WRONLY, 0644);
431                 if (fd >= 0) {
432                     INFO("%s(): also wipe %s\n", __func__, fstab->recs[top_idx].key_loc);
433                     wipe_block_device(fd, get_file_size(fd));
434                     close(fd);
435                 } else {
436                     ERROR("%s(): %s wouldn't open (%s)\n", __func__,
437                           fstab->recs[top_idx].key_loc, strerror(errno));
438                 }
439             }
440             if (fs_mgr_do_format(&fstab->recs[top_idx]) == 0) {
441                 /* Let's replay the mount actions. */
442                 i = top_idx - 1;
443                 continue;
444             }
445         }
446         if (mret && mount_errno != EBUSY && mount_errno != EACCES &&
447             fs_mgr_is_encryptable(&fstab->recs[attempted_idx])) {
448             if (wiped) {
449                 ERROR("%s(): %s is wiped and %s %s is encryptable. Suggest recovery...\n", __func    __,
450                       fstab->recs[attempted_idx].blk_device, fstab->recs[attempted_idx].mount_poi    nt,
451                       fstab->recs[attempted_idx].fs_type);
452                 encryptable = FS_MGR_MNTALL_DEV_NEEDS_RECOVERY;
453                 continue;
454             } else {
455                 /* Need to mount a tmpfs at this mountpoint for now, and set
456                  * properties that vold will query later for decrypting
457                  */
458                 ERROR("%s(): possibly an encryptable blkdev %s for mount %s type %s )\n", __func_    _,
459                       fstab->recs[attempted_idx].blk_device, fstab->recs[attempted_idx].mount_poi    nt,
460                       fstab->recs[attempted_idx].fs_type);
461                 if (fs_mgr_do_tmpfs_mount(fstab->recs[attempted_idx].mount_point) < 0) {
462                     ++error_count;
463                     continue;
464                 }
465             }
466             encryptable = FS_MGR_MNTALL_DEV_MIGHT_BE_ENCRYPTED;
467         } else {
468             ERROR("Failed to mount an un-encryptable or wiped partition on"
469                    "%s at %s options: %s error: %s\n",
470                    fstab->recs[attempted_idx].blk_device, fstab->recs[attempted_idx].mount_point,
471                    fstab->recs[attempted_idx].fs_options, strerror(mount_errno));
472             ++error_count;
473             continue;
474         }
475     }
476 
477     if (error_count) {
478         return -1;
479     } else {
480         return encryptable;
481     }
482 }
```  
