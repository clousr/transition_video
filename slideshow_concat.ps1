# Define the temporary video folder
$tmpVideoFolder = ".\tmpvideo"

# Define the output filename for the final video
$outputFile = ".\output-swipe.mp4"

# Get the list of intermediate videos
$videoFiles = Get-ChildItem -Path $tmpVideoFolder -File | Sort-Object Name

# Create a text file for FFmpeg concat
$concatFile = Join-Path $PSScriptRoot "concat.txt"
$concatContent = $videoFiles | ForEach-Object { "file '$($_.FullName)'" }
[System.IO.File]::WriteAllLines($concatFile, $concatContent)

# Use FFmpeg to concatenate the intermediate videos
$ffmpegCommand = "ffmpeg -f concat -safe 0 -i $concatFile -c copy $outputFile"
Invoke-Expression $ffmpegCommand

# Clean up temporary files
# Remove-Item -Path $tmpVideoFolder -Recurse -Force
# Remove-Item -Path $concatFile

Write-Host "Final video '$outputFile' created successfully."
