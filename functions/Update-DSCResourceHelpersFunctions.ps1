function Update-DSCResourceHelpersFunctions
{
  <#
    .SYNOPSIS
    Updates the structure (placeholder) for helper functions
    .DESCRIPTION
    Updates the structure (placeholder) for helper functions
    .EXAMPLE
    Update-DSCResourceHelpersFunctions -Name myResource -
    .EXAMPLE
    New-DscModuleFromYaml -YamlPath .\MsDscTools\examples\proget_dsc.yaml -OutputDirectory "${HOME}/Documents"
  #>

  [CmdletBinding()]
  Param
  (
    # location of the yaml file
    [ValidateScript( { Test-Path($_) -PathType Container} ) ]
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
    [String]$DSCModulePath
  )

  Process {

    # Set absolute pathes
    if ([System.IO.Path]::IsPathRooted($DSCModulePath)) {
        $DSCModulePathAbs = $DSCModulePath
    } else {
        $DSCModulePathAbs = Join-Path (Get-Location) $DSCModulePath
    }

    $ModuleName = Split-Path $DSCModulePathAbs -Leaf
    $ModulePath = Split-Path -parent $PSScriptRoot
    $RootModuleTemplatePath = "${ModulePath}\Templates\RootModule.psm1"


    Write-Verbose "Adding helper functions structure to ${Path}"
    Copy-Item -Force $RootModuleTemplatePath "${DSCModulePathAbs}/${ModuleName}.psm1"

    if (!(Test-Path("$DSCModulePathAbs/Functions"))) {
      New-Item -ItemType Directory -Path $DSCModulePathAbs/Functions
    }

    # Powershell 5 only
    Update-ModuleManifest "${DSCModulePathAbs}/${ModuleName}.psd1" -RootModule "${ModuleName}.psm1"

  }
}