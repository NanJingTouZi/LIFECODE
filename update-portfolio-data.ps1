# update-portfolio-data.ps1
# Script ADAPTIF: scan folder porto/ otomatis
# Jika folder hilang → kartu hilang
# Jika folder tambah → kartu tambah

$basePath = "C:\Users\isanw\LIFECODE\porto"
$outputJson = "C:\Users\isanw\LIFECODE\portfolio-data.json"

$portfolioData = @()
$id = 1

$folders = Get-ChildItem -Path $basePath -Directory | Sort-Object Name

foreach ($folder in $folders) {
    $folderName = $folder.Name
    $indexFile = Join-Path $folder.FullName "index.html"
    
    if (Test-Path $indexFile) {
        $content = Get-Content -Path $indexFile -Raw -ErrorAction SilentlyContinue
        
        $totalReturn = if ($content -match 'Total Return:?\s*<strong[^>]*>(.*?)</strong>') { $matches[1].Trim() } else { "—" }
        $winRate = if ($content -match 'Win Rate:</strong>\s*<span[^>]*>(.*?)</span>') { $matches[1].Trim() } else { "—" }
        $maxDD = if ($content -match 'Max Drawdown:</strong>\s*<span[^>]*>(.*?)</span>') { $matches[1].Trim() } else { "—" }
        $profitFactor = if ($content -match 'Profit Factor:</strong>\s*<span[^>]*>(.*?)</span>') { $matches[1].Trim() } else { "—" }
        
        $portfolioData += @{
            id = $id
            title = $folderName
            key = $folderName
            status = "active"
            folder = $folderName
            backtestReturn = $totalReturn
            winRate = $winRate
            maxDD = $maxDD
            profitFactor = $profitFactor
        }
        
        Write-Host "$folderName : Return=$totalReturn, WinRate=$winRate, MaxDD=$maxDD, PF=$profitFactor"
        $id++
    } else {
        Write-Host "$folderName : index.html tidak ditemukan" -ForegroundColor Yellow
    }
}

$portfolioData | ConvertTo-Json -Depth 3 | Set-Content -Path $outputJson -Encoding UTF8
Write-Host "`n✅ portfolio-data.json saved ($($portfolioData.length) portfolios)" -ForegroundColor Green
