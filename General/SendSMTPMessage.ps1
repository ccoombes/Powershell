<#
.DESCRIPTION
  Basic smtp script for for testing SMTP server connectivity
.NOTES
  Version:        1.0
  Author:         Chris Coombes
  Email:          ccoombes@outlook.com
  Creation Date:  03-02-2021
  Purpose/Change: Initial script development
#>
$content = "Random String "+$timestamp

$splat = @{
    SmtpServer = 'host' #Server host name or IP
    From = 'Display Name<test-to@mail.xyz>' #format to include display name, display name not required
    To = 'test-1@mail.xyz','test-1@mail.xyz' #can include multiple recipients
    Subject = $content
    Body = $content
}

Send-MailMessage @splat -Verbose