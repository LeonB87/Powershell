Function Get-MailboxByEmailaddress{
    param(
        [string]$emailAddress,
        [string]$DomainController
        )

    try {
        $oMailbox = get-mailbox -identity $emailAddress -ResultSize 1 -DomainController $DomainController
    }
    catch {
        return $false
    }

    return $oMailbox
}
