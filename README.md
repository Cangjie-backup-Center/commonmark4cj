<div align="center">
<h1>markdown hybrid</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.2.6-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-95.6%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

用于根据CommonMark规范（以及一些扩展）解析和呈现Markdown文本。

### 特性

- 🚀 解析markdown文本

- 🛠️ Node树状结构

- 💡 遍历/渲染Node树

## 软件架构

### 源码目录

```shell
├── entry                  # 示例模块
├── markdown_hybrid        # markdown互操作模块
└── README.md              # 整体介绍
```

## 约束与限制

- 在下述版本验证通过:
    - IDE: DevEco Studio 5.1.1 Beta1(Build Version:5.1.1.821)
    - Cangjie Plugin: Cangjie Support Plugin 5.1.1.821
- 最低适配API版本: 5.0.2(14)
- 要求使用最终集成的HAP模块中hvigorfile.ts从 @ohos/cangjie-build-support 导入的hapTasks [参考](https://developer.huawei.com/consumer/cn/doc/cangjie-guides-V5/cj-hvigor-configuration-V5)

## 开源协议

本项目基于 [BSD-2-Clause](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。