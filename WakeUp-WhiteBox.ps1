$a = 0
[int]$SecondsBetweenRetries = 4
[int]$MaxRetries = 6

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

    if (Test-Connection WhiteBox -BufferSize 16 -Count 1 -Quiet) {

        Write-Host "Responded to Test-Connection" -ForegroundColor Green

        "Checking path"
        if (Test-Path -Path \\WhiteBox\Family) {
            Write-Host "Path ready" -ForegroundColor Green

            Write-Host "Copy script section"
            $ScriptOnWhiteBoxPath =  "\\Whitebox\Family\Tim\Scripts\WakeUp-WhiteBox.ps1"
            $ScriptOnWhiteBox = Get-Item -Path $ScriptOnWhiteBoxPath
            $ScriptOnWHiteBoxLastWriteTime = $ScriptOnWhiteBox.LastWriteTimeUtc

            $ScriptLocalPath = 
            $ScriptLocal = Get-Item -Path "C:\Stuff\Run\WakeOnLan\wol-0.5.1-win32\bin\WakeUp-WhiteBox.ps1"
            $ScriptLocalLastWriteTime = $ScriptLocal.LastWriteTimeUtc

            if ($ScriptLocalLastWriteTime -and $ScriptOnWHiteBoxLastWriteTime){
                
                Write-Host "Both scripts exist"
                Write-Host ("Script on WhiteBox last write time UTC = " + ($ScriptOnWHiteBoxLastWriteTime.ToString("yyyy-MM-dd hh:mm:ss")))
                Write-Host ("Script local last write time UTC       = " + ($ScriptLocalLastWriteTime.ToString("yyyy-MM-dd hh:mm:ss")))
                if ($ScriptOnWHiteBoxLastWriteTime -eq $ScriptLocalLastWriteTime){
                    Write-Host "Scripts are same so no copying needed"
                }
                elseif ($ScriptOnWHiteBoxLastWriteTime -gt $ScriptLocalLastWriteTime){
                    Write-Host "Script on WhiteBox is newer so copying down"
                    Copy-Item -Path $ScriptOnWhiteBoxPath -Destination $ScriptLocalPath
                }
                else {
                    Write-Host "Script locally is newer so copying up"
                    Copy-Item -Path $ScriptLocalPath -Destination $ScriptOnWhiteBoxPath
                }
            }



            Break
        }
        else {
            Write-Host "Path not ready" -ForegroundColor DarkMagenta

        }
    }
    else {
        Write-Host "Did not respond to Test-Connection" -ForegroundColor DarkMagenta
        Write-Host "Sending wake up"
        C:\Stuff\Run\WakeOnLan\wol-0.5.1-win32\bin\wol.exe 00:D0:4B:96:2D:97
    }

    $a++

}
While ($a -le $MaxRetries)

"Press any key to close. Or will close automatically in 10 seconds"
$counter = 0
while (!$Host.UI.RawUI.KeyAvailable -and ($counter++ -lt 10)) {
    Start-Sleep -Seconds 1
}

