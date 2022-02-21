

function check-mycustommodule {
    param(
        [Parameter(Mandatory = $false)][string]$message = "This seems to work!",

        [Parameter(Mandatory = $false)]
        [string]$fromEnvironmentVariable = $env:APIurl
    )
    BEGIN {
        Write-Host ($message)

        Write-Information ("I have the value '$($fromEnvironmentVariable)' inside the variable 'fromEnvironmentVariable'")
    }
    PROCESS {

    }
    END {
        return $message
    }
}

function Get-SchemaValidationResult {
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [hashtable]$Body,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$SchemaFile

    )

    BEGIN {
        Write-Information ('Checking the validation status of the request')
    }
    PROCESS {
        $jsonBody = ConvertTo-Json $Body -Depth 100
        $schema = Get-Content $SchemaFile -Raw

        $validation = Test-Json -Json $jsonBody -Schema $schema

        return $validation
    }
    END {
        Write-Information ('Completed checking the validation status of the request')
    }
}




Export-ModuleMember -Function "get-*",'check-mycustommodule'