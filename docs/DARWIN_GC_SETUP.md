# macOS Nix Garbage Collection Setup

## Current Configuration

This system uses **Determinate Nix**, which manages its own daemon and is incompatible with nix-darwin's native Nix management. This means automatic garbage collection cannot be configured declaratively through nix-darwin.

## Manual Garbage Collection Setup

To enable automatic weekly garbage collection on macOS, you need to manually install the provided launchd service:

### Installation

```bash
# Copy the plist to your user LaunchAgents directory
cp ~/nixos-config/modules/darwin/org.nixos.nix-gc.plist ~/Library/LaunchAgents/

# Load the service
launchctl load ~/Library/LaunchAgents/org.nixos.nix-gc.plist

# Verify it's loaded
launchctl list | grep nix-gc
```

### Schedule

The garbage collection runs:
- **Every Sunday at 2:00 AM**
- Deletes generations older than **30 days**
- Logs output to `/tmp/nix-gc.log`
- Logs errors to `/tmp/nix-gc.err`

### Manual Garbage Collection

You can also run garbage collection manually at any time:

```bash
# Delete generations older than 30 days
nix-collect-garbage --delete-older-than 30d

# Or delete all old generations (keeps current)
nix-collect-garbage -d
```

### Customization

To change the schedule, edit `~/Library/LaunchAgents/org.nixos.nix-gc.plist` and modify the `StartCalendarInterval`:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key>
    <integer>0</integer>  <!-- 0=Sunday, 1=Monday, ..., 6=Saturday -->
    <key>Hour</key>
    <integer>2</integer>  <!-- 0-23 -->
    <key>Minute</key>
    <integer>0</integer>  <!-- 0-59 -->
</dict>
```

After editing, reload the service:

```bash
launchctl unload ~/Library/LaunchAgents/org.nixos.nix-gc.plist
launchctl load ~/Library/LaunchAgents/org.nixos.nix-gc.plist
```

## Why Manual Setup?

Determinate Nix and nix-darwin both try to manage the Nix daemon, creating a conflict. By setting `nix.enable = false` in the nix-darwin configuration, we let Determinate Nix handle the core Nix functionality while nix-darwin manages system settings, packages, and home-manager.

This is a **working compromise** that gives you:
- ✅ All the security improvements (SSH ForwardAgent fix)
- ✅ Clean package management (no duplicates)
- ✅ Consistent configuration (useUserPackages)
- ✅ Automatic garbage collection (via launchd)
- ✅ Zero migration risk

## Alternative: Migrate to Official Nix

If you want full declarative control through nix-darwin, you would need to:
1. Uninstall Determinate Nix completely
2. Install official Nix
3. Enable nix-darwin's Nix management (`nix.enable = true`)

This process takes 30-60 minutes and requires careful execution. For most users, the manual launchd setup is sufficient and much simpler.
