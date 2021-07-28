

function check-mycustommodule {
    param(
        [Parameter(Mandatory = $false)][string]$message = "This seems to work!"
    )
    BEGIN {
        Write-Host ($message)
    }
    PROCESS {

    }
    END {
        return $message
    }
}

Export-ModuleMember -Function "get-*"