# copy_fileshare.ps1
# This PowerShell script copies a file or files matching a pattern to a network share

# Parameters
# -FromPath			A valid absolute path to the folder containing the file(s) to copy
# -Include			A filename or wildcard pattern for including files
# -ToPath				The destination path to copy to
# -AddTimestamp	(Optional) Append a timestamp to the destination filename(s)
# -Username			(Optional) Copy the file as the given user
# -Password			(Optional) The password for the specified user

# Example
# .\copy_fileshare.ps1 -FromPath:'C:\Files' -Include:'*.txt' -ToPath \\server\share

# Get command line parameters
Param (
	[string]$FromPath,
	[string]$Include,
	[string]$ToPath,
	[switch]$AddTimestamp,
	[string]$Username,
	[string]$Password
)

# Remove any trailing slashes from the paths
$FromPath = $FromPath.TrimEnd('\');
$ToPath = $ToPath.TrimEnd('\');

# Make sure the source path exists
if ((Test-Path -Path $FromPath -PathType container) -ne $True) {
	Write-Host "The source folder specified does not exist."
}
else {
  # Count the files that are copied
	$count = 0

	# Find matching file(s) in the specified source path
	$MatchingFiles = Get-ChildItem "$($FromPath)\*" -Include:$Include

	foreach ($f in $MatchingFiles) {
		# Add a timestamp to the destination filename if specified
		if ($AddTimestamp) {
			$DestinationFile = "$($f.Basename)_$(Get-Date -Format "MM-dd-yyyy_HHmm")$($f.Extension)"
		}
		else {
			$DestinationFile = $f.Name
		}
    $DestinationFile = "$ToPath\$DestinationFile"

		# If authentication parameters were passed, authenticate against the network
		if ($Username) {
			net use $ToPath $Password /USER:$Username
		}

		# Copy the file
		Copy-Item $f.FullName $DestinationFile
		$count++
	}
	Write-Host "$count files copied to the specified destination."
}