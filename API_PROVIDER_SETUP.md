API Provider Setup (Local + Azure)

Local (Windows PowerShell)
1. Choose provider and set only the required key:
   - Use API Market:
     $env:HAIRSTYLE_PROVIDER="apimarket"
     $env:API_MARKET_KEY="YOUR_API_MARKET_KEY"
   - Use LightX (default):
     $env:HAIRSTYLE_PROVIDER="lightx"
     $env:LIGHTX_API_KEY="YOUR_LIGHTX_KEY"
2. Start the app:
   python -m uvicorn local_app.app:app --reload --host 0.0.0.0 --port 8000

Azure Container Apps
1. Set provider and only the required key:
   - API Market:
     az containerapp update -g hairstylelooksmvp-rg -n hairstylelooksmvp-api `
       --set-env-vars HAIRSTYLE_PROVIDER=apimarket API_MARKET_KEY=YOUR_API_MARKET_KEY
   - LightX:
     az containerapp update -g hairstylelooksmvp-rg -n hairstylelooksmvp-api `
       --set-env-vars HAIRSTYLE_PROVIDER=lightx LIGHTX_API_KEY=YOUR_LIGHTX_KEY

Notes
- HAIRSTYLE_PROVIDER defaults to "lightx" if not set.
- Keep API keys out of source control.
