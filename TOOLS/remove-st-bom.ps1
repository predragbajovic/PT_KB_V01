param(
    [Parameter(Mandatory = $false)]
    [string]$Root = "."
)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$changed = 0
$checked = 0

Get-ChildItem -Path $Root -Recurse -File -Filter "*.st" | ForEach-Object {
    $checked++
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)

    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $newBytes = $bytes[3..($bytes.Length - 1)]
        $text = [System.Text.Encoding]::UTF8.GetString($newBytes)
        [System.IO.File]::WriteAllText($_.FullName, $text, $utf8NoBom)
        $changed++
        Write-Host "BOM removed:" $_.FullName
    }
}

Write-Host "Checked ST files:" $checked
Write-Host "Updated ST files:" $changed
