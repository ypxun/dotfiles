# 🚀 跨平台 Dotfiles 配置方案

基于 `chezmoi` 管理的模块化配置框架，支持 macOS、Debian、Arch Linux 及其它类 Unix 系统。

[Switch to English](./README.md)

---

## 🛠️ 设计哲学
* **逻辑隔离**: 核心配置位于独立目录；分发逻辑收纳于 `dot_tmpl/`。
* **字典映射**: 通过查找表处理环境差异，拒绝复杂的嵌套判断。
* **声明式同步**: 区分核心工具（自动安装）与增强组件（状态巡检）。

## 📂 架构概览
* **dot_tmpl/**: 部署模板 (chezmoiroot)
* **zsh/**: Shell 逻辑与 P10K 配置
* **git/**: Git 行为与身份识别
* **aerospace/**: macOS 窗口平铺管理
* **...**: 其他模块化配置

## 🔧 扩展性适配
若需适配新系统 (如 Fedora, Alpine)：
1. **更新映射表**: 在 `.chezmoi.toml.tmpl` 字典中为新系统注册路径与包名。
2. **接入包管理**: 在 `run_onchange` 脚本中增加对应包管理器 (dnf/apk) 的分支。
3. **规则过滤**: 在 `.chezmoiignore` 中针对新环境排除特定文件。

## 🚀 快速开始
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <你的仓库地址>