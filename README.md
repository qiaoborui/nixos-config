# NixOS Configuration

My personal NixOS and nix-darwin configuration files for declarative system management.

## Structure

```
.
├── flake.nix           # Main flake configuration
├── hosts/              # Host-specific configurations
│   ├── darwin/         # macOS configuration
│   └── nixos/          # Linux configuration
├── modules/            # Reusable modules
│   ├── darwin/         # macOS-specific modules
│   ├── nixos/          # Linux-specific modules
│   └── shared/         # Shared configurations
├── overlays/           # Package overlays
└── apps/               # Helper scripts
```

## Features

- **Declarative Dock configuration** for macOS
- **Home Manager** integration for user environment
- **Homebrew** integration via nix-homebrew
- **Secrets management** with agenix
- Shared configuration between macOS and NixOS

## Usage

### macOS (nix-darwin)

```bash
# Build and switch
darwin-rebuild switch --flake ~/nixos-config/.#macbook

# Or use the flake app
nix run .#build-switch
```

### NixOS

```bash
# Build and switch
sudo nixos-rebuild switch --flake .#hostname
```

## Notes

- Secrets are stored in a separate private repository (`nix-secret/`)
- The Dock configuration automatically manages persistent apps while preserving recent apps
