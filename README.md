# 🚀 Cross-Platform Dotfiles

Modular configuration framework managed by `chezmoi`. Optimized for macOS, Debian, and Arch Linux.

[切换至中文版](./README_zh.md)

---

## 🛠️ Philosophy
* **Isolation**: Source configs in subdirs; deployment logic in `dot_tmpl/`.
* **Mapping**: Handles OS differences via lookup tables in `.chezmoi.toml.tmpl`.
* **Sync**: Distinguishes between Core Utilities (auto) and Enhanced Tools (tips).

## 📂 Structure
* **dot_tmpl/**: Deployment templates (chezmoiroot)
* **zsh/**: Shell logic & Powerlevel10k
* **git/**: Git behaviors & identity
* **aerospace/**: macOS Window management
* **...**: Other modular configurations

## 🔧 Scalability
To add a new OS (e.g., Fedora, Alpine):
1. **Update Mappings**: Add new keys to dictionaries in `.chezmoi.toml.tmpl`.
2. **Hook PKG Manager**: Add a branch for the new manager (dnf/apk) in the `run_onchange` script.
3. **Filter Assets**: Use `.chezmoiignore` to exclude files if necessary.

## 🚀 Quick Start
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-repo-url>