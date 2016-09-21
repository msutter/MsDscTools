$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

# Load all functions recursively present in functions dir
Get-ChildItem -Recurse -Path "$moduleRoot\Functions" -Include "*.ps1" -Exclude "*.Tests.*" |
Resolve-Path |
ForEach-Object -Process {
    . $_.ProviderPath
}

# Export Functions
Export-ModuleMember -Function *
