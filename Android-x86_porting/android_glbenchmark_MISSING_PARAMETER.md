# Android GLBenchmark 由于MISSING_PARAMETER问题导致网络连接失败问题分析

## 问题概述

根据刘晓旭工程师提供的app分析报告：

1. 反汇编com.glbenchmark.glbenchmark.apk, 出现错误提示“Uploading device information:MISSING_PARAMETER”代码调用流程：
检查UploadDeviceInfoTask.java：status.good()，
Status.java：good()具体实现{netmanlibJNI.Status_good(this.swigCPtr(1), this)}，this.swigCPtr (1)默认是Flag.DEVICEINFO_FAILED，然后通过下面赋值：
this.swigCPtr(1) = Services.java：netmanlibJNI.Services_getDeviceInfo(this.swigCPtr(2), this, deviceInfo, recievedInfo)；
this.swigCPtr(2) = Services.java：netmanlibJNI.Services_instance() ；
2. 如果status.good()返回false，则界面会提示“Uploading device information:”+ status.toString();
Status.java：status.toString()表示不同的出错状态其中包括“MISSING_PARAMETER”。
status.toString()具体实现{netmanlibJNI.Status_toString(this.swigCPtr(1), this)}。
3. status的赋值
UploadDeviceInfoTask.java：Status status = services.getDeviceInfo(props.toJsonString(), recievedInfo);
props赋值，MinimalProps.java：props.collect(new AndroidDeviceInfoCollector(context), this.sysinf), 
collect具体实现Properties.java：systeminfolibJNI.Properties_collect(this.swigCPtr, this, DeviceInfoCollector.getCPtr(deviceInfoCollector), deviceInfoCollector, SystemInfo.getCPtr(systeminfo), systeminfo)
AndroidDeviceInfoCollector.java中收集device info，包括OsInfo、DisplayInfo、CpuInfo、GpuInfo、MultiGpuInfo、MemoryInfo、StorageInfo、BatteryInfo等信息，应用获取CpuInfo，StorageInfo方式，
我通过demo测试，在运行不正常的设备S1上，同样可以获取到CpuInfo，StorageInfo的信息。

## 分析步骤

获取getDeviceInfo函数所在的so：
```
unzip com.glbenchmark.glbenchmark.apk
objdump -T lib/x86_64/*.so | grep getDeviceInfo
```
确认函数源码位于libnetman_jni.so。

使用objdump -d进行反汇编，getDeviceInfo位于50570-50a6d。函数反汇编结果如下：
```
0000000000050570 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo>:
   50570:	41 57                	push   %r15
   50572:	48 8d 35 3d b6 1a 00 	lea    0x1ab63d(%rip),%rsi        # 1fbbb6 <_ZNSt12_Destroy_auxILb0EE9__destroyIPN4Poco16PatternFormatter13PatternActionEEEvT_S6_+0x3dc66>
   50579:	41 56                	push   %r14
   5057b:	41 55                	push   %r13
   5057d:	41 54                	push   %r12
   5057f:	4d 89 c4             	mov    %r8,%r12
   50582:	55                   	push   %rbp
   50583:	53                   	push   %rbx
   50584:	48 89 fb             	mov    %rdi,%rbx
   50587:	48 8d a4 24 68 ff ff 	lea    -0x98(%rsp),%rsp
   5058e:	ff 
   5058f:	48 8b 2d 0a 3b 29 00 	mov    0x293b0a(%rip),%rbp        # 2e40a0 <_ZTISs+0x1290>
   50596:	4c 8d 7c 24 60       	lea    0x60(%rsp),%r15
   5059b:	48 89 54 24 18       	mov    %rdx,0x18(%rsp)
   505a0:	4c 8d 6c 24 50       	lea    0x50(%rsp),%r13
   505a5:	4c 89 fa             	mov    %r15,%rdx
   505a8:	4c 89 ef             	mov    %r13,%rdi
   505ab:	4c 89 4c 24 08       	mov    %r9,0x8(%rsp)
   505b0:	48 8d 45 18          	lea    0x18(%rbp),%rax
   505b4:	48 89 44 24 40       	mov    %rax,0x40(%rsp)
   505b9:	e8 92 61 ff ff       	callq  46750 <_ZNSsC1EPKcRKSaIcE@plt>
   505be:	48 8d 44 24 70       	lea    0x70(%rsp),%rax
   505c3:	4c 89 ea             	mov    %r13,%rdx
   505c6:	31 f6                	xor    %esi,%esi
   505c8:	48 89 c7             	mov    %rax,%rdi
   505cb:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
   505d0:	e8 8b 7f 00 00       	callq  58560 <_ZN6netman6StatusC1EiRKSs>
   505d5:	48 8b 44 24 50       	mov    0x50(%rsp),%rax
   505da:	48 8d 78 e8          	lea    -0x18(%rax),%rdi
   505de:	48 39 ef             	cmp    %rbp,%rdi
   505e1:	0f 85 f1 02 00 00    	jne    508d8 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x368>
   505e7:	4d 85 e4             	test   %r12,%r12
   505ea:	0f 84 20 02 00 00    	je     50810 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x2a0>
   505f0:	48 8b 03             	mov    (%rbx),%rax
   505f3:	31 d2                	xor    %edx,%edx
   505f5:	4c 89 e6             	mov    %r12,%rsi
   505f8:	48 89 df             	mov    %rbx,%rdi
   505fb:	ff 90 48 05 00 00    	callq  *0x548(%rax)
   50601:	48 85 c0             	test   %rax,%rax
   50604:	49 89 c6             	mov    %rax,%r14
   50607:	0f 84 57 02 00 00    	je     50864 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x2f4>
   5060d:	48 8d 84 24 80 00 00 	lea    0x80(%rsp),%rax
   50614:	00 
   50615:	4c 89 f6             	mov    %r14,%rsi
   50618:	4c 89 ff             	mov    %r15,%rdi
   5061b:	48 89 c2             	mov    %rax,%rdx
   5061e:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
   50623:	e8 28 61 ff ff       	callq  46750 <_ZNSsC1EPKcRKSaIcE@plt>
   50628:	48 8b 03             	mov    (%rbx),%rax
   5062b:	4c 89 f2             	mov    %r14,%rdx
   5062e:	4c 89 e6             	mov    %r12,%rsi
   50631:	48 89 df             	mov    %rbx,%rdi
   50634:	ff 90 50 05 00 00    	callq  *0x550(%rax)
   5063a:	48 83 7c 24 08 00    	cmpq   $0x0,0x8(%rsp)
   50640:	0f 84 ba 02 00 00    	je     50900 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x390>
   50646:	48 8b 03             	mov    (%rbx),%rax
   50649:	48 89 df             	mov    %rbx,%rdi
   5064c:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
   50651:	ff 90 58 05 00 00    	callq  *0x558(%rax)
   50657:	85 c0                	test   %eax,%eax
   50659:	0f 84 11 01 00 00    	je     50770 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x200>
   5065f:	48 8b 03             	mov    (%rbx),%rax
   50662:	31 d2                	xor    %edx,%edx
   50664:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
   50669:	48 89 df             	mov    %rbx,%rdi
   5066c:	ff 90 68 05 00 00    	callq  *0x568(%rax)
   50672:	48 85 c0             	test   %rax,%rax
   50675:	49 89 c4             	mov    %rax,%r12
   50678:	0f 84 12 03 00 00    	je     50990 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x420>
   5067e:	48 8b 03             	mov    (%rbx),%rax
   50681:	31 d2                	xor    %edx,%edx
   50683:	4c 89 e6             	mov    %r12,%rsi
   50686:	48 89 df             	mov    %rbx,%rdi
   50689:	ff 90 48 05 00 00    	callq  *0x548(%rax)
   5068f:	48 85 c0             	test   %rax,%rax
   50692:	49 89 c6             	mov    %rax,%r14
   50695:	0f 84 25 01 00 00    	je     507c0 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x250>
   5069b:	48 89 c7             	mov    %rax,%rdi
   5069e:	e8 5d 61 ff ff       	callq  46800 <strlen@plt>
   506a3:	48 8d 4c 24 40       	lea    0x40(%rsp),%rcx
   506a8:	48 89 c2             	mov    %rax,%rdx
   506ab:	4c 89 f6             	mov    %r14,%rsi
   506ae:	48 89 cf             	mov    %rcx,%rdi
   506b1:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
   506b6:	e8 55 61 ff ff       	callq  46810 <_ZNSs6assignEPKcm@plt>
   506bb:	48 8b 03             	mov    (%rbx),%rax
   506be:	4c 89 f2             	mov    %r14,%rdx
   506c1:	4c 89 e6             	mov    %r12,%rsi
   506c4:	48 89 df             	mov    %rbx,%rdi
   506c7:	ff 90 50 05 00 00    	callq  *0x550(%rax)
   506cd:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   506d2:	48 8b 74 24 18       	mov    0x18(%rsp),%rsi
   506d7:	4c 89 fa             	mov    %r15,%rdx
   506da:	48 8b 7c 24 20       	mov    0x20(%rsp),%rdi
   506df:	e8 fc 23 00 00       	callq  52ae0 <_ZN6netman8Services13getDeviceInfoERKSsRSs>
   506e4:	8b 84 24 80 00 00 00 	mov    0x80(%rsp),%eax
   506eb:	89 44 24 70          	mov    %eax,0x70(%rsp)
   506ef:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   506f4:	48 8d 70 08          	lea    0x8(%rax),%rsi
   506f8:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
   506fd:	48 8d 78 08          	lea    0x8(%rax),%rdi
   50701:	e8 ea 60 ff ff       	callq  467f0 <_ZNSs4swapERSs@plt>
   50706:	48 8b 84 24 88 00 00 	mov    0x88(%rsp),%rax
   5070d:	00 
   5070e:	48 8d 78 e8          	lea    -0x18(%rax),%rdi
   50712:	48 39 ef             	cmp    %rbp,%rdi
   50715:	0f 85 87 02 00 00    	jne    509a2 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x432>
   5071b:	bf 10 00 00 00       	mov    $0x10,%edi
   50720:	e8 db 5f ff ff       	callq  46700 <_Znwm@plt>
   50725:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
   5072a:	49 89 c4             	mov    %rax,%r12
   5072d:	8b 44 24 70          	mov    0x70(%rsp),%eax
   50731:	49 8d 7c 24 08       	lea    0x8(%r12),%rdi
   50736:	48 83 c6 08          	add    $0x8,%rsi
   5073a:	41 89 04 24          	mov    %eax,(%r12)
   5073e:	e8 1d 60 ff ff       	callq  46760 <_ZNSsC1ERKSs@plt>
   50743:	48 8b 03             	mov    (%rbx),%rax
   50746:	48 89 df             	mov    %rbx,%rdi
   50749:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
   5074e:	ff 90 38 05 00 00    	callq  *0x538(%rax)
   50754:	4c 8b 03             	mov    (%rbx),%r8
   50757:	48 89 c1             	mov    %rax,%rcx
   5075a:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
   5075f:	31 d2                	xor    %edx,%edx
   50761:	48 89 df             	mov    %rbx,%rdi
   50764:	41 ff 90 70 05 00 00 	callq  *0x570(%r8)
   5076b:	4c 89 e0             	mov    %r12,%rax
   5076e:	eb 52                	jmp    507c2 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x252>
   50770:	4c 8d 25 c9 4f 27 00 	lea    0x274fc9(%rip),%r12        # 2c5740 <_ZTSSs+0x4e77d>
   50777:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   5077e:	00 00 
   50780:	49 83 c4 10          	add    $0x10,%r12
   50784:	41 f7 04 24 fb ff ff 	testl  $0xfffffffb,(%r12)
   5078b:	ff 
   5078c:	75 f2                	jne    50780 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x210>
   5078e:	48 8b 03             	mov    (%rbx),%rax
   50791:	48 89 df             	mov    %rbx,%rdi
   50794:	ff 90 88 00 00 00    	callq  *0x88(%rax)
   5079a:	48 8b 03             	mov    (%rbx),%rax
   5079d:	48 89 df             	mov    %rbx,%rdi
   507a0:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
   507a5:	ff 50 30             	callq  *0x30(%rax)
   507a8:	48 85 c0             	test   %rax,%rax
   507ab:	74 13                	je     507c0 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x250>
   507ad:	48 8b 0b             	mov    (%rbx),%rcx
   507b0:	48 8d 15 41 0c 1c 00 	lea    0x1c0c41(%rip),%rdx        # 2113f8 <_ZNSt12_Destroy_auxILb0EE9__destroyIPN4Poco16PatternFormatter13PatternActionEEEvT_S6_+0x534a8>
   507b7:	48 89 c6             	mov    %rax,%rsi
   507ba:	48 89 df             	mov    %rbx,%rdi
   507bd:	ff 51 70             	callq  *0x70(%rcx)
   507c0:	31 c0                	xor    %eax,%eax
   507c2:	48 8b 54 24 60       	mov    0x60(%rsp),%rdx
   507c7:	48 8d 7a e8          	lea    -0x18(%rdx),%rdi
   507cb:	48 39 ef             	cmp    %rbp,%rdi
   507ce:	0f 85 8c 01 00 00    	jne    50960 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x3f0>
   507d4:	48 8b 54 24 78       	mov    0x78(%rsp),%rdx
   507d9:	48 8d 7a e8          	lea    -0x18(%rdx),%rdi
   507dd:	48 39 ef             	cmp    %rbp,%rdi
   507e0:	0f 85 92 00 00 00    	jne    50878 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x308>
   507e6:	48 8b 54 24 40       	mov    0x40(%rsp),%rdx
   507eb:	48 8d 7a e8          	lea    -0x18(%rdx),%rdi
   507ef:	48 39 ef             	cmp    %rbp,%rdi
   507f2:	0f 85 b0 00 00 00    	jne    508a8 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x338>
   507f8:	48 8d a4 24 98 00 00 	lea    0x98(%rsp),%rsp
   507ff:	00 
   50800:	5b                   	pop    %rbx
   50801:	5d                   	pop    %rbp
   50802:	41 5c                	pop    %r12
   50804:	41 5d                	pop    %r13
   50806:	41 5e                	pop    %r14
   50808:	41 5f                	pop    %r15
   5080a:	c3                   	retq   
   5080b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   50810:	4c 8d 25 29 4f 27 00 	lea    0x274f29(%rip),%r12        # 2c5740 <_ZTSSs+0x4e77d>
   50817:	eb 0b                	jmp    50824 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x2b4>
   50819:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   50820:	85 c0                	test   %eax,%eax
   50822:	74 0e                	je     50832 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x2c2>
   50824:	41 8b 44 24 10       	mov    0x10(%r12),%eax
   50829:	49 83 c4 10          	add    $0x10,%r12
   5082d:	83 f8 07             	cmp    $0x7,%eax
   50830:	75 ee                	jne    50820 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x2b0>
   50832:	48 8b 03             	mov    (%rbx),%rax
   50835:	48 89 df             	mov    %rbx,%rdi
   50838:	ff 90 88 00 00 00    	callq  *0x88(%rax)
   5083e:	48 8b 03             	mov    (%rbx),%rax
   50841:	48 89 df             	mov    %rbx,%rdi
   50844:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
   50849:	ff 50 30             	callq  *0x30(%rax)
   5084c:	48 85 c0             	test   %rax,%rax
   5084f:	74 13                	je     50864 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x2f4>
   50851:	48 8b 0b             	mov    (%rbx),%rcx
   50854:	48 8d 15 35 b3 1a 00 	lea    0x1ab335(%rip),%rdx        # 1fbb90 <_ZNSt12_Destroy_auxILb0EE9__destroyIPN4Poco16PatternFormatter13PatternActionEEEvT_S6_+0x3dc40>
   5085b:	48 89 c6             	mov    %rax,%rsi
   5085e:	48 89 df             	mov    %rbx,%rdi
   50861:	ff 51 70             	callq  *0x70(%rcx)
   50864:	48 8b 54 24 78       	mov    0x78(%rsp),%rdx
   50869:	31 c0                	xor    %eax,%eax
   5086b:	48 8d 7a e8          	lea    -0x18(%rdx),%rdi
   5086f:	48 39 ef             	cmp    %rbp,%rdi
   50872:	0f 84 6e ff ff ff    	je     507e6 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x276>
   50878:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
   5087d:	f0 0f c1 4a f8       	lock xadd %ecx,-0x8(%rdx)
   50882:	85 c9                	test   %ecx,%ecx
   50884:	0f 8f 5c ff ff ff    	jg     507e6 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x276>
   5088a:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
   5088f:	48 8d b4 24 80 00 00 	lea    0x80(%rsp),%rsi
   50896:	00 
   50897:	e8 54 5e ff ff       	callq  466f0 <_ZNSs4_Rep10_M_destroyERKSaIcE@plt>
   5089c:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   508a1:	e9 40 ff ff ff       	jmpq   507e6 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x276>
   508a6:	66 90                	xchg   %ax,%ax
   508a8:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
   508ad:	f0 0f c1 4a f8       	lock xadd %ecx,-0x8(%rdx)
   508b2:	85 c9                	test   %ecx,%ecx
   508b4:	0f 8f 3e ff ff ff    	jg     507f8 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x288>
   508ba:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
   508bf:	48 8d b4 24 80 00 00 	lea    0x80(%rsp),%rsi
   508c6:	00 
   508c7:	e8 24 5e ff ff       	callq  466f0 <_ZNSs4_Rep10_M_destroyERKSaIcE@plt>
   508cc:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   508d1:	e9 22 ff ff ff       	jmpq   507f8 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x288>
   508d6:	66 90                	xchg   %ax,%ax
   508d8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
   508dd:	f0 0f c1 50 f8       	lock xadd %edx,-0x8(%rax)
   508e2:	85 d2                	test   %edx,%edx
   508e4:	0f 8f fd fc ff ff    	jg     505e7 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x77>
   508ea:	48 8d b4 24 80 00 00 	lea    0x80(%rsp),%rsi
   508f1:	00 
   508f2:	e8 f9 5d ff ff       	callq  466f0 <_ZNSs4_Rep10_M_destroyERKSaIcE@plt>
   508f7:	e9 eb fc ff ff       	jmpq   505e7 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x77>
   508fc:	0f 1f 40 00          	nopl   0x0(%rax)
   50900:	4c 8d 25 39 4e 27 00 	lea    0x274e39(%rip),%r12        # 2c5740 <_ZTSSs+0x4e77d>
   50907:	eb 0b                	jmp    50914 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x3a4>
   50909:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   50910:	85 c0                	test   %eax,%eax
   50912:	74 0e                	je     50922 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x3b2>
   50914:	41 8b 44 24 10       	mov    0x10(%r12),%eax
   50919:	49 83 c4 10          	add    $0x10,%r12
   5091d:	83 f8 07             	cmp    $0x7,%eax
   50920:	75 ee                	jne    50910 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x3a0>
   50922:	48 8b 03             	mov    (%rbx),%rax
   50925:	48 89 df             	mov    %rbx,%rdi
   50928:	ff 90 88 00 00 00    	callq  *0x88(%rax)
   5092e:	48 8b 03             	mov    (%rbx),%rax
   50931:	48 89 df             	mov    %rbx,%rdi
   50934:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
   50939:	ff 50 30             	callq  *0x30(%rax)
   5093c:	48 85 c0             	test   %rax,%rax
   5093f:	0f 84 7b fe ff ff    	je     507c0 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x250>
   50945:	48 8b 0b             	mov    (%rbx),%rcx
   50948:	48 8d 15 6b b2 1a 00 	lea    0x1ab26b(%rip),%rdx        # 1fbbba <_ZNSt12_Destroy_auxILb0EE9__destroyIPN4Poco16PatternFormatter13PatternActionEEEvT_S6_+0x3dc6a>
   5094f:	48 89 c6             	mov    %rax,%rsi
   50952:	48 89 df             	mov    %rbx,%rdi
   50955:	ff 51 70             	callq  *0x70(%rcx)
   50958:	e9 63 fe ff ff       	jmpq   507c0 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x250>
   5095d:	0f 1f 00             	nopl   (%rax)
   50960:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
   50965:	f0 0f c1 4a f8       	lock xadd %ecx,-0x8(%rdx)
   5096a:	85 c9                	test   %ecx,%ecx
   5096c:	0f 8f 62 fe ff ff    	jg     507d4 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x264>
   50972:	48 8b 74 24 20       	mov    0x20(%rsp),%rsi
   50977:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
   5097c:	e8 6f 5d ff ff       	callq  466f0 <_ZNSs4_Rep10_M_destroyERKSaIcE@plt>
   50981:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   50986:	e9 49 fe ff ff       	jmpq   507d4 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x264>
   5098b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   50990:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
   50995:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
   5099a:	48 89 c1             	mov    %rax,%rcx
   5099d:	e9 30 fd ff ff       	jmpq   506d2 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x162>
   509a2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
   509a7:	f0 0f c1 50 f8       	lock xadd %edx,-0x8(%rax)
   509ac:	85 d2                	test   %edx,%edx
   509ae:	0f 8f 67 fd ff ff    	jg     5071b <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x1ab>
   509b4:	4c 89 ee             	mov    %r13,%rsi
   509b7:	e8 34 5d ff ff       	callq  466f0 <_ZNSs4_Rep10_M_destroyERKSaIcE@plt>
   509bc:	e9 5a fd ff ff       	jmpq   5071b <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x1ab>
   509c1:	48 89 c3             	mov    %rax,%rbx
   509c4:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
   509c9:	48 8d 78 e8          	lea    -0x18(%rax),%rdi
   509cd:	48 39 ef             	cmp    %rbp,%rdi
   509d0:	74 08                	je     509da <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x46a>
   509d2:	4c 89 ee             	mov    %r13,%rsi
   509d5:	e8 36 bb ff ff       	callq  4c510 <closedir@plt+0x5030>
   509da:	48 8b 44 24 40       	mov    0x40(%rsp),%rax
   509df:	48 8d 78 e8          	lea    -0x18(%rax),%rdi
   509e3:	48 39 ef             	cmp    %rbp,%rdi
   509e6:	74 0a                	je     509f2 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x482>
   509e8:	48 8d 74 24 3f       	lea    0x3f(%rsp),%rsi
   509ed:	e8 1e bb ff ff       	callq  4c510 <closedir@plt+0x5030>
   509f2:	48 89 df             	mov    %rbx,%rdi
   509f5:	e8 36 5d ff ff       	callq  46730 <_Unwind_Resume@plt>
   509fa:	48 89 c3             	mov    %rax,%rbx
   509fd:	48 8b 44 24 60       	mov    0x60(%rsp),%rax
   50a02:	48 8d 78 e8          	lea    -0x18(%rax),%rdi
   50a06:	48 39 ef             	cmp    %rbp,%rdi
   50a09:	74 b9                	je     509c4 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x454>
   50a0b:	4c 89 ee             	mov    %r13,%rsi
   50a0e:	e8 fd ba ff ff       	callq  4c510 <closedir@plt+0x5030>
   50a13:	eb af                	jmp    509c4 <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x454>
   50a15:	4c 89 e7             	mov    %r12,%rdi
   50a18:	48 89 c3             	mov    %rax,%rbx
   50a1b:	e8 00 5d ff ff       	callq  46720 <_ZdlPv@plt>
   50a20:	eb db                	jmp    509fd <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x48d>
   50a22:	48 89 c3             	mov    %rax,%rbx
   50a25:	48 8b 84 24 88 00 00 	mov    0x88(%rsp),%rax
   50a2c:	00 
   50a2d:	48 8d 78 e8          	lea    -0x18(%rax),%rdi
   50a31:	48 39 ef             	cmp    %rbp,%rdi
   50a34:	74 c7                	je     509fd <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x48d>
   50a36:	4c 89 ee             	mov    %r13,%rsi
   50a39:	e8 d2 ba ff ff       	callq  4c510 <closedir@plt+0x5030>
   50a3e:	eb bd                	jmp    509fd <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x48d>
   50a40:	48 89 c3             	mov    %rax,%rbx
   50a43:	48 8b 44 24 50       	mov    0x50(%rsp),%rax
   50a48:	48 8d 78 e8          	lea    -0x18(%rax),%rdi
   50a4c:	48 39 ef             	cmp    %rbp,%rdi
   50a4f:	74 89                	je     509da <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x46a>
   50a51:	48 8d b4 24 80 00 00 	lea    0x80(%rsp),%rsi
   50a58:	00 
   50a59:	e8 b2 ba ff ff       	callq  4c510 <closedir@plt+0x5030>
   50a5e:	e9 77 ff ff ff       	jmpq   509da <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x46a>
   50a63:	48 89 c3             	mov    %rax,%rbx
   50a66:	e9 6f ff ff ff       	jmpq   509da <Java_net_kishonti_netman_swig_netmanlibJNI_Services_1getDeviceInfo+0x46a>
   50a6b:	00 00                	add    %al,(%rax)
   50a6d:	00 00                	add    %al,(%rax)
	...
```
由于汇编代码可读性较差，所以使用IDA Pro工具生成代码流程图：
