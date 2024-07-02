foreach ($file in Get-ChildItem -Path .\icons_dark -Filter "*.png" -Recurse) {
	$newFilePath = $file -replace ".*icons_dark\\", ""
	$newFilePath = "$(Get-Location)\icons_light\$newFilePath"
	$newFileDir = Split-Path -Parent "$newFilePath"
	if (!(Test-Path $newFileDir)) {
		New-Item -Path "$newFileDir" -ItemType "directory"
	}
	magick "$file" -colorspace lab -channel 0 -negate +channel -colorspace sRGB "$newFilePath"
	Write-Output "Converted`n`t$file`n`t$newFilePath"
}
