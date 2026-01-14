# CMT Cube RK3288 U-Boot

自动构建适用于 CMT Cube RK3288 的 U-Boot，输出 `full.bin` 可直接写入 SD/eMMC：

```bash
sudo dd if=full.bin of=/dev/sdX bs=512 seek=0
sync
```

产物包含：
- `idbloader.img`（SPL）
- `boot.img`（U-Boot + DTB）
- 合并为 `full.bin`（sector 0 开始）