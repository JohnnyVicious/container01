while ($null -ne 1) {
    $PSVersionTable.PSVersion
    ping mssql
    test-netconnection mssql 1433
    Start-Sleep -s 5
}
