# Hairstyle MVP

This repo contains:
- `local_app/` FastAPI app + static UI
- `infra/` Terraform (Option A: App Service + Azure Files)
- `.github/workflows/` CI/CD for infra + deploy

## Required GitHub Secrets

Terraform:
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `LIGHTX_API_KEY`
- `NAME_PREFIX` (e.g., `hairstylelooksmvp`)
- `TFSTATE_RG`
- `TFSTATE_STORAGE`
- `TFSTATE_CONTAINER`
- `TFSTATE_KEY`

Deploy:
- `AZURE_WEBAPP_NAME` (Terraform output `web_app_name`)

## Deploy Flow
1. Run Terraform (workflow or local).
2. Upload presets + prompts via `scripts/upload_presets.ps1`.
3. Push `local_app/` changes → auto deploy to App Service.

## Local Run
```
python -m pip install fastapi uvicorn python-multipart openpyxl requests
python -m uvicorn local_app.app:app --reload --host 0.0.0.0 --port 8000
```
