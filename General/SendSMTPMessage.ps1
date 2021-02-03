#Basic smtp script for for testing SMTP

$content = "Random String "+$timestamp

$splat = @{
    SmtpServer = 'host' #Server host name or IP
    From = 'Display Name<test-to@mail.xyz>' #format to include display name, display name not required
    To = 'test-1@mail.xyz','test-1@mail.xyz' #can include multiple recipients
    Subject = $content
    Body = $content
}

Send-MailMessage @splat -Verbose