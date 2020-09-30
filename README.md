
[![forthebadge](https://forthebadge.com/images/badges/fuck-it-ship-it.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/gluten-free.svg)](https://forthebadge.com)

Diagtastic!

# About
Diagtastic! is powershell utility for organizing incident research and building timelines. The goal of this project is to help new IT professional like helpdesk and sys admins hone their troubleshooting skills while getting experience with the powershell CLI. To do this, this utiliy implements the OSI Model for troubleshooting into incident journals where the user is prompted to define which layer of the OSI model they believe the error is occuring in (an "angle") and how that is manifesting practically (a "source")

**Example:** User reports that Adobe DC is not working correctly (Application layer). The Helpdesk agent notices the PDF (Presentation Layer) they're trying to open doesn't work on any copmuter and is likely the source of the problem. The Angle in this case would be the a presentation layer problem whose specific source is the corrupt PDF file.

and would be indicated in like

<code>
Update-Incident 113983 -Angle Presentation -Source "PDF File" -Notes "Noticed that the pdf file the user was opening wouldn't open on any computer"
</code>

# Requirements
* [PSSQLite 1.1.0](https://www.powershellgallery.com/packages/PSSQLite/1.1.0)

# Installation Instructions
## Windows 
I recommend installing this module in your user profile. so to do that, clone this project to:

<code>
     C:\Users\%USERNAME%\Documents\WindowsPowerShell\Modules
</code>


## Linux
I have no idea. probably installs somewhere in the snapdir for pwsh, will find out later.