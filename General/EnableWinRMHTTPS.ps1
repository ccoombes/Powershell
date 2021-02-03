<#
.DESCRIPTION
  Enable WinRM over HTTPS with a self signed certificate.
  Used for Ansible testing on Windows
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  03-02-2021
  Purpose/Change: Initial script development
#>

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