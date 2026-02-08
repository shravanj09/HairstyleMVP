param(
  [string]$StorageAccount,
  [string]$StorageKey,
  [string]$PresetsSource = "D:\\saloon\\Looks\\img",
  [string]$PromptsSource = "D:\\saloon\\Looks\\HairstylePresertPromts.xlsx"
)

if (-not $StorageAccount -or -not $StorageKey) {
  Write-Error "StorageAccount and StorageKey are required."
  exit 1
}

if (-not (Test-Path $PresetsSource)) {
  Write-Error "PresetsSource not found: $PresetsSource"
  exit 1
}

if (-not (Test-Path $PromptsSource)) {
  Write-Error "PromptsSource not found: $PromptsSource"
  exit 1
}

az storage file upload-batch `
  --account-name $StorageAccount `
  --account-key $StorageKey `
  --source $PresetsSource `
  --destination presets

az storage file upload `
  --account-name $StorageAccount `
  --account-key $StorageKey `
  --share-name prompts `
  --source $PromptsSource `
  --path HairstylePresertPromts.xlsx

Write-Host "Upload complete."
