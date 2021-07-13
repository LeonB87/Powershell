

function check-mycustommodule {
    param(
        [Parameter(Mandatory = $false)][string]$message = "This seems to work!"
    )
    BEGIN {
        Write-Host ($message)
    }
    PROCESS {
        $message = ("The input we've received is: $($message)")
    }
    END {
        return $message
    }
}

function Get-ModuleReply {
    Write-Host ("Module is called")
    return ("Hi there")
}

Export-ModuleMember -Function "Get-ModuleReply","check-mycustommodule"