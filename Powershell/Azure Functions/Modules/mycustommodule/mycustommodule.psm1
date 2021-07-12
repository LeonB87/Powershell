

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

    }
}

Export-ModuleMember -Function get-*