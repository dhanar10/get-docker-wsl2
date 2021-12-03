Param (
	[string]$distribution = 'Ubuntu-20.04'
)

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script

wsl -d $distribution -u root bash -c @'
(TMP_DIR=$(mktemp -d) && curl -fsSL https://get.docker.com -o $TMP_DIR/get-docker.sh && sudo sh $TMP_DIR/get-docker.sh); rm -rfv $TMP_DIR
'@

# Configure Docker remote API so that Windows Docker CLI can access it

wsl -d $distribution -u root bash -c 'cp -n /etc/default/docker /etc/default/docker.orig'
wsl -d $distribution -u root bash -c 'echo DOCKER_OPTS=\"-H unix:///var/run/docker.sock -H tcp://127.0.0.1:\" > /etc/default/docker'

# Start Docker service immediately

wsl -d $distribution -u root bash -c 'service docker start'

# Configure start Docker service on Windows startup https://stackoverflow.com/a/64073035

$wshShell = New-Object -comObject WScript.Shell
$shortcut = $wshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\wsl2-docker-$($distribution.ToLower()).lnk")
$shortcut.TargetPath = "C:\Windows\System32\wsl.exe"
$shortcut.Arguments = "-d $distribution -u root bash -c 'service docker start'"
$shortcut.WindowStyle = 7   # Minimized
$shortcut.Save()

# Install and configure Windows Docker CLI

Invoke-WebRequest "https://download.docker.com/win/static/stable/x86_64/docker-$(wsl -d $distribution bash -c "docker -v | grep -o '[0-9\.]\+' | head -n 1").zip" -OutFile docker.zip
Expand-Archive .\docker.zip C:\
rm .\docker.zip

$userPaths = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User) -split ';'
if ($userPaths -notcontains "C:\docker") {
    $userPaths = $userPaths + "C:\docker" | where { $_ }
    [Environment]::SetEnvironmentVariable('Path', $userPaths -join ';', $containerType)
}
[Environment]::SetEnvironmentVariable("DOCKER_HOST", "tcp://127.0.0.1:2375", [EnvironmentVariableTarget]::User)
