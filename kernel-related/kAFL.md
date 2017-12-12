# [kAFL](https://github.com/RUB-SysSec/kAFL.git)
## 下载并安装依赖
```
git clone https://github.com/RUB-SysSec/kAFL.git
cd kAFL
sudo bash ./install.sh
cd kAFL-Fuzzer/agents
bash ./compile.sh
```
将会下载QEMU和Linux-4.6.2，打完patch，编译安装到本机，请确保安装过程无错误。
例如生成qemu-2.9.0/x86_64-softmmu/qemu-system-x86_64，并把该QEMU路径配置到kAFL/kAFL-Fuzzer/kafl.ini的qemu-kafl_location。

kAFL支持的host CPU类型有：
```
Intel(R) Core(TM) i5-6500
Intel(R) Core(TM) i7-6700HQ 
...
```
## 配置guest虚拟机
- 手动创建一个qcow2的QEMU虚拟机系统镜像linux.qcow2，例如安装Ubuntu16.04
- 创建QEMU虚拟机的Overlay
```
mkdir snapshot && cd snapshot
qemu-img create -b /absolute/path/to/hdd/linux.qcow2 -f qcow2 overlay_0.qcow2
qemu-img create -f qcow2 ram.qcow2 3000
```
- 进入虚拟机系统
`qemu-2.9.0/x86_64-softmmu/qemu-system-x86_64 -hdb /path/to/snapshot/ram.qcow2 -hda /path/to/snapshot/overlay_0.qcow2 -machine pc-i440fx-2.6 -serial mon:stdio -enable-kvm -m 3000`

- 编译kAFL loader agent
```
git clone https://github.com/RUB-SysSec/kAFL.git
cd kAFL/kAFL-Fuzzer/agents
bash ./compile.sh
```
- （可选）载入测试用例漏洞驱动
```
cd kAFl/kAFL-Fuzzer/vuln_drivers/simple/linux_x86-64/
sudo bash ./load.sh
```
- 创建可用于Fuzzing的快照
```
cd kAFL/kAFL-Fuzzer/agents/linux_x86_64/loader/
sudo ./loader
```
此时虚拟机系统将暂停，切换至QEMU monitor命令行，创建名为kafl的快照
```
# press CTRL-a + c
savevm kafl
q 
```
## 配置kAFL组件
1. 编辑kAFL/kAFL-Fuzzer/kafl.ini，配置qemu-kafl_location为编译生成的qemu-system-x86_64位置。
2. 编译agents，执行kAFL-Fuzzer/agents/compile.sh
3. 取回已载入驱动的地址范围，用于fuzzing时的-ip0参数
```
cd /path/to/kAFL/kAFL-Fuzzer
python kafl_info.py /path/to/snapshot/ram.qcow2 /path/to/snapshot/ agents/linux_x86_64/info/info 3000 -v
```

## 开始Fuzzing
```
python kafl_fuzz.py /path/to/snapshot/ram.qcow2 /path/to/snapshot agents/linux_x86_64/fuzzer/kafl_vuln_test 3000 /path/to/input/directory /path/to/working/directory -ip0 0xffffffffc0287000-0xffffffffc028b000 -v --Purge
```
## Paper
https://www.usenix.org/conference/usenixsecurity17/technical-sessions/presentation/schumilo
