################################################################################################################################
#                                                                                                                              #
#  Author - Brian G                                                                                                            #
#  Script Type - Powershell                                                                                                    #
#  Purpose -  Compare Active Directory Domain Administrator group membership between two points in time.                       #
#  Assumptions:                                                                                                                #
#  A previous membership list exists for this script to compare against.                                                       #
#     If one does not exist already, create a new baseline list by running the 1st 4 commands in this script interactively.    #
#  You are running this script on a computer that is a member of the domain you are querying.                                  #
#                                                                                                                              #
#  File Version 0.1                                                                                                            #
################################################################################################################################

# Define Working Directory
$WORKDIR = "D:\AdminScripts\domainAdminsMonthly"

# Change to Working Directory
cd $WORKDIR

# Import Active Directory Module for Powershell
import-module activedirectory

# Get list of members in the Domain Admins group, and put it into a file for todays processing.
get-adgroupmember "domain admins" | findstr "name" | sort | out-file "$WORKDIR\Dadmins.now"

# Make a comparison between the existing list of Domain Admin Group Members.
$COMPARE = compare-object -ReferenceObject (Get-Content $WORKDIR\Dadmins.last) -differenceobject (get-content $WORKDIR\Dadmins.now)

# Create report file depending on whether the membership list has changed from the last time this script was run.
if ($COMPARE) {
echo "The following users have been ADDED since the last check:`n`r`n`r" | out-file $WORKDIR\CheckResults.txt
foreach ($user in $COMPARE) {echo $USER | findstr "name" | findstr "=>" | out-file  $WORKDIR\CheckResults.txt -Append}
echo "`n`r`n`rThe following users have been REMOVED since the last check: `n`r`n`r" | out-file  $WORKDIR\CheckResults.txt -Append
foreach ($user in $COMPARE) {echo $USER | findstr "name" | findstr "<=" | out-file  $WORKDIR\CheckResults.txt -Append}
}
else
{
echo "There are no differences to the Domain Admins Group Membership since the last time the check was done" | Out-file "$WORKDIR\CheckResults.txt"
}
 

# Archive the list from todays processing.
copy-item "Dadmins.now" "Dadmins.$(get-date -f yyyy-MM-dd).txt" 

# Make the list from todays processing into the file we will compare to on the next check.
copy-item -Force -Path "Dadmins.now" "Dadmins.last"

# Remove the original file from todays processing.
remove-item -path "Dadmins.now"

# Archive the report file with the date appended.
rename-item -Path "$WORKDIR\CheckResults.txt" -NewName "$WORKDIR\CheckResults.$(get-date -f yyyy-MM-dd).txt"





