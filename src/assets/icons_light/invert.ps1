foreach ($Folder in Get-ChildItem -Path . -Filter "*.png" -Recurse) {
	magick "$Folder" -channel rgb +negate "$Folder"
}

