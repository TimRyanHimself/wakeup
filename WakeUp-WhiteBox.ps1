
[int]$SecondsBetweenRetries = 4
[int]$MaxRetries = 6

# $MacAddress = "00:D0:4B:96:2D:97"
# $RemotePath = "\\WhiteBox\Family"
# $RemoteHostName = "WhiteBox"

$MacAddress = "AC:15:A2:58:91:E9"
$RemotePath = "\\DESKTOP-J33C9LL\Family"
$RemoteHostName = "DESKTOP-J33C9LL"


$a = 0
Do {

    Write-Host "********************"

    if ($a -gt 0) {
        Write-Host "Retry number $a. Max retries $MaxRetries"
        Write-Host "Waiting $SecondsBetweenRetries seconds"
        Start-Sleep -Seconds $SecondsBetweenRetries
    }
    else {
        Write-Host "First try"
    }

    if (Test-Connection $RemoteHostName -BufferSize 16 -Count 1 -Quiet) {

        Write-Host "Responded to Test-Connection" -ForegroundColor Green

        "Checking path"
        if (Test-Path -Path $RemotePath) {
            Write-Host "Path ready" -ForegroundColor Green
            Break
        }
        else {
            Write-Host "Path not ready" -ForegroundColor DarkMagenta

        }
    }
    else {
        Write-Host "Did not respond to Test-Connection" -ForegroundColor DarkMagenta
        Write-Host "Sending wake up"
        C:\Stuff\Run\WakeOnLan\wol-0.5.1-win32\bin\wol.exe $MacAddress
    }

    $a++

}
While ($a -le $MaxRetries)

"Press any key to close. Or will close automatically in 10 seconds"
$counter = 0
while (!$Host.UI.RawUI.KeyAvailable -and ($counter++ -lt 10)) {
    Start-Sleep -Seconds 1
}

