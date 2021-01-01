[string]$fileName = 'C:\Git\source\repos\Mine\powershelltestfiles\LEICode.csv'
[string]$output = 'C:\Git\source\repos\Mine\powershelltestfiles\LEICode_Updated.csv'
[string]$uri = 'https://leilookup.gleif.org/api/v2/leirecords?lei='

$csv = Import-Csv -Path $fileName 
$csv 

foreach ($row in $csv)
{  
    # get from gleif
    Start-Sleep -Seconds 2
    $request = -join ($uri, $row.LegalEntityCode.ToString());
    $response = Invoke-WebRequest -Uri $request
    $json = $response.Content | ConvertFrom-Json    

    # schema may include language information
    if ($null -ne $json.Entity.LegalName."@xml:lang")
    {
        $jsonName = ($json.Entity.LegalName."$" | Out-String)
    }
    else { $jsonName = ($json.Entity.LegalName | Out-String) }

    # remove the trash
    $nodollar = $jsonName.Replace("$", "")
    $nodash = $nodollar.Replace('-', '')
    $gleifName = $nodash.Trim()

    # check if it's different
    if ($gleifName -ne $row.LegalEntityName)
    {
        # update csv object
        $row.LegalEntityName = $gleifName
    }      
}
$csv

# export updated object to csv file
$csv | Export-Csv -Path $output -NoTypeInformation






