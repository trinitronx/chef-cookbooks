# logrotate.ps1
# This PowerShell script replicates the functionality of the logrotate utility on Linux/Unix-based systems

# Parameters
# -Path 					A valid absolute path to a log folder
# -Include				A log file to rotate or a wildcard pattern for including files
# -Rotate					The number of log files to keep
# -RestartService	The name of a service to stop and start before and after rotating the logs

# Example
# .\logrotate.ps1 -Path 'C:\Logs' -Include '*.log' -Rotate 7

# Get command line parameters
Param (
	[string]$Path,
	[string]$Include,
	[int]$Rotate = 10,
	[string]$RestartService
)

# Remove any trailing slashes from the path
$Path = $Path.TrimEnd('\');

# Make sure the path exists
if ((Test-Path -Path $Path -PathType container) -ne $True) {
	Write-Host "The log folder path specified does not exist."
}
else {
	# Stop a service if requested
	if ($RestartService) {
		Stop-Service $RestartService
	}

	Write-Host "Rotating logs in $($Path)..."
	$count = 0

	# Find matching log files in the specified path 
	$MatchingFiles = Get-ChildItem "$($Path)\*" -Include:$Include

	foreach ($f in $MatchingFiles) {
		# Make sure the file exists
		if (($f.FullName) -and (Test-Path $f.FullName)) {
			$pattern = "$($f.Name).*"

			# Delete old log files
			if (Test-Path "$($f.FullName).$Rotate") {
				Remove-Item "$($f.FullName).$Rotate" -Force
			}

			# Rotate the newer log files
			for ($i = $Rotate; $i -ge 1; $i--) {
				if ($i -eq 1) {
					Rename-Item -Path $f.FullName -NewName "$($f.Name).$i"
				}
				else {
					if (Test-Path "$($f.FullName).$($i-1)") {
						Rename-Item -Path "$($f.FullName).$($i-1)" -NewName "$($f.Name).$i"
					}
				}
			}

			$count++
		}
	}
	Write-Host "$count log file(s) were rotated in the specified directory."

	# Start a service if requested
	if ($RestartService) {
		Start-Service $RestartService
	}
}