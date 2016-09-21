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
        Write-Verbose "${AbsOutputDirectory}/$($Module.Name)/DSCResources/$($Resource.Name)"
        if (Test-Path "${AbsOutputDirectory}/$($Module.Name)/DSCResources/$($Resource.Name)") {
          Write-Verbose "Updating $($Resource.Name)"
          Update-xDscResource -Force –Path "${AbsOutputDirectory}/$($Module.Name)/DSCResources/$($Resource.Name)" –Property $DscProperties
        } else {
          Write-Verbose "Creating $($Resource.Name)"
          New-xDscResource –Name $Resource.Name –Property $DscProperties –Path $AbsOutputDirectory –ModuleName $Module.Name
        }
        Update-DscHeader -ResourcePsm1ScriptPath "${AbsOutputDirectory}/$($Module.Name)/DSCResources/$($Resource.Name)/$($Resource.Name).psm1"
      }
      Update-DSCResourceHelpersFunctions -DSCModulePath "${AbsOutputDirectory}/$($Module.Name)"
      Write-Verbose "Copy DSC YAML definition in Module $($Resource.Name)"
      if (!(Test-path "${AbsOutputDirectory}/$($Module.Name)/$($Module.Name).dsc.yml")) {
        Copy-Item -Force $AbsYamlPath "${AbsOutputDirectory}/$($Module.Name)/$($Module.Name).dsc.yml"
      }
    }
  }
}

