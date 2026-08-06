# update-forward-test.ps1
# Script untuk auto-update forward-test.json dari ShowMyTrades
# Jalankan daily via Task Scheduler

$forwardJson = "C:\Users\isanw\LIFECODE\forward-test.json"

$accounts = @(
    @{ Key = "WAIVER1";   Url = "https://showmytrades.com/account/nanjing-waiver-risk-1" },
    @{ Key = "WAIVER5";   Url = "https://showmytrades.com/account/nanjing-waiver-risk-10" },
    @{ Key = "AXION1";    Url = "https://showmytrades.com/account/nanjing-axion-risk-1" },
    @{ Key = "AXION10";   Url = "https://showmytrades.com/account/nanjing-axion-risk-10" },
    @{ Key = "CAPE1";     Url = "https://showmytrades.com/account/nanjing-cape-risk-1" },
    @{ Key = "CAPE10";    Url = "https://showmytrades.com/account/nanjing-cape-risk-10" },
    @{ Key = "SEAL1";     Url = "https://showmytrades.com/account/nanjing-shark-risk-1" },
    @{ Key = "SEAL10";    Url = "https://showmytrades.com/account/nanjing-shark-risk-10" },
    @{ Key = "TRICK7";    Url = "https://showmytrades.com/account/nanjing-trick-risk-7-5" },
    @{ Key = "HOLE7";     Url = "https://showmytrades.com/account/nanjing-hole-risk-7-5" },
    @{ Key = "ZEUS10";    Url = "https://showmytrades.com/account/isanwijaya-master-zeus10" },
    @{ Key = "ZEUS50";    Url = "https://showmytrades.com/account/isanwijaya-master-zeus50" },
    @{ Key = "ATHENA10";  Url = "https://showmytrades.com/account/isanwijaya-master-athena10" },
    @{ Key = "ATHENA50";  Url = "https://showmytrades.com/account/isanwijaya-master-athena50" },
    @{ Key = "ODIN10";    Url = "https://showmytrades.com/account/isanwijaya-master-odin10" },
    @{ Key = "ODIN50";    Url = "https://showmytrades.com/account/isanwijaya-master-odin50" },
    @{ Key = "DOLPHIN1";  Url = "https://showmytrades.com/account/nanjing-dolphin-1" },
    @{ Key = "DOLPHIN10"; Url = "https://showmytrades.com/account/nanjing-dolphin-10" },
    @{ Key = "ORCA1";     Url = "https://showmytrades.com/account/nanjing-orca-1" },
    @{ Key = "ORCA10";    Url = "https://showmytrades.com/account/nanjing-orca-10" },
    @{ Key = "MERLIN1";   Url = "https://showmytrades.com/account/nanjing-merlin-1" },
    @{ Key = "MERLIN10";  Url = "https://showmytrades.com/account/nanjing-merlin-10" }
)

$forwardData = $null

# Read existing data if file exists
if (Test-Path $forwardJson) {
    $forwardData = Get-Content -Path $forwardJson -Raw | ConvertFrom-Json -AsHashtable
}

if (-not $forwardData) {
    $forwardData = @{}
}

$today = Get-Date -Format "yyyy-MM-dd"

foreach ($account in $accounts) {
    $key = $account.Key
    $url = $account.Url
    
    Write-Host "Fetching $key..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
        $content = $response.Content
        
        $gain = if ($content -match 'Gain.*?</td>\s*<td[^>]*>(.*?)</td>') { ($matches[1] -replace '<[^>]+>','').Trim() } else { "ERROR" }
        $profit = if ($content -match 'Profit.*?</td>\s*<td[^>]*>(.*?)</td>') { ($matches[1] -replace '<[^>]+>','').Trim() } else { "ERROR" }
        $drawdown = if ($content -match 'Maximum Drawdown \(on Equity\).*?</td>\s*<td[^>]*>(.*?)</td>') { ($matches[1] -replace '<[^>]+>','').Trim() } else { "ERROR" }
        $winRate = if ($content -match 'Win Rate.*?</td>\s*<td[^>]*>(.*?)</td>') { ($matches[1] -replace '<[^>]+>','').Trim() } else { "ERROR" }
        $profitFactor = if ($content -match 'Profit Factor.*?</td>\s*<td[^>]*>(.*?)</td>') { ($matches[1] -replace '<[^>]+>','').Trim() } else { "ERROR" }
        $balance = if ($content -match 'Balance.*?</td>\s*<td[^>]*>(.*?)</td>') { ($matches[1] -replace '<[^>]+>','').Trim() } else { "ERROR" }
        
        $forwardData[$key] = @{
            gain = $gain
            profit = $profit
            drawdown = $drawdown
            winRate = $winRate
            profitFactor = $profitFactor
            balance = $balance
            lastUpdate = $today
        }
        
        Write-Host "  ✓ $key : Gain=$gain, Profit=$profit" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ $key : ERROR - $($_.Exception.Message)" -ForegroundColor Red
        if (-not $forwardData[$key]) {
            $forwardData[$key] = @{
                gain = "ERROR"
                profit = "ERROR"
                drawdown = "ERROR"
                winRate = "ERROR"
                profitFactor = "ERROR"
                balance = "ERROR"
                lastUpdate = $today
            }
        }
    }
    
    Start-Sleep -Seconds 2
}

$forwardData | ConvertTo-Json -Depth 3 | Set-Content -Path $forwardJson -Encoding UTF8
Write-Host "`n✅ forward-test.json updated ($($forwardData.Count) portfolios)" -ForegroundColor Green
Write-Host "Date: $today"
