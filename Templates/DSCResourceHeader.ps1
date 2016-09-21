# HEADER START #
# Load helper functions (DSC is NOT loading automatically the functions of own module)
# Usefull if you have helper methods/function in your dsc Module
$script:currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Debug -Message "CurrentPath: $script:currentPath"
Import-Module $script:currentPath\..\..\*.psd1 -Verbose:$false -ErrorAction Stop
# HEADER STOP #