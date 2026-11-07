# Desktop Icon Refresh Monitor

A Windows batch script that watches the desktop for the moment [Windhawk](https://windhawk.net/) finishes refreshing your desktop icons, then restarts Windows Explorer so everything settles into a clean state. If no icon refresh is ever detected, it restarts Explorer anyway and forces a system-wide icon refresh.

Current version: **v12**

## Requirements

- Windows with PowerShell 5.1 or later (included with Windows 10/11)
- Windhawk installed (the script looks for a process named `windhawk`)
- Desktop icons placed in the **left portion of the primary monitor**
- An interactive desktop session (the script takes screenshots to detect changes)

## Usage

1. Place `IconRefreshMonitor.bat` in any folder you can write to.
2. Run it (double-click, or start it at login via the Startup folder or Task Scheduler).
3. Launch Windhawk, or let it launch on its own, while the script is running.

No installation or configuration is needed. On each run the batch file generates `IconRefreshMonitor.ps1` next to itself and runs it with `-NoProfile -ExecutionPolicy Bypass -STA`. You can delete the generated `.ps1` at any time; it is rewritten on every run.

## How it works

1. **Baseline.** Captures screenshots of the left 30% of the desktop working area (the screen minus the taskbar, and skipping the top and bottom 3%) and keeps the latest one as a baseline.
2. **Wait for Windhawk.** Waits up to 20 seconds for `windhawk` to start, refreshing the baseline the whole time. If it never starts, the script exits without touching Explorer.
3. **Monitor.** Once Windhawk is running, compares live screenshots against the baseline for up to 20 seconds. A change counts as a candidate when at least 1.2% of sampled pixels changed and at least 0.6% changed strongly. The area around the mouse cursor is ignored.
4. **Confirm.** Two consecutive candidate hits trigger a persistence re-check 500 ms later. If the change is gone, it is treated as a false alarm and the baseline is rebuilt.
5. **Restart Explorer.**
   - **Refresh confirmed:** waits 2 seconds, then restarts Explorer.
   - **Timed out (20 seconds, nothing detected):** restarts Explorer, then triggers an icon refresh with `SHChangeNotify` (`SHCNE_ASSOCCHANGED`), the same trigger used by `RefreshIcons.bat`. Success or failure is printed to the console.

### Explorer restart details

- Explorer is stopped, and the script waits up to 4 seconds for Windows to bring the shell back on its own. It only launches `explorer.exe` manually if that doesn't happen, which avoids opening a stray second File Explorer window.
- For about 3 seconds afterward it closes any File Explorer windows (class `CabinetWClass`) that reopen automatically. The taskbar and desktop windows are never targeted.

## Files

| File | Purpose |
|------|---------|
| `IconRefreshMonitor.bat` | The script you run |
| `IconRefreshMonitor.ps1` | Generated at runtime; safe to delete |
| `IconRefreshDebug\` | Old debug screenshot folder; deleted automatically if present |

## Exit codes

The batch file returns the PowerShell exit code. The script exits with `0` both on normal completion and when Windhawk never launches.

## Limitations and notes

- Only the **primary monitor** is watched.
- Detection is pixel-based, so a wallpaper that animates, or other visual activity in the watched area, can cause false triggers. The two-hit and persistence checks reduce this but don't eliminate it.
- Any File Explorer windows you have open will be closed when Explorer restarts. Save your work in them first.
- Thresholds (`0.012`, `0.006`, the 20-second timeouts, the 2-second delay) are hardcoded in the batch file. Edit the corresponding `echo` lines to tune them.

## Changelog

- **v12:** After a timeout-triggered restart, refreshes icons directly via `SHChangeNotify` instead of opening Settings at Default apps. The trigger lives in `Invoke-IconRefresh` and reports failures in the console.
- **v11 and earlier:** See the script header history.
