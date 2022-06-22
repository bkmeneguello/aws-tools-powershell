$BasePath = Split-Path -Path $PSScriptRoot -Parent
$TemplateFile = Get-Item -Path $BasePath\scripts\aws-tools-template.json
PowerShellGet\Find-Module -Name 'AWS.Tools.*' -Repository 'PSGallery' `
| Where-Object -Property 'Name' -NotIn ('AWS.Tools.Common', 'AWS.Tools.Installer') `
| ForEach-Object -Process {
    $ModuleName = $_.Name.ToLower()
    $n = $ModuleName.Split('.')
    $TemplateName = $n[0..1] + 'powershell' + $n[2] -join '-'
    $ModuleFile = Get-Item -Path "$BasePath\bucket\$TemplateName.json" -ErrorAction SilentlyContinue
    $TemplateJSON = $TemplateFile | Get-Content | ConvertFrom-Json
    if ($ModuleFile.Exists) {
        $ModuleJSON = $ModuleFile | Get-Content | ConvertFrom-Json
        $TemplateJSON.version = $ModuleJSON.version
        $TemplateJSON.url = $ModuleJSON.url
        $TemplateJSON.hash = $ModuleJSON.hash
    }
    $TemplateJSON.description = $_.Description -Split '[.]' | Select-Object -First 1
    $TemplateJSON.psmodule.name = $_.Name
    $TemplateJSON.checkver.url = $TemplateJSON.checkver.url -Replace ('<TBD>', $_.Name)
    $TemplateJSON.autoupdate.url = $TemplateJSON.autoupdate.url -Replace ('<TBD>', $ModuleName)
    $ModuleFile | Set-Content -Value ($TemplateJSON | ConvertTo-Json)
}
# Get-ChildItem -Path bucket\aws-tools-*.json | ForEach-Object -Process { $_.Basename }
