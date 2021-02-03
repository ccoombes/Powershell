#setup host to use HTTPS remoting with selfsigned cert

$hostname = "xxxxx"

#generate new selfsigned cert        
$cert = New-SelfSignedCertificate -DnsName $hostname -Subject $hostname -CertStoreLocation "cert:\LocalMachine\My"
        
#winrm paramamters
$valueset = @{
    CertificateThumbprint = $cert.Thumbprint
    Hostname = $hostname
}

$selectorset = @{
    Address = "*"
    Transport = "HTTPS"
}

# Add new Listener with new SSL cert
New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset

# create firewall rule - Windows Remote Management (HTTPS-In) TCP 5986

$newRuleParams = @{
    DisplayName   = 'Windows Remote Management (HTTPS-In)'
    Direction     = 'Inbound'
    LocalPort     = 5986
    RemoteAddress = 'Any'
    Protocol      = 'TCP'
    Action        = 'Allow'
    Enabled       = 'True'
    Group         = 'Windows Remote Management'
}

New-NetFirewallRule @newRuleParams