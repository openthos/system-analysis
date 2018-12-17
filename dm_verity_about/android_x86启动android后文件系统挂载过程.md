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


