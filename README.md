# NozzleMods for EmComm Tools R5

A comprehensive collection of scripts and tools to enhance EmComm Tools R5 with VARA modem support, radio configuration utilities, and system maintenance tools.

## Quick Installation

```bash
curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETC5_NozzleMods/main/install.sh | bash
```

Or download and run:
```bash
wget https://raw.githubusercontent.com/CowboyPilot/ETC5_NozzleMods/main/install.sh
chmod +x install.sh
./install.sh
```

## What Gets Installed

The installer creates `~/NozzleMods/` with the following structure:

```
NozzleMods/
├── install.sh                    # This installer (saved for updates)
├── bin/
│   └── nozzle-menu              # Main menu (also copied to /opt/emcomm-tools/bin/)
├── wine-tools/
│   ├── wine-setup.sh            # VARA tools installer (Winlink, VarAC, VARA HF/FM)
│   └── fix-varac-13.sh          # Fix .NET issues with VarAC V13
├── radio-tools/
│   ├── xiegu-g90/
│   │   └── update-g90-config.sh # Configure G90 DigiRig PTT options
│   └── yaesu-ft710/
│       ├── install_ft710.sh     # Install FT-710 support
│       ├── yaesu-ft710.json     # Radio configuration
│       ├── 78-et-ft710.rules    # udev rules
│       └── udev-tester.patch    # System patches
└── linux-tools/
    └── fix-sources.sh           # Fix APT repository issues
```

## Prerequisites

Before using NozzleMods, ensure you have:

1. **EmComm Tools R5** properly installed
2. Run `et-user` to configure your callsign
3. Run `et-audio` to configure audio
4. Run `et-radio` to select your radio

## Main Menu: nozzle-menu

After installation, access all features by running:
```bash
nozzle-menu
```

The menu provides:

### VARA Applications
- VarAC + VARA HF/FM
- Winlink + VARA HF/FM
- Pat + VARA HF/FM
- VARA modems standalone

Features:
- Automatic port allocation (8300-8350)
- Clean process management
- INI file configuration
- COM10 mapping to /dev/et-cat

### Radio Configuration
- **Xiegu G90**: Configure DigiRig PTT (CAT or RTS)
- **Yaesu FT-710**: Install full support with udev rules

### System Tools
- Fix APT repository sources (especially for Ubuntu 22.10 kinetic)
- Fix VarAC V13 .NET runtime issues

## VARA Tools Installation

If VARA tools aren't installed, nozzle-menu will offer to run the installer which:

1. Creates 32-bit Wine prefix at `~/.wine32`
2. Installs dependencies (dotnet, vcrun, etc.)
3. Downloads and installs:
   - Winlink Express
   - VARA HF
   - VARA FM
   - VarAC (if installer available)
4. Configures COM10 → /dev/et-cat mapping
5. Creates GNOME menu launchers

### Manual VARA Installation

```bash
cd ~/NozzleMods/wine-tools
./wine-setup.sh
```

**Important**: The first run may require you to log out and back in to activate the 32-bit Wine environment.

## Individual Tool Usage

### Radio Configuration

**Xiegu G90 DigiRig PTT:**
```bash
sudo ~/NozzleMods/radio-tools/xiegu-g90/update-g90-config.sh
```
Choose between CAT PTT or RTS PTT options.

**Yaesu FT-710 Support:**
```bash
cd ~/NozzleMods/radio-tools/yaesu-ft710
sudo ./install_ft710.sh
```
Installs udev rules, radio configuration, and patches system files. Creates backup for easy rollback.

### System Fixes

**Fix APT Sources (Ubuntu 22.10/kinetic):**
```bash
sudo ~/NozzleMods/linux-tools/fix-sources.sh
```

**Fix VarAC V13 .NET Issues:**
```bash
~/NozzleMods/wine-tools/fix-varac-13.sh
```

## Radio-Specific Notes

### Xiegu G90
Menu settings for digital modes:
- Set appropriate audio levels
- Configure DigiRig PTT mode

### Yaesu FT-710
Required menu settings:
- 031 CAT RATE = 38400bps
- 032 CAT TOT = 100ms
- FUNC → RADIO SETTING → MODE PSK/DATA
  - USB OUT LEVEL 30
  - USB MOD GAIN 70
- Select Mode DATA-U

## Troubleshooting

### VARA Applications Won't Start
1. Ensure VARA tools are installed (option 0 in menu)
2. Check Wine prefix exists: `ls ~/.wine32`
3. Verify executables: `ls ~/.wine32/drive_c/VARA/`

### Port Conflicts
The launcher automatically finds free ports (8300-8350). If issues occur:
```bash
ss -tan | grep 8300
```

### Radio Not Detected
1. Verify selection: `et-radio`
2. Check device: `ls -l /dev/et-cat /dev/et-audio`
3. Monitor udev: `sudo udevadm monitor`

### VarAC V13 Crashes
Run the .NET fix:
```bash
~/NozzleMods/wine-tools/fix-varac-13.sh
```

## Updating NozzleMods

Simply re-run the installer:
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/NozzleMods/main/install.sh | bash
```

Or if you have it downloaded:
```bash
~/NozzleMods/install.sh
```

## File Locations

- **User Scripts**: `~/NozzleMods/`
- **nozzle-menu**: `/opt/emcomm-tools/bin/` (accessible from anywhere)
- **Wine Prefix**: `~/.wine32/`
- **EmComm Tools**: `/opt/emcomm-tools/`
- **Configuration**: `~/.config/emcomm-tools/`

## Backup and Restore

### Xiegu G90
Backups are created automatically:
```bash
/opt/emcomm-tools/conf/radios.d/xiegu-g90.json.backup.*
```

### Yaesu FT-710
Backup location:
```bash
~/.ft710-backup/udev-tester.sh.backup
```
To restore: re-run install script and choose restore option.

## Support

For issues or questions:
1. Check the individual script files for inline documentation
2. Review EmComm Tools R5 documentation
3. Test radio connectivity with `et-radio`

## Credits

- EmComm Tools R5 by [TheTechPrepper](https://github.com/thetechprepper)
- VARA modems by Jose Alberto Reyes Martin, EA5HVK
- VarAC by Irad Yakir
- Winlink Express by Winlink Development Team

## License

These scripts are provided as-is for use with EmComm Tools R5. Use at your own risk.

## 73!

Happy operating!