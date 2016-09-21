function Update-DscHeader
{
  <#
    .SYNOPSIS
    Updates the header of a DSC resource psm1 script
    .DESCRIPTION
    Updates the header of a DSC resource psm1 script
    .EXAMPLE
    Update-DscHeader -Name myResource -
  #>

  [CmdletBinding()]
  Param
  (
    # location of the yaml file
    [ValidateScript( { Test-Path($_) -include *.psm1} ) ]
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
    [String]$ResourcePsm1ScriptPath
  )

  Process {

    # Get header content
    $ModulePath = Split-Path -parent $PSScriptRoot
    $Header = Get-Content $ModulePath\Templates\DscResourceHeader.ps1

    # Set absolute pathes
    if ([System.IO.Path]::IsPathRooted($ResourcePsm1ScriptPath)) {
        $Path = $ResourcePsm1ScriptPath
    } else {
        $Path = Join-Path (Get-Location) $ResourcePsm1ScriptPath
    }

    $ResourcePsm1ScriptContent = Get-Content $ResourcePsm1ScriptPath -Raw
    $Header = Get-Content C:\vagrant\MsDscTools\Templates\DSCResourceHeader.ps1 -Raw
    $Regex = '(?s)(# HEADER START #.*# HEADER STOP #)'

    if ($ResourcePsm1ScriptContent -Match $Regex){
      $match = [regex]::Match($ResourcePsm1ScriptContent, $Regex)
      if ($match.captures.groups[1].value -ne $Header){
        Write-Verbose "Update header to ${ResourcePsm1ScriptPath}"
        $Null = $ResourcePsm1ScriptContent -replace $Regex , $Header
      } else {
        Write-Verbose "Nothing to update"
      }

    } else {
      Write-Verbose "Adding header to ${ResourcePsm1ScriptPath}"
      $Null = Set-Content $ResourcePsm1ScriptPath -value $Header, "", $ResourcePsm1ScriptContent
    }

  }
}