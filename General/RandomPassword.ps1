# Generate a 20 character long random password, with at least 3 non-alphanumeric characters
$Password = [System.Web.Security.Membership]::GeneratePassword(64, 1)
Write-Output $Password