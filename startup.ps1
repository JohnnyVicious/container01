try {
    if (!($PSVersionTable.PSVersion.Major -ge 7 -or ($PSVersionTable.PSVersion.Major -eq 6 -and $PSVersionTable.PSVersion.Minor -ge 2))) { 
        Write-Error "You need at least PowerShell 6.2 to run this script!"; throw    
    }
    else { Write-Output "PowerShell version $($PSVersionTable.PSVersion) detected." }

if ($sqler = Get-Item Env:SQLER -ErrorAction SilentlyContinue) {
        $sqler = $sqler.Value
        $sqlerport = (Get-Item Env:SQLERPORT -ErrorAction SilentlyContinue).Value
        if (test-connection $sqler -tcpport $sqlerport -ErrorAction SilentlyContinue) {
            Write-Output "Connected to SQLer, getting Github data..."                
            #$githubdata = Invoke-SqlCmd -ServerInstance "$mssql" -Username $mssqluser -Password $mssqlpass -Query "SELECT * FROM github WHERE GITHUB_PROJ='TradeBot'"
            $requestdata = [ordered]@{                    
                projectname = "TradeBot"
            }
            [string]$mydata = "$(ConvertTo-Json $requestdata -Compress -Verbose:$false)"
            $result = Invoke-RestMethod -Uri "http://$($SQLER):$($SQLERPORT)/getgithubuser" -Method 'POST' -Body $mydata -ContentType "application/json"
            $githubdata = $result.data
        }
        else { Write-Error "Unable to connect to $sqler on TCP $sqlerport!"; throw }
    }
    else { Write-Error "SQLer server not set as environment variable!"; throw }


    # UPDATING
    if ($githubdata) {
        if (Get-Item Env:DEMO -ErrorAction SilentlyContinue) { $demo = $true } else { $demo = $false }
        if (Get-Item Env:PUSH -ErrorAction SilentlyContinue) { $push = $true } else { $push = $false }
        $githubuser = $githubdata.GITHUB_USER
        $githubtoken = $githubdata.GITHUB_TOKEN
        $githuburl = $githubdata.GITHUB_REPO
        $githubproject = $githubdata.GITHUB_PROJ
        $githubrepo = "https://$($githubuser):$($githubtoken)@$($githuburl)$($githubproject).git"
        "https://$($githubuser):$($githubtoken)@$($githuburl)$($githubproject).git"
        
        # Return to Home folder
        if ((Get-Location).Path -match 'container') { cd.. }
        if ((Get-Location).Path -match $githubproject) { cd.. }
        Write-Output "Path is $((Get-Location).Path)"

        if ((Get-Location | Get-ChildItem -Directory).Name -contains $githubproject) {
            Write-Output "Git clone already done, checking for updates"
            cd $githubproject      

            if ($PUSH) {                                  
                # If pushing from local source is enabled
                if ($demo) {
                    # dev branch
                    Write-Output "(Running on DEV branch)"
                    git checkout dev  
                    #git fetch $githubrepo dev     
                }
                else {
                    # master branch
                    git checkout master        
                    #git fetch $githubrepo master
                }

                Write-Output "Performing GIT PUSH..."
                git add .
                git commit -m "$(Get-Date -Format "yyyyMMdd HH:mm")"
                git push $githubrepo
            } else {                
                if ($demo) { 
                    Write-Output "Checking for updates on DEV branch..."
                    git checkout dev
                    git pull $githubrepo dev
                } else {
                    Write-Output "Checking for updates..."
                    git checkout master
                    git pull $githubrepo master
                }                
            }
        }
        else {                    
            Write-Output "Git clone for the first time..."
            git clone $githubrepo
            cd $githubproject
            git config --global user.email "you@example.com"
            git config --global user.name "PowerShell Script"            
            if ($demo) { git checkout dev }
        }
        
    }
    else { Write-Error "Github data not loaded!"; throw }

    # Launch MAIN program
    Write-Output "Checking for MAIN program in $((Get-Location).Path)"
    if((Get-ChildItem -File).Name -contains 'main.ps1'){
        Write-Output "Main.ps1 found in $((Get-Location).Path)."
    } else {
        Write-Error "No main.ps1 found in $((Get-Location).Path)!"; throw
    }
}
catch {
    $seconds = Get-Random -Minimum 60 -Maximum 300
    $Error
    $Error.Clear()
    Write-Output "Something went wrong, waiting $seconds before restarting..."
    Start-Sleep -Seconds $seconds
    Exit
}
