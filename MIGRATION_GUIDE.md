# 从 Determinate Nix 迁移到官方 Nix

## ⚠️ 重要提示

这个迁移过程需要 **20-30 分钟**，期间会：
- 卸载 Determinate Nix
- 安装官方 Nix
- 重新应用 nix-darwin 配置

**迁移期间你的 Nix 环境会暂时不可用**，但 `/nix/store` 中的所有包都会保留。

## 📋 准备工作

### 当前状态
- ✅ 配置已更新到分支：`migrate-to-official-nix-v2`
- ✅ Darwin 配置已启用 nix-darwin 的 Nix 管理
- ✅ 已配置自动垃圾回收和存储优化

### 备份（可选但推荐）

```bash
# 备份当前环境信息
nix-env -q > ~/nix-backup-$(date +%Y%m%d).txt

# 备份当前 Nix 配置
cp /etc/nix/nix.conf ~/nix.conf.backup 2>/dev/null || true
```

---

## 🚀 迁移步骤

### 步骤 1: 卸载 Determinate Nix

运行 Determinate Nix 的卸载程序：

```bash
/nix/nix-installer uninstall
```

**重要选择**：
- 当询问是否保留 `/nix/store` 时，选择 **保留**（推荐）
  - 这样可以保留所有已下载的包，无需重新下载
  - 节省时间和带宽
- 可能需要输入密码以执行系统级操作

**预期输出**：
```
? Nix was previously installed with nix-installer.
? Uninstall Nix? (y/n)
> y

? Preserve the Nix store at `/nix/store`? (recommended)
> y

...卸载进度信息...

Nix has been uninstalled!
```

**验证卸载**：
```bash
# 这些命令应该失败（command not found）
which nix
# 预期输出：nix not found

nix --version
# 预期输出：command not found: nix
```

如果还能找到 `nix` 命令，需要重启终端后再次检查。

---

### 步骤 2: 安装官方 Nix

使用官方安装脚本安装 Nix：

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

**安装过程**：
- 大约需要 5-10 分钟
- 会自动检测到已存在的 `/nix/store`
- 配置 Nix 守护进程
- 设置环境变量

**预期输出**：
```
Installation finished!

To use Nix, open a new shell or run:

  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

**重新加载环境**：

对于 fish shell：
```bash
exec fish
```

或者源配置文件：
```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
```

**验证安装**：
```bash
nix --version
# 预期输出（不应该包含 "Determinate" 字样）：
# nix (Nix) 2.24.x

which nix
# 预期输出：
# /nix/var/nix/profiles/default/bin/nix
```

---

### 步骤 3: 应用新的 nix-darwin 配置

现在官方 Nix 已安装，可以应用启用了 nix-darwin 管理的新配置：

```bash
cd ~/nixos-config

# 确认在正确的分支
git branch
# 应该显示：* migrate-to-official-nix-v2

# 应用新配置
nix run .#build-switch
```

**首次构建**：
- 可能需要 5-10 分钟（需要构建/下载 darwin-rebuild 等工具）
- 会看到大量构建输出
- nix-darwin 会配置 Nix 守护进程

**预期输出**：
```
building the system configuration...
...大量构建信息...

setting up /etc...
setting up launchd services...
reloading nix-daemon...

system defaults...
setting up user launchd services...

Activation complete!
```

**常见问题**：

1. **如果提示 flake 相关错误**：
   ```bash
   # 更新 flake.lock
   nix flake update

   # 重新尝试
   nix run .#build-switch
   ```

2. **如果 build-switch 命令不存在**：
   ```bash
   # 直接构建并应用
   nix build .#darwinConfigurations.Boruis-MacBook-Air.system
   ./result/sw/bin/darwin-rebuild switch --flake .
   ```

---

### 步骤 4: 验证迁移成功

运行以下命令验证一切正常：

```bash
# 1. 检查 Nix 版本（不应有 "Determinate" 字样）
nix --version

# 2. 验证实验性特性已启用
nix show-config | grep experimental-features
# 预期输出：experimental-features = flakes nix-command

# 3. 检查垃圾回收配置
cat /Library/LaunchDaemons/org.nixos.nix-gc.plist
# 应该看到配置文件内容

# 4. 检查存储优化配置
cat /Library/LaunchDaemons/org.nixos.nix-store-optimise.plist
# 应该看到配置文件内容

# 5. 验证应用程序
ls /Applications/Nix\ Apps/
# 应该看到你所有的应用

# 6. 测试 fish shell
which fish
fish --version

# 7. 测试常用工具
atuin --version
tmux -V
nvim --version
```

---

### 步骤 5: 清理和合并

如果一切正常，合并更改到 main 分支：

```bash
# 提交配置更改
git add hosts/darwin/default.nix
git commit -m "feat: Migrate from Determinate Nix to official Nix

Enable nix-darwin's native Nix management with:
- Automatic garbage collection (weekly, delete >30d)
- Automatic store optimization (weekly)
- Declarative Nix configuration

Removed:
- Determinate Nix dependency
- Manual launchd garbage collection setup

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 切换回 main 分支
git checkout main

# 合并迁移分支
git merge migrate-to-official-nix-v2

# 删除迁移分支（可选）
git branch -d migrate-to-official-nix-v2

# 推送到远程
git push origin main
```

---

## 🔄 如果遇到问题：回滚

如果迁移过程中遇到严重问题，可以回滚到 Determinate Nix：

```bash
# 1. 如果官方 Nix 已安装，先卸载
sudo rm -rf /nix/var/nix/daemon-socket
sudo launchctl bootout system/org.nixos.nix-daemon

# 2. 重新安装 Determinate Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. 重启终端
exec fish

# 4. 切换回 main 分支
cd ~/nixos-config
git checkout main

# 5. 应用原配置
nix run .#build-switch
```

---

## ✅ 迁移完成后的优势

迁移完成后，你将拥有：

1. **完全声明式配置**
   - 所有 Nix 设置都在 `hosts/darwin/default.nix` 中
   - 无需手动配置文件或 launchd 服务

2. **自动维护**
   - 每周日凌晨 2 点：自动垃圾回收（删除 >30 天的旧版本）
   - 每周日凌晨 3 点：自动存储优化（去重，节省空间）

3. **更好的社区支持**
   - 大多数文档和教程基于官方 Nix
   - 与 NixOS 配置完全一致

4. **无供应商锁定**
   - 纯官方 Nix，无第三方依赖

5. **简化的配置**
   - 可以删除 `modules/darwin/org.nixos.nix-gc.plist`
   - 可以删除 `docs/DARWIN_GC_SETUP.md`
   - 所有配置都通过 nix-darwin 管理

---

## 📞 需要帮助？

如果在任何步骤遇到问题：

1. **不要惊慌** - `/nix/store` 中的包都是安全的
2. **检查错误信息** - 记录完整的错误输出
3. **尝试回滚** - 使用上面的回滚步骤
4. **寻求帮助** - 提供错误信息和你执行的步骤

---

## 🎯 准备开始？

确认以下事项后即可开始：

- [ ] 已阅读完整迁移指南
- [ ] 理解迁移过程需要 20-30 分钟
- [ ] 网络连接稳定
- [ ] 有时间完成整个过程（不要在中途停止）
- [ ] 已备份重要数据（可选）

**准备好了吗？从步骤 1 开始！** 🚀
