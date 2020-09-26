#
# Author: DJ Kemmet
# Purpose: see readme
# Date: 9/22/20
#

# Try to import SQLITE if you get an error write it to sqlite_import_error, SEWPER LAZY catch.
import-module PSSQLite -ErrorVariable $sqlite_import_error

# If you got an error message, install PSSQLite...
if($sqlite_import_error){

    # Install PSSQLite
    Install-Module -Name PSSQLite -Force
}

# Check for this module's database
Switch (Test-Path -Path '~\.diagtastic'){

    #If the directory exists
    $true{

        # Set the database location throughout the script so every function can work from it. 
        $global:database = '~\.diagtastic\db.sqlite'

        # keep going don't do anything.
        continue
    }

    # if the directory does not exist
    $false{

        # Create directory for script data in user's profile
        New-Item -ItemType Directory -Path ~\.diagtastic

        # Setup database
        $database = '~\.diagtastic\db.sqlite'
        
        $create_angles_table = 'CREATE TABLE "angle" ("angle_name"	TEXT UNIQUE)'

        Invoke-SqliteQuery -Database $database -Query $create_angles_table
        
    }
}

#
# Start cmdlet definitions
#

function New-Incident {
    <#
        .DESCRIPTION
        Use this funciton to create a new research log for a given incident.

        .EXAMPLE
        New-Incident -Name My_incident

        .EXAMPLE
        New-Incident -Name MyIncident
    #>



    # Define the parameters of this function in a param block.
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][String[]]$Name
    )
    $query = "
    CREATE TABLE '$($Name)' (
	'date_logged'	TEXT UNIQUE,
	'date_occured'	TEXT,
	'incident_angle'	TEXT,
	'entry_source'	TEXT,
	'entry_notes'	TEXT
)"

    # Create the table to track this incident's troubleshooting
    Invoke-SqliteQuery -Database $database -Query $query

    # Create initial entry signifying when troubleshooting started.
    $initial_incident_entry = "INSERT INTO '$($Name)' ('date_logged', 'incident_angle', 'entry_source', 'entry_notes') VALUES ('$(Get-Date)', 'Initial', 'Diagtastic', 'Started researching the problem.')"
    Invoke-SqliteQuery -Database $database -Query $initial_incident_entry

}

function Update-Incident {
    <#
        .DESCRIPTION
        Use this command to update your research time line

        .EXAMPLE
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String]$Incident,
        [Parameter(Mandatory=$false)][String]$Occurred,
        [Parameter(Mandatory=$true)][String]$Angle, 
        [Parameter(Mandatory=$true)][String]$Source, 
        [Parameter(Mandatory=$true)][String]$Notes
    )

    $update_incident_table = "INSERT INTO '$($Incident)' ('date_logged', 'date_occured', 'incident_angle', 'entry_source', 'entry_notes') VALUES ('$(Get-Date)', '$($Occurred)', '$($Angle)', '$($Source)', '$($Notes)')"

    Invoke-SqliteQuery -Database $database -Query $update_incident_table
}

#TODO
function Remove-Incident {
    <#
        .DESCRIPTION
        Use this function to remove incidents from your console.

        .EXAMPLE
        Remove-Incident -Name MyIncident

        .EXAMPLE
        Remove-Incident -name "My Incident"
    #>
    param (
        [Parameter(Mandatory=$true)][String]$Name
    )



}

function Export-Incident {
    <#
        .DESCRIPTION
        Use this function to export a troubleshooting timeline out of your console.

        .EXAMPLE
        Export-Incident -Name MyIncident
    
        .EXAMPLE
        Export-Incident

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][String]$Name,
        [Parameter(Mandatory=$false)][String]$Path
    )

    # If there was no incident name supplied, go ahead and walk the user through the export.
    if(!$Name){
        
        # Get all incident names
        $list_of_all_incidents = Invoke-SqliteQuery -database $database -Query "SELECT name FROM sqlite_master WHERE type='table';"

        # Get the incident the user wants to export
        $incident_selection = $incident_selection = Read-Host "Using base 0, select the incident you want to export" $($list_of_all_incidents | ForEach-Object -Process {Write-Host $_.name})

        # Format a query to get all the rows from the table in the database the incident research is stored in
        $query = "SELECT * FROM '$($list_of_all_incidents[$incident_selection].name)'"

        # Now lets move on to exporting those incidents. Lets start by checking to see if the user supplied a path...
        switch($Path){

            # OPTION 1: If the path variable is empty ie. not defined...
            (""){
                
                # Now actually query the database for rows and export them to a CSV where the user specified.
                $File_name = 'Incident' + ($File_name = $(Get-Date -Format "MM/dd/yyyy").replace('/','-').replace(' ', '').toString()) + '.csv'
                Invoke-SqliteQuery -database $database -Query $query | Export-Csv -Path ~\Desktop\$File_name

                # Interestingly enough, it looks like the switch keeps evaluating so for speed's sake, lets skip the rest of the switch.
                continue
            }

            # OPTION 2: if the user did specify a path, use that for the export.
            ($Path){
                $File_name = 'Incident' + ($File_name = $(Get-Date -Format "MM/dd/yyyy").replace('/','-').replace(' ', '').toString()) + '.csv'
                Invoke-SqliteQuery -database $database -query $query | Export-CSV -Path ($Path +  '/' + $File_name)

                # Interestingly enough, it look slike the switch keeps evaluating so for speed's sake, lets skip the rest of the swith.
                continue
            }
        }

        # Now that the incident has been exported, Give the user a message to let them know the task is done. 
        Write-Host "Your incident has been exported."   
    }

    # Otherwise, a name was provided so export that incident.
    else{

        # Format a query to get all the rows from the table in the database the incident research is stored in
        $query = "SELECT * FROM '$($Name)'"

        # Now lets move on to exporting those incidents. Lets start by checking to see if the user supplied a path...
        switch($Path){

            # OPTION 1: If the path variable is empty ie. not defined...
            (""){
                
                # Now actually query the database for rows and export them to a CSV where the user specified.
                $File_name = 'Incident' + ($File_name = $(Get-Date -Format "MM/dd/yyyy").replace('/','-').replace(' ', '').toString()) + '.csv'
                Invoke-SqliteQuery -database $database -Query $query | Export-Csv -Path ~\Desktop\$File_name

                # Interestingly enough, it looks like the switch keeps evaluating so for speed's sake, lets skip the rest of the switch.
                continue
            }

            # OPTION 2: if the user did specify a path, use that for the export.
            ($Path){
                $File_name = 'Incident' + ($File_name = $(Get-Date -Format "MM/dd/yyyy").replace('/','-').replace(' ', '').toString()) + '.csv'
                Invoke-SqliteQuery -database $database -query $query | Export-CSV -Path ($Path +  '/' + $File_name)

                # Interestingly enough, it look slike the switch keeps evaluating so for speed's sake, lets skip the rest of the swith.
                continue
            }
        }

        # Now that the incident has been exported, Give the user a message to let them know the task is done. 
        Write-Host "Your incident has been exported."   
    }
}

function Import-Incident {
    <#
        .DESCRIPTION
        Use this function to import a troubleshooting timeline into your console

        .EXAMPLE
        Import-Incident -Path C:\Users\dj\Downloads\myincident.csv

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)][String]$Name,
        [Parameter(mandatory=$True)][String]$Path
    )

    # First, Create a table with the incident name to dump incident research into
    $query = "
    CREATE TABLE '$($Name)' (
    'date_logged'	TEXT UNIQUE,
    'date_occured'	TEXT,
    'incident_angle'	TEXT,
    'entry_source'	TEXT,
    'entry_notes'	TEXT
)"

    # make the table defined
    Invoke-SqliteQuery -Database $database -Query $query

    # okay now import incident research into a variable called rows
    Import-CSV -Path $Path | ForEach-Object -Process {

        # Format a query with our row data.
        $query = "INSERT INTO $($Name) ('date_logged','date_occured','incident_angle','entry_source','entry_notes') VALUES ('$($_.date_logged)','$($_.date_occured)','$($_.incident_angle)','$($_.entry_source)','$($_.entry_notes)')"

        # Execute the query
        Invoke-SqliteQuery -Database $database -Query $query

    }
}

