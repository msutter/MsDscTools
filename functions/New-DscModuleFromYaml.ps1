function New-DscModuleFromYaml
{
  <#
    .SYNOPSIS
    Build new DSC custom Resources based on a yaml file
    .DESCRIPTION
    Powershell Module providing feature to build new DSC custom Resources based on a yaml file
    See example folder for the yaml format to provide
    .EXAMPLE
    New-DscModuleFromYaml -YamlPath .\MsDscTools\examples\proget_dsc.yaml
    .EXAMPLE
    New-DscModuleFromYaml -YamlPath .\MsDscTools\examples\proget_dsc.yaml -OutputDirectory "${HOME}/Documents"
  #>

  [CmdletBinding()]
  Param
  (
    # location of the yaml file
    [ValidateScript( { Test-Path($_) } ) ]
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
    [string]$YamlPath,

    # location where the Module must be written
    [ValidateScript( { Test-Path($_) -PathType Container } )]
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true )]
    [string]$OutputDirectory = ("${PSHOME}/Modules")

  )

  Process {

    # Set absolute pathes
    if ([System.IO.Path]::IsPathRooted($YamlPath)) {
        $AbsYamlPath = $YamlPath
    } else {
        $AbsYamlPath = Join-Path (Get-Location) $YamlPath
    }

    if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
        $AbsOutputDirectory = $OutputDirectory
    } else {
        $AbsOutputDirectory = Join-Path (Get-Location) $OutputDirectory
    }

    $yaml = Get-Yaml -FromFile $AbsYamlPath
    foreach ($Module in $yaml.Modules){
      foreach ($Resource in $Module.Resources){
        $DscProperties = @()
        foreach ($property in $Resource.properties){
          $DscProperty = New-xDscResourceProperty @property
          $DscProperties += $DscProperty
        }
        New-xDscResource –Name $Resource.Name –Property $DscProperties –Path $AbsOutputDirectory –ModuleName $Module.Name
      }

    }
  }
}

