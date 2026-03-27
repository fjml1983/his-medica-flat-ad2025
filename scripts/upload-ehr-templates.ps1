param(
  [string]$TemplateDir = "docker/ehrbase-templates",
  [string]$EhrbaseTemplateEndpoint = "http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4"
)

if (-not (Test-Path $TemplateDir)) {
  Write-Error "Template directory not found: $TemplateDir"
  exit 1
}

$optFiles = Get-ChildItem -Path $TemplateDir -Recurse -File -Filter *.opt
$xmlFiles = Get-ChildItem -Path $TemplateDir -Recurse -File -Filter *.xml
$files = @($optFiles) + @($xmlFiles)
if (-not $files -or $files.Count -eq 0) {
  Write-Error "No .opt or .xml templates found in: $TemplateDir"
  exit 1
}

foreach ($file in $files) {
  Write-Host "Uploading template: $($file.FullName)"
  curl.exe -sS -X POST "$EhrbaseTemplateEndpoint" `
    -H "Content-Type: application/xml" `
    --data-binary "@$($file.FullName)"
  Write-Host ""
}

Write-Host "\nUploaded templates. Current template list:"
curl.exe -sS "$EhrbaseTemplateEndpoint"
Write-Host ""
