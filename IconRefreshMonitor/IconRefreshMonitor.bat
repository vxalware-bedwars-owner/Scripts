@echo off
setlocal EnableExtensions

rem ============================================================
rem  Desktop Icon Refresh Monitor v12
rem
rem  CHANGED vs v11:
rem   - After a timeout-triggered Explorer restart ONLY, the script no
rem     longer opens Settings at Default apps, Microsoft Edge. It now
rem     triggers the icon refresh directly with SHChangeNotify
rem     (SHCNE_ASSOCCHANGED), the same trigger used by RefreshIcons.bat.
rem   - The trigger lives in a function, Invoke-IconRefresh, and reports
rem     success or failure in the console instead of failing silently.
rem   - Unchanged: a confirmed icon refresh still restarts Explorer after
rem     2 seconds with no extra refresh trigger, and if Windhawk never
rem     launches within 20 seconds the script just exits.
rem ============================================================

set "PSFILE=%~dp0IconRefreshMonitor.ps1"
set "DEBUGDIR=%~dp0IconRefreshDebug"

rem Delete any leftover debug screenshots from earlier troubleshooting.
if exist "%DEBUGDIR%" rmdir /s /q "%DEBUGDIR%" >nul 2>&1

>"%PSFILE%" echo $ErrorActionPreference = 'SilentlyContinue'
>>"%PSFILE%" echo Add-Type -AssemblyName System.Drawing
>>"%PSFILE%" echo Add-Type -AssemblyName System.Windows.Forms
>>"%PSFILE%" echo.
>>"%PSFILE%" echo # Precise window targeting: Process.MainWindowHandle is unreliable for a
>>"%PSFILE%" echo # multi-window process like explorer.exe - it can resolve to the taskbar
>>"%PSFILE%" echo # instead of a stray File Explorer window, and closing the taskbar window
>>"%PSFILE%" echo # is the same as Alt+F4 on the desktop (triggers the Shut Down dialog).
>>"%PSFILE%" echo # This targets ONLY windows of class 'CabinetWClass', which is File
>>"%PSFILE%" echo # Explorer's window class - never the taskbar (Shell_TrayWnd) or the
>>"%PSFILE%" echo # desktop (Progman / WorkerW).
>>"%PSFILE%" echo $memberDef = '[DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam); public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam); [DllImport("user32.dll")] public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount); [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd); [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);'
>>"%PSFILE%" echo Add-Type -Namespace WinApiHelper -Name Native -MemberDefinition $memberDef
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Close-ExplorerWindows {
>>"%PSFILE%" echo     $found = New-Object System.Collections.Generic.List[IntPtr]
>>"%PSFILE%" echo     $callback = {
>>"%PSFILE%" echo         param($hWnd, $lParam)
>>"%PSFILE%" echo         if ([WinApiHelper.Native]::IsWindowVisible($hWnd)) {
>>"%PSFILE%" echo             $sb = New-Object System.Text.StringBuilder 256
>>"%PSFILE%" echo             [WinApiHelper.Native]::GetClassName($hWnd, $sb, $sb.Capacity) ^| Out-Null
>>"%PSFILE%" echo             if ($sb.ToString() -eq 'CabinetWClass') { $found.Add($hWnd) }
>>"%PSFILE%" echo         }
>>"%PSFILE%" echo         return $true
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo     [WinApiHelper.Native]::EnumWindows($callback, [IntPtr]::Zero) ^| Out-Null
>>"%PSFILE%" echo     foreach ($h in $found) { [WinApiHelper.Native]::SendMessage($h, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero) ^| Out-Null }
>>"%PSFILE%" echo     return $found.Count
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Restart-Explorer {
>>"%PSFILE%" echo     Write-Host 'Restarting Windows Explorer...'
>>"%PSFILE%" echo     Get-Process explorer -ErrorAction SilentlyContinue ^| Stop-Process -Force
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     # Windows has its own crash-recovery that auto-restarts explorer.exe as
>>"%PSFILE%" echo     # the shell within a second or two, on its own. Launching it ourselves
>>"%PSFILE%" echo     # right away used to race that auto-restart: if Windows had already
>>"%PSFILE%" echo     # brought the shell back by the time we called Start-Process, our call
>>"%PSFILE%" echo     # became a SECOND explorer.exe instance - and a second instance doesn't
>>"%PSFILE%" echo     # become the shell, it just opens a plain File Explorer window.
>>"%PSFILE%" echo     # Fix: wait to see if Windows brings the shell back on its own first,
>>"%PSFILE%" echo     # and only launch it manually if it doesn't within a few seconds.
>>"%PSFILE%" echo     $shellBack = $false
>>"%PSFILE%" echo     for ($i=0; $i -lt 20; $i++) {
>>"%PSFILE%" echo         Start-Sleep -Milliseconds 200
>>"%PSFILE%" echo         if (Get-Process explorer -ErrorAction SilentlyContinue) { $shellBack = $true; break }
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo     if (-not $shellBack) {
>>"%PSFILE%" echo         Write-Host '  shell did not come back on its own, launching it.'
>>"%PSFILE%" echo         Start-Process explorer.exe
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     # Safety net: some setups reopen a folder window a moment after the
>>"%PSFILE%" echo     # shell restarts (e.g. 'restore previous windows'). Sweep for genuine
>>"%PSFILE%" echo     # File Explorer windows (CabinetWClass only) a few times over ~3
>>"%PSFILE%" echo     # seconds rather than just once.
>>"%PSFILE%" echo     $totalClosed = 0
>>"%PSFILE%" echo     for ($i=0; $i -lt 6; $i++) {
>>"%PSFILE%" echo         Start-Sleep -Milliseconds 500
>>"%PSFILE%" echo         $totalClosed += Close-ExplorerWindows
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo     if ($totalClosed -gt 0) { Write-Host ('  closed {0} auto-opened Explorer window(s).' -f $totalClosed) }
>>"%PSFILE%" echo     Write-Host 'Explorer restarted.'
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Invoke-IconRefresh {
>>"%PSFILE%" echo     # Same trigger as RefreshIcons.bat: broadcast SHCNE_ASSOCCHANGED (0x08000000)
>>"%PSFILE%" echo     # through SHChangeNotify so Explorer reloads every icon.
>>"%PSFILE%" echo     Write-Host 'Triggering system icon refresh...'
>>"%PSFILE%" echo     try {
>>"%PSFILE%" echo         $sig = '[DllImport("shell32.dll")] public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);'
>>"%PSFILE%" echo         $shell32 = Add-Type -MemberDefinition $sig -Name 'Shell32' -Namespace 'Win32' -PassThru -ErrorAction Stop
>>"%PSFILE%" echo         $shell32::SHChangeNotify(0x08000000, 0x0000, [IntPtr]::Zero, [IntPtr]::Zero)
>>"%PSFILE%" echo         Write-Host '  icon refresh triggered.'
>>"%PSFILE%" echo     } catch {
>>"%PSFILE%" echo         Write-Host ('  icon refresh failed: {0}' -f $_.Exception.Message)
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Get-DesktopRegion {
>>"%PSFILE%" echo     # WorkingArea = screen minus the taskbar, whichever edge it's
>>"%PSFILE%" echo     # docked to. This guarantees the watched region never overlaps
>>"%PSFILE%" echo     # the taskbar, so taskbar mods/repaints can't be mistaken for
>>"%PSFILE%" echo     # a desktop icon refresh.
>>"%PSFILE%" echo     $wa = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
>>"%PSFILE%" echo     $x = $wa.Left
>>"%PSFILE%" echo     $y = [int]($wa.Top + ($wa.Height * 0.03))
>>"%PSFILE%" echo     $w = [int]($wa.Width * 0.30)
>>"%PSFILE%" echo     $h = [int]($wa.Height * 0.94)
>>"%PSFILE%" echo     return [pscustomobject]@{ X=$x; Y=$y; W=$w; H=$h }
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Get-RegionBitmap($r) {
>>"%PSFILE%" echo     $bmp = New-Object System.Drawing.Bitmap($r.W,$r.H)
>>"%PSFILE%" echo     $g = [System.Drawing.Graphics]::FromImage($bmp)
>>"%PSFILE%" echo     $g.CopyFromScreen($r.X,$r.Y,0,0,$bmp.Size)
>>"%PSFILE%" echo     $g.Dispose()
>>"%PSFILE%" echo     return $bmp
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Get-CursorRegionPos($r) {
>>"%PSFILE%" echo     $p = [System.Windows.Forms.Cursor]::Position
>>"%PSFILE%" echo     return [pscustomobject]@{ X = ($p.X - $r.X); Y = ($p.Y - $r.Y) }
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Compare-Bitmaps($base,$cur,$step,$cursor) {
>>"%PSFILE%" echo     $changed = 0
>>"%PSFILE%" echo     $samples = 0
>>"%PSFILE%" echo     $strong = 0
>>"%PSFILE%" echo     $cursorPad = 24
>>"%PSFILE%" echo     for ($y=0; $y -lt $base.Height; $y += $step) {
>>"%PSFILE%" echo         for ($x=0; $x -lt $base.Width; $x += $step) {
>>"%PSFILE%" echo             if ($cursor) {
>>"%PSFILE%" echo                 $dx = [Math]::Abs($x - $cursor.X)
>>"%PSFILE%" echo                 $dy = [Math]::Abs($y - $cursor.Y)
>>"%PSFILE%" echo                 if (($dx -le $cursorPad) -and ($dy -le $cursorPad)) { continue }
>>"%PSFILE%" echo             }
>>"%PSFILE%" echo             $a = $base.GetPixel($x,$y)
>>"%PSFILE%" echo             $b = $cur.GetPixel($x,$y)
>>"%PSFILE%" echo             $d = [Math]::Abs($a.R-$b.R) + [Math]::Abs($a.G-$b.G) + [Math]::Abs($a.B-$b.B)
>>"%PSFILE%" echo             if ($d -ge 75) { $changed++ }
>>"%PSFILE%" echo             if ($d -ge 150) { $strong++ }
>>"%PSFILE%" echo             $samples++
>>"%PSFILE%" echo         }
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo     if ($samples -eq 0) { return [pscustomobject]@{ Ratio=0; Strong=0 } }
>>"%PSFILE%" echo     return [pscustomobject]@{ Ratio=([double]$changed/$samples); Strong=([double]$strong/$samples) }
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo function Build-Baseline($region,$rounds) {
>>"%PSFILE%" echo     $b = Get-RegionBitmap $region
>>"%PSFILE%" echo     for ($i=0; $i -lt $rounds; $i++) {
>>"%PSFILE%" echo         Start-Sleep -Milliseconds 150
>>"%PSFILE%" echo         $next = Get-RegionBitmap $region
>>"%PSFILE%" echo         $b.Dispose()
>>"%PSFILE%" echo         $b = $next
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo     return $b
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host ''
>>"%PSFILE%" echo Write-Host '=============================================='
>>"%PSFILE%" echo Write-Host ' Desktop Icon Refresh Monitor v12'
>>"%PSFILE%" echo Write-Host '=============================================='
>>"%PSFILE%" echo Write-Host ''
>>"%PSFILE%" echo $region = Get-DesktopRegion
>>"%PSFILE%" echo Write-Host ('Watching left desktop area (taskbar excluded): {0}x{1} at ({2},{3})' -f $region.W,$region.H,$region.X,$region.Y)
>>"%PSFILE%" echo Write-Host 'Building a validated baseline...'
>>"%PSFILE%" echo $baseline = Build-Baseline $region 3
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host 'Waiting for Windhawk (baseline stays fresh in the meantime)...'
>>"%PSFILE%" echo $waitStart = Get-Date
>>"%PSFILE%" echo $timedOut = $false
>>"%PSFILE%" echo while (-not (Get-Process -Name 'windhawk' -ErrorAction SilentlyContinue)) {
>>"%PSFILE%" echo     if (((Get-Date) - $waitStart).TotalSeconds -ge 20) { $timedOut = $true; break }
>>"%PSFILE%" echo     Start-Sleep -Milliseconds 150
>>"%PSFILE%" echo     $next = Get-RegionBitmap $region
>>"%PSFILE%" echo     $baseline.Dispose()
>>"%PSFILE%" echo     $baseline = $next
>>"%PSFILE%" echo }
>>"%PSFILE%" echo if ($timedOut) {
>>"%PSFILE%" echo     Write-Host '20 seconds passed with no sign of Windhawk. Exiting.'
>>"%PSFILE%" echo     $baseline.Dispose()
>>"%PSFILE%" echo     exit 0
>>"%PSFILE%" echo }
>>"%PSFILE%" echo Write-Host 'Windhawk launched'
>>"%PSFILE%" echo Write-Host 'Monitoring for the icon refresh...'
>>"%PSFILE%" echo.
>>"%PSFILE%" echo $hits = 0
>>"%PSFILE%" echo $confirmed = $false
>>"%PSFILE%" echo $monitorTimedOut = $false
>>"%PSFILE%" echo $monitorStart = Get-Date
>>"%PSFILE%" echo.
>>"%PSFILE%" echo while (-not $confirmed) {
>>"%PSFILE%" echo     if (((Get-Date) - $monitorStart).TotalSeconds -ge 20) {
>>"%PSFILE%" echo         $monitorTimedOut = $true
>>"%PSFILE%" echo         break
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo     $cursor = Get-CursorRegionPos $region
>>"%PSFILE%" echo     $current = Get-RegionBitmap $region
>>"%PSFILE%" echo     $cmp = Compare-Bitmaps $baseline $current 6 $cursor
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     if (($cmp.Ratio -ge 0.012) -and ($cmp.Strong -ge 0.006)) {
>>"%PSFILE%" echo         $hits++
>>"%PSFILE%" echo         Write-Host ('  candidate hit {0}: ratio={1:N3} strong={2:N3}' -f $hits,$cmp.Ratio,$cmp.Strong)
>>"%PSFILE%" echo     } else {
>>"%PSFILE%" echo         $hits = 0
>>"%PSFILE%" echo         $current.Dispose()
>>"%PSFILE%" echo         Start-Sleep -Milliseconds 40
>>"%PSFILE%" echo         continue
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     if ($hits -ge 2) {
>>"%PSFILE%" echo         Write-Host '  candidate confirmed, re-verifying it persists...'
>>"%PSFILE%" echo         $current.Dispose()
>>"%PSFILE%" echo.
>>"%PSFILE%" echo         Start-Sleep -Milliseconds 500
>>"%PSFILE%" echo         $cursor2 = Get-CursorRegionPos $region
>>"%PSFILE%" echo         $recheck = Get-RegionBitmap $region
>>"%PSFILE%" echo         $cmp2 = Compare-Bitmaps $baseline $recheck 6 $cursor2
>>"%PSFILE%" echo         $recheck.Dispose()
>>"%PSFILE%" echo         Write-Host ('  persistence check: ratio={0:N3} strong={1:N3}' -f $cmp2.Ratio,$cmp2.Strong)
>>"%PSFILE%" echo.
>>"%PSFILE%" echo         if (($cmp2.Ratio -ge 0.012) -and ($cmp2.Strong -ge 0.006)) {
>>"%PSFILE%" echo             $confirmed = $true
>>"%PSFILE%" echo             break
>>"%PSFILE%" echo         } else {
>>"%PSFILE%" echo             Write-Host '  change did not persist - treating as a false alarm, resetting baseline.'
>>"%PSFILE%" echo             $hits = 0
>>"%PSFILE%" echo             $baseline.Dispose()
>>"%PSFILE%" echo             $baseline = Build-Baseline $region 2
>>"%PSFILE%" echo         }
>>"%PSFILE%" echo     } else {
>>"%PSFILE%" echo         $current.Dispose()
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     Start-Sleep -Milliseconds 40
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo $baseline.Dispose()
>>"%PSFILE%" echo.
>>"%PSFILE%" echo if ($confirmed) {
>>"%PSFILE%" echo     Write-Host 'Icon refresh confirmed!'
>>"%PSFILE%" echo     Write-Host 'Waiting 2 seconds...'
>>"%PSFILE%" echo     Start-Sleep -Seconds 2
>>"%PSFILE%" echo } else {
>>"%PSFILE%" echo     Write-Host '20 seconds passed with no icon refresh detected. Restarting Explorer anyway.'
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Restart-Explorer
>>"%PSFILE%" echo.
>>"%PSFILE%" echo # Only when NO icon refresh was detected (monitor timed out): trigger a
>>"%PSFILE%" echo # system-wide icon refresh now that the new shell is up.
>>"%PSFILE%" echo if (-not $confirmed) {
>>"%PSFILE%" echo     Invoke-IconRefresh
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host ''
>>"%PSFILE%" echo Write-Host 'Closing in 2 seconds...'
>>"%PSFILE%" echo Start-Sleep -Seconds 2

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%PSFILE%"
set "ERR=%ERRORLEVEL%"
exit /b %ERR%