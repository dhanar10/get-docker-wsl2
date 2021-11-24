Param (
	[string]$distribution = 'Ubuntu-20.04'
)

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script

wsl -d $distribution -u root bash -c @'
(TMP_DIR=$(mktemp -d) && curl -fsSL https://get.docker.com -o $TMP_DIR/get-docker.sh && sudo sh $TMP_DIR/get-docker.sh); rm -rfv $TMP_DIR
'@

# https://stackoverflow.com/a/64073035

$wshShell = New-Object -comObject WScript.Shell
$shortcut = $wshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\wsl2-docker-$($distribution.ToLower()).lnk")
$shortcut.TargetPath = "C:\Windows\System32\wsl.exe"
$shortcut.Arguments = "-d $distribution -u root bash -c 'service docker start'"
$shortcut.WindowStyle = 7   # Minimized
$shortcut.Save()

# Start docker service immediately

wsl -d $distribution -u root bash -c 'service docker start'
