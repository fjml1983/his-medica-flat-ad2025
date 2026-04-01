param(
  [string]$ArchetypeDir = "docker/ehrbase-archetypes",
  [string]$EhrbaseArchetypeEndpoint = "http://localhost:8081/ehrbase/rest/openehr/v1/definition/archetype/adl1.4"
)

if (-not (Test-Path $ArchetypeDir)) {
  Write-Error "Archetype directory not found: $ArchetypeDir"
  exit 1
}

$endpointCheck = [int](curl.exe -sS -o NUL -w "%{http_code}" "$EhrbaseArchetypeEndpoint")
if ($endpointCheck -eq 404) {
  Write-Warning "This EHRbase instance does not expose archetype upload endpoint: $EhrbaseArchetypeEndpoint"
  Write-Warning "No archetypes were uploaded. This is expected on many EHRbase versions."
  exit 0
}

if ($endpointCheck -lt 200 -or $endpointCheck -ge 400) {
  Write-Error "Could not validate archetype endpoint ($EhrbaseArchetypeEndpoint). HTTP: $endpointCheck"
  exit 1
}

$files = Get-ChildItem -Path $ArchetypeDir -Recurse -File -Filter *.adl
if (-not $files -or $files.Count -eq 0) {
  Write-Error "No .adl archetypes found in: $ArchetypeDir"
  exit 1
}

foreach ($file in $files) {
  Write-Host "Uploading archetype: $($file.FullName)"
  $uploadStatus = [int](curl.exe -sS -o NUL -w "%{http_code}" -X POST "$EhrbaseArchetypeEndpoint" `
    -H "Content-Type: application/text" `
    --data-binary "@$($file.FullName)")
  if ($uploadStatus -lt 200 -or $uploadStatus -ge 300) {
    Write-Error "Failed uploading $($file.Name). HTTP: $uploadStatus"
    exit 1
  }
}

Write-Host "`nUploaded archetypes."
