
Import-Module ActiveDirectory

$numusers = 3
$numgroups = 100

$OU = 'OU=Vera Performance Test2 - NonNested,DC=corp,DC=veraqa,DC=com'
$OUFile = ".\ADOrganizationalUnits.csv"
$OUFileObject = Import-Csv $OUFile

#DELETE OU - Read the below 3 lines of code before enabling


<#Get-ADOrganizationalUnit -Identity $OU `
| Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru `
| Remove-ADOrganizationalUnit -Confirm:$false -Recursive#>


# CREATE OU

Get-Content OUStructure.txt | Foreach-Object {
  $alleOU = ''
  $ous = (Split-Path $_ -Parent).Split('\')
  [array]::Reverse($ous)
  $ous | Foreach-Object {
    if ($_.Length -eq 0) {
      return
    }
    $alleOU = $alleOU + 'OU=' + $_ + ','
  }
  $alleOU += $OU
  $nyOUNavn = Split-Path $_ -Leaf
  
  Write-Output ("################################################################################################################")
  Write-Output ($alleOU)
  Write-Output ($nyOUNavn)
  New-ADOrganizationalUnit -Name "$nyOUNavn" -Path "$alleOU" -ProtectedFromAccidentalDeletion $false
  Write-Output ("################################################################################################################")
  #Start-Sleep 1

}

# PAUSE for sometime to wait for OU creation

Start-Sleep 120

# EXPORT OU List

Get-ADOrganizationalUnit -SearchBase $OU -SearchScope Subtree -Filter * | Select-Object DistinguishedName,Name `
| Export-csv -path $OUFile -NoTypeInformation


#DELETE CSV FILES

Get-ChildItem -Path “.\users\” *.csv | Remove-Item -force
Get-ChildItem -Path “.\groups\” *.csv | Remove-Item -force

#CREATE USERS IN OU

ForEach ($OU in $OUFileObject){
#For ($i=0; $i -le 0; $i++) {
    $filepath = ".\users\" + $OU.Name + ".csv"
    "username" | Out-File -FilePath $filepath -Encoding ASCII
    $result = -join ((48..57) + (97..122) | Get-Random -Count 5 | % {[char]$_})
    #Write-Host $result

    For ($i=1; $i -le $numusers; $i++) {

        $username = "user_" + $result + "_"
        New-ADUser -Name $username$i -UserPrincipalName $username$i@corp.veraqa.com `
        -SamAccountName $username$i -GivenName 'Vera' -SurName 'Performance' -DisplayName 'Vera Perf' `
        -Path $OU.DistinguishedName -AccountPassword (ConvertTo-SecureString -AsPlainText -Force -String "Test@1234") `
        -PasswordNeverExpires 1 -EmailAddress $username$i@veraqa.com -Enabled $True
        
        #Write-Host $username$i
        "$username$i" | Out-File -FilePath $filepath -Append -Encoding ASCII
    }
}


# CREATE GROUPS IN OU

ForEach ($OU in $OUFileObject){
#For ($i=0; $i -le 0; $i++) {
    $filepath = ".\groups\" + $OU.Name + ".csv"
    "groupname" | Out-File -FilePath $filepath -Encoding ASCII
    $result = -join ((48..57) + (97..122) | Get-Random -Count 5 | % {[char]$_})
    #Write-Host $result

    For ($i=1; $i -le $numgroups; $i++) {

        $groupname = "group_" + $result + "_"
        New-ADGroup -Name $groupname$i -Path $OU.DistinguishedName -Description "New Groups Created in Bulk" -OtherAttributes @{'mail'="$groupname$i@veraqa.com"} `
        -GroupCategory Distribution -GroupScope Global -Managedby administrator
        
        #Start-Sleep -Milliseconds 200
        #Write-Host $groupname$i
        "$groupname$i" | Out-File -FilePath $filepath -Append -Encoding ASCII
    }

}


# ADD USERS TO GROUP

$files = get-childitem .\groups\*.csv
foreach ( $file in $files )
{
    #Write-Host $file
    #Get-Content $_.FullName
    $GroupList = import-csv $file
    foreach ($group in $GroupList) {
        $userfile = $file -replace "groups", "users"
        $UserList = import-csv $userfile
        foreach ($user in $UserList) {
        #For ($i=0; $i -le 2; $i++) {
            Add-ADGroupMember -Identity $group.groupname -Member $user.username
            #Start-Sleep -Milliseconds 200
        }

    }
}

# ADD GROUP TO GROUP - Yet To Implement

#$GroupList = Import-Csv ".\ad_new_group_created.csv"
#$UserList = Import-Csv ".\ad_new_group_created.csv"

#foreach ($group in $GroupList) {
#For ($i=0; $i -le 0; $i++) {
#    For ($i=0; $i -le 0; $i++) {
#    foreach ($user in $UserList) {
#        Add-ADGroupMember -Identity $group.groupname -Member $user.groupname
#    }
#}


##### REFERENCE CODE #######

#1..1 | % { New-ADUser $username$_ -Path $OU.Path -AccountPassword (ConvertTo-SecureString -AsPlainText -Force -String "Test@1234")`
# -EmailAddress $username$_@veraqa.com -Enabled $True ; "$username$_" | Out-File -FilePath ad_new_user_created.csv -Append -Encoding ASCII}


#import-csv .\ad_ou.csv | New-ADOrganizationalUnit –PassThru