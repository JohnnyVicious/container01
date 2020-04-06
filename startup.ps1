if (!($PSVersionTable.PSVersion.Major -ge 7 -or ($PSVersionTable.PSVersion.Major -eq 6 -and $PSVersionTable.PSVersion.Minor -ge 2))) { 
    Write-Error "You need at least PowerShell 6.2 to run this script!"
    Exit 
}
else { Write-Output "PowerShell version $($PSVersionTable.PSVersion) detected." }

if ($null -eq (Get-InstalledModule sqlserver)) {
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

try {
    if ((get-installedmodule sqlserver).Version) {
        if ($mssql = Get-Item Env:MSSQL -ErrorAction SilentlyContinue) {
            $mssql = $mssql.Value
            $mssqlport = (Get-Item Env:MSSQL -ErrorAction SilentlyContinue).Value
            if (test-connection $mssql -tcpport $mssqlport -ErrorAction SilentlyContinue) {
                Write-Output "Connected to MSSQL, getting Github data..."
                Invoke-SqlCmd 
            }
            else { Write-Error "Unable to connect to $mssql on TCP $mssqlport!"; throw }
        }
        else { Write-Error "MSSQL server not set as environment variable!"; throw }
    } else { Write-Error "PS module SqlServer is not installed!"; throw }
}
catch {
    $seconds = Get-Random -Minimum 60 -Maximum 300
    Write-Output "Something went wrong, waiting $seconds before restarting..."
    Start-Sleep -Seconds $seconds
    Exit
}
