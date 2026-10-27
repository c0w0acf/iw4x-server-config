# iw4x-server-config
# IW4x Self-Hosted Dedicated Server & Specialist Mod Orchestration

A streamlined, automated setup for hosting a custom Call of Duty: Modern Warfare 2 (IW4x) dedicated server featuring **Specialist Perks/Strike Packages** and **IW4MAdmin** integration.

## Features
- **Automated Orchestration:** PowerShell script (`Deploy-IW4xServer.ps1`) handles directory validation, firewall rules, server configuration sync, and concurrent service execution.
- **Specialist Perk Mod:** Built-in support for 8-kill streak perk stacking (Pro versions unlocked).
- **RCON & Moderation:** Pre-configured log synchronization for IW4MAdmin webfront tracking.

## Quick Start
1. Populate your base IW4x server binaries into your target directory.
2. Run PowerShell as Administrator.
3. Execute the deployment script: