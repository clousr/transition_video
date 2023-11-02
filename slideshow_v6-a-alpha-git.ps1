# Define the input folder containing image files (PNG and JPEG)
$inputFolder = ".\photos" #1024x1024 or square, will work with others but need to adjust ffmpegCommand

# Define the temporary video folder
$tmpVideoFolder = ".\tmpvideo"

# Define the total duration for each image in the video (in seconds)
$imageDuration = 2

# Define the transition duration as a percentage of the total image duration
$transitionPercentage = 0.001

# Calculate the actual transition duration in seconds
$transitionDuration = $imageDuration * $transitionPercentage

# Ensure the temporary video folder exists
if (-not (Test-Path $tmpVideoFolder)) {
    New-Item -Path $tmpVideoFolder -ItemType Directory
}

# Get the list of image files
$imageFiles = Get-ChildItem -Path $inputFolder -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg)' } | Sort-Object Name

# Create intermediate videos with transitions
for ($i=0; $i -lt $imageFiles.Count - 1; $i++) {
    $firstImage = $imageFiles[$i].FullName
    $secondImage = $imageFiles[$i+1].FullName
    $outputVideo = Join-Path $tmpVideoFolder ("{0:D6}.mp4" -f ($i + 1))

    $offset = $imageDuration - $transitionDuration
    $ffmpegCommand = "ffmpeg -loop 1 -t $imageDuration -framerate 60 -i `"$firstImage`" -loop 1 -t $imageDuration -framerate 60 -i `"$secondImage`" -filter_complex ""[0:v]scale=1024:1024[scaled0];[1:v]scale=1024:1024[scaled1];[scaled0][scaled1]xfade=transition=slideleft:duration$transitionDuration:offset=$offset[out]"" -map ""[out]"" -c:v vp9 -crf 17 -pix_fmt yuva420p -r 60 -n `"$outputVideo`""
    Invoke-Expression $ffmpegCommand
}

Write-Host "Intermediate videos created in '$tmpVideoFolder'."
