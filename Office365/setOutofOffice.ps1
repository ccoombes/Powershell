$user = 'csledge@ipmg.com.au'
$name = 'Chris'
$redirect = 'justin.davies@pmplimited.com.au'
$message = 'Thank you for your email, '+$name+' is no longer with the business.<br><br>Please direct your email to '+$redirect

Set-MailboxAutoReplyConfiguration -Identity $user -AutoReplyState Enabled -ExternalMessage $message -InternalMessage $message