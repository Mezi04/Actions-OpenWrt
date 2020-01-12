# 适用斐讯n1的openwrt ci

## 说明

- 编译完成的zip包中有三个文件/文件夹
  - .tar.gz可以用于docker
  - .img是openwrt直刷包，可刷入u盘直接使用，也可以刷入emmc
  - packages为本次编译中产生的所有ipk(包含未打包进固件的插件)

- 目前有两个workflow
  -   [build-lean-n1.yml](https://github.com/Mezi04/Actions-OpenWrt/blob/master/.github/workflows/build-lean-n1.yml) ：基于Lean维护的Openwrt分支，插件较全
  -  [build-openwrt-n1.yml](https://github.com/Mezi04/Actions-OpenWrt/blob/master/.github/workflows/build-openwrt-n1.yml) ：原版Openwrt（19.0.7分支）杂交Lienol的package，插件较少
  - 两个workflow都会添加额外的openclash进固件，如不喜欢可自行注释

## 感谢以下作者的无私奉献

- P3TERX [Action-Openwrt](https://github.com/P3TERX/Actions-OpenWrt)

- tuanqing [制作"贝壳云 / 斐讯N1"可启动OpenWrt镜像的一键脚本](https://github.com/tuanqing/mknop)

- Lean [lede](https://github.com/coolsnowwolf/lede)

- Lienol [openwrt-package](https://github.com/Lienol/openwrt-package)

- jerrykuku [argon 主题](https://github.com/jerrykuku/luci-theme-argon)

- vernesong [Openclash](https://github.com/vernesong/OpenClash)

- openwrt项目组 [openwrt](https://github.com/openwrt/openwrt)

  

## 关于项目如何使用，可参考P3TERX的说明

> ## Usage
>
> - Sign up for [GitHub Actions](https://github.com/features/actions/signup)
> - Fork [this GitHub repository](https://github.com/P3TERX/Actions-OpenWrt)
> - Generate `.config` files using [Lean's OpenWrt](https://github.com/coolsnowwolf/lede) source code.
> - Push `.config` file to the GitHub repository, and the build starts automatically.Progress can be viewed on the Actions page.
> - When the build is complete, click the `Artifacts` button in the upper right corner of the Actions page to download the binaries.
>
> [Read the details in my blog (in Chinese) | 中文教程](https://p3terx.com/archives/build-openwrt-with-github-actions.html)
