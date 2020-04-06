while ($null -ne 1) {
    $PSVersionTable.PSVersion
    test-connection -ping mssql
    test-connection mssql -tcpport 1433
    Start-Sleep -s 5
}
