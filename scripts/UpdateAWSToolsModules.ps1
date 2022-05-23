$basepath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
PowerShellGet\Find-Module -Name 'AWS.Tools.*' -Repository 'PSGallery' |  Where-Object -Property 'Name' -NotIn ('AWS.Tools.Common', 'AWS.Tools.Installer') | ForEach-Object -Process {
    $pkg_name = $_.Name.ToLower()
    $n = $pkg_name.Split('.')
    $t_name = $n[0..1] + 'powershell' + $n[2] -join '-'
    $m_file = "$basepath\..\bucket\$t_name.json"
    $t = (Get-Content -Path $basepath\aws-tools-template.json | ConvertFrom-Json)
    if (Test-Path $m_file) {
        $m = (Get-Content $m_file | ConvertFrom-Json)
        $t.version = $m.version
        $t.url = $m.url
        $t.hash = $m.hash
    }
    $t.description = $_.description.Split('.')[0]
    $t.psmodule.name = $_.Name
    $t.checkver.url = $t.checkver.url.Replace('<TBD>', $_.Name)
    $t.autoupdate.url = $t.autoupdate.url.Replace('<TBD>', $pkg_name)
    ConvertTo-Json $t | Set-Content -Path $m_file
}
# Get-ChildItem -Path bucket\aws-tools-*.json | ForEach-Object -Process { $_.Basename }
