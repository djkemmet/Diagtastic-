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
    Install-Module -Name PSSQLite
}

# Check for this module's database
Switch (Test-Path -Path '~\.diagtastic'){

    #If the directory exists
    $true{

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

        .EXAMPLE

        .EXAMPLE

        .EXAMPLE

    #>

    # Define the parameters of this function in a param block.
    [CmdletBinding()]
    param (
        [String[]]$IncidentName
    )


}

function Update-Incident {

}