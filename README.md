# 🚀 Cross-Platform Dotfiles

Modular configuration framework managed by `chezmoi`. Optimized for macOS, Debian, and Arch Linux.

[切换至中文版](./README_zh.md)

---

## 📂 Structure
* **dot_tmpl/**: Deployment templates (chezmoiroot)
* **zsh/**: Shell logic & Powerlevel10k & Antidote
* **git/**: Git behaviors & identity
* **aerospace/**: macOS Window management
* **...**: Other modular configurations

## 🔧 Scalability
To add a new OS (e.g., Fedora, Alpine):
1. **Update Mappings**: Add new keys to dictionaries in `.chezmoi.toml.tmpl`.
2. **Hook PKG Manager**: Extended for automation in the `.chezmoiscripts` scripts.
3. **Filter Assets**: Use `.chezmoiignore` to exclude files if necessary.

**Change to zsh firstly: `chsh -s $(command -v zsh)`**