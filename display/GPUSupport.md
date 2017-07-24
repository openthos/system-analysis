
The current supported GPUs of OPENTHOS / Android-x86

* Intel
  - Intel GMA cards are supported by kernel i915 driver + mesa i915 dri driver (enabled) or i915g gallium3d driver (not enabled).
    - https://en.wikipedia.org/wiki/Intel_GMA
  - Intel GEN5+ cards are supported by kernel i915 drivre + mesa i965 dri driver.
    - https://en.wikipedia.org/wiki/Intel_HD_and_Iris_Graphics 
  - PowerVR based GPUs are not supported
  - Refer: https://en.wikipedia.org/wiki/List_of_Intel_graphics_processing_units

* Nvidia
  - Supported by kernel nouveau driver + mesa nouveau gallium3d driver
  - FeatureMatrices: https://nouveau.freedesktop.org/wiki/FeatureMatrix/
  - CodeNames: https://nouveau.freedesktop.org/wiki/CodeNames/
  - In particular, GT720 is well supported according to the feature matrices.

* AMD Radeon
  - AMD non-GCN cards are supported by kernel radeon driver + mesa r300g/r600g gallium3d driver.
  - AMD GCN cards are supported by kernel amdgpu driver + mesa radeonsi gallium3d driver
  - Refer: https://en.wikipedia.org/wiki/Radeon#Free_and_open-source_graphics_device_driver_.22Radeon.22
  - GCN 1.1 (R7 340/350) may be supported older radeon + r600g.
  
* VMware
  - VMware virtual GPU is supported by kernel vmwgfx driver + mesa svga gallium3d driver
  - Refer: https://www.mesa3d.org/vmware-guest.html

* QEMU
  - QEMU virtual GPU (virtio) is supported by kernel virtio driver + mesa virgl gallium3d driver
  - Refer: https://virgil3d.github.io/
