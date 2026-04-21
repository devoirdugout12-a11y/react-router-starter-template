# scripts/trigger-build.ps1
# Script to push changes to GitHub and trigger Cloudflare Pages build

Write-Host "🚀 Démarrage du déploiement Bakatiket..." -ForegroundColor Cyan

# 1. Add all changes
git add .

# 2. Commit
$msg = "build: Bakatiket React Migration (Realtime DB + Auth)"
git commit -m $msg --allow-empty

# 3. Push to master (Cloudflare is listening to this branch)
Write-Host "📤 Poussée vers GitHub..." -ForegroundColor Yellow
git push origin master

Write-Host "✅ Déploiement déclenché sur Cloudflare Pages !" -ForegroundColor Green
Write-Host "Lien Live: https://9c24ff07.bakatiket.pages.dev/" -ForegroundColor Cyan
