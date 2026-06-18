# 🚀 跨平台 Dotfiles 配置方案

基于 `chezmoi` 管理的模块化配置框架，支持 macOS、Debian、Arch Linux 及其它类 Unix 系统。

[Switch to English](./README.md)

---

## 📂 架构概览
* **dot_tmpl/**: 部署模板 (chezmoiroot)
* **zsh/**: Shell 逻辑与 P10K 配置与 Antidote 插件管理
* **git/**: Git 行为与身份识别
* **aerospace/**: macOS 窗口平铺管理
* **...**: 其他模块化配置

## 🔧 扩展性适配
若需适配新系统 (如 Fedora, Alpine)：
1. **更新映射表**: 在 `.chezmoi.toml.tmpl` 字典中为新系统注册路径与包名。
2. **接入包管理**: 在 `.chezmoiscripts` 脚本中做逻辑判断。
3. **规则过滤**: 在 `.chezmoiignore` 中针对新环境排除特定文件。

**需先手动切换为zsh: `chsh -s $(command -v zsh)`**