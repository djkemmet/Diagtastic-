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