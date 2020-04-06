try {
    if (!($PSVersionTable.PSVersion.Major -ge 7 -or ($PSVersionTable.PSVersion.Major -eq 6 -and $PSVersionTable.PSVersion.Minor -ge 2))) { 
        Write-Error "You need at least PowerShell 6.2 to run this script!"; throw    
    }
    else { Write-Output "PowerShell version $($PSVersionTable.PSVersion) detected." }

    if ($null -eq (Get-InstalledModule sqlserver -ErrorAction SilentlyContinue)) {
        Write-Output "Installing PS module SqlServer"
        Install-Module -Name SqlServer -Scope CurrentUser -Force    
        Import-Module SqlServer
        Write-Host "PowerShell SqlServer module $((get-module sqlserver).Version) is installed."
    }
    else {
        Update-Module SqlServer    
        Import-Module SqlServer
        Write-Host "PowerShell SqlServer module $((get-module sqlserver).Version) is installed."
    }


    if ((get-installedmodule sqlserver).Version) {
        if ($mssql = Get-Item Env:MSSQL -ErrorAction SilentlyContinue) {
            $mssql = $mssql.Value
            $mssqlport = (Get-Item Env:MSSQLPORT -ErrorAction SilentlyContinue).Value
            $mssqluser = 'github_r'
            $mssqlpass = 'reader'
            if (test-connection $mssql -tcpport $mssqlport -ErrorAction SilentlyContinue) {
                Write-Output "Connected to MSSQL, getting Github data..."                
                $githubdata = Invoke-SqlCmd -ServerInstance "$mssql" -Username $mssqluser -Password $mssqlpass -Query "SELECT * FROM github"                
            }
            else { Write-Error "Unable to connect to $mssql on TCP $mssqlport!"; throw }
        }
        else { Write-Error "MSSQL server not set as environment variable!"; throw }
    }
    else { Write-Error "PS module SqlServer is not installed!"; throw }

    # UPDATING
    if($githubdata){
        $githubuser = $githubdata.GITHUB_USER
        $githubtoken = $githubdata.GITHUB_TOKEN
        $githuburl = $githubdata.GITHUB_REPO
        $githubproject = $githubdata.GITHUB_PROJ
        $githubrepo = "https://$($githubuser):$($githubtoken)@$($githuburl)$($githubproject).git"
        "https://$($githubuser):$($githubtoken)@$($githuburl)$($githubproject).git"
        
        # Return to Home folder
        if((Get-Location).Path -match 'container'){ cd.. }
        if((Get-Location).Path -match $githubproject){ cd.. }
        Write-Output "Path is $((Get-Location).Path)"

        if((Get-Location | Get-ChildItem -Directory).Name -contains $githubproject){
            Write-Output "Git clone already done"
            cd $githubproject
            git pull $githubrepo

        } else {                    
            Write-Output "Git clone for the first time..."
            git clone $githubrepo
            git config --global user.email "you@example.com"
            git config --global user.name "Your Name"
        }

        if (Get-Item Env:DEMO -ErrorAction SilentlyContinue) {
            # If DEMO env exists, dev branch will be merged
            Write-Output "DEMO varibale set, merging dev branch"
            if((Get-Location | Get-ChildItem -Directory).Name -contains $githubproject){ cd $githubproject }
            git fetch $githubrepo dev
            git merge origin/dev
            git commit
        }
        
    } else { Write-Error "Github data not loaded!"; throw }
}
catch {
    $seconds = Get-Random -Minimum 60 -Maximum 300
    $Error
    $Error.Clear()
    Write-Output "Something went wrong, waiting $seconds before restarting..."
    Start-Sleep -Seconds $seconds
    Exit
}
