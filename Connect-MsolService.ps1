
##Requirements$Users = (Get-MsolUser | where-Object {$_.ImmutableId -eq $null})
Write-Output "This Script requires MSOnline & ActiveDirectory Modules"
$confirmation = Read-Host "Are you Sure You Want To Proceed (Y)?"

if ($confirmation -ne 'Y') {
  exit 1
}

Connect-MsolService
#LG: Gets our user list, where ImmutableID is not set
$Users = (Get-MsolUser | where-Object {$_.ImmutableId -eq $null})
 
#Gather domain variables
$Dom = Get-ADDomain
 
#Establish random password length
[Reflection.Assembly]::LoadWithPartialName(“System.Web”)
$RandPassLength = [int] 16
 
#Specify which OU the accounts should be created in
#Replace 'User Accounts' with the name of the OU that should be used.
$OU = 'OU=User Accounts,' + $Dom.DistinguishedName
 
$Users | Foreach {
   
    #Generate a unique, randomized password for each user
    $RandomPassword = [System.Web.Security.Membership]::GeneratePassword($RandPassLength, 2)
      $setpass = ConvertTo-SecureString -AsPlainText $RandomPassword -force
 
    #Generate a new SamAccountName
    $SamAccountName = $_.FirstName + '.' + $_.LastName
 
    #Generate a new Name
    $Name = $_.FirstName + ' ' + $_.LastName
 
    #Create new on premises user for existing, enabled cloud user
    New-ADUser $Name `
          -AccountPassword $SetPass `
             -ChangePasswordAtLogon $False `
            -SamAccountName $SamAccountName `
        -DisplayName $Name `
        -GivenName $_.FirstName `
        -Surname $_.LastName `
             -UserPrincipalName $_.UserPrincipalName `
             -Path $OU `
      
    }