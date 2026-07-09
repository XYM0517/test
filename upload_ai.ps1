param(
  [string]$UserAccount = 'xuym16',
  [int]$AiLines = 5000,
  [int]$HumanLines = 1000,
  [int]$MixedLines = 50,
  [string]$ApiUrl = 'http://codegpt-copilot.asiainfo.com.cn/api/prompt/commit/save'
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$payload = [PSCustomObject]@{
  userAccount = $UserAccount
  aiLines     = $AiLines
  humanLines  = $HumanLines
  mixedLines  = $MixedLines
} | ConvertTo-Json

Write-Host "`n=================================================="
Write-Host "           AI 贡献统计数据上传工具"
Write-Host "=================================================="
Write-Host ">>> 目标地址: $ApiUrl"
Write-Host ">>> 用户账号: $UserAccount"
Write-Host ">>> AI 代码行数: $AiLines"
Write-Host ">>> 人工代码行数: $HumanLines"
Write-Host ">>> 混合代码行数: $MixedLines"
Write-Host ">>> JSON 载荷: $payload"
Write-Host "--------------------------------------------------"

try {
  Write-Host ">>> 正在发送请求... (超时: 30秒)"
  $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  $resp = Invoke-RestMethod -Uri $ApiUrl -Method Post -ContentType 'application/json' -Body $payload -TimeoutSec 30
  $stopwatch.Stop()
  
  Write-Host "`n>>> ✅ 请求成功!" -ForegroundColor Green
  Write-Host ">>> 耗时: $($stopwatch.Elapsed.TotalMilliseconds)ms" -ForegroundColor Cyan
  
  if ($resp -ne $null) {
    try {
      $json = $resp | ConvertTo-Json -Compress
      Write-Host ">>> 响应(JSON): $json" -ForegroundColor Cyan
    } catch {
      Write-Host ">>> 响应(文本):" -ForegroundColor Cyan
      $resp | Out-String | Write-Output
    }
  } else {
    Write-Host ">>> 响应: 空响应(服务端成功处理但未返回正文)" -ForegroundColor Yellow
  }
  
  Write-Host "`n>>> 🎉 数据上传完成! 贡献率已更新" -ForegroundColor Green
} catch {
  Write-Host "`n>>> ❌ 请求失败!" -ForegroundColor Red
  Write-Error ("错误信息: " + $_.Exception.Message)
  if ($_.Exception.Response) {
    $statusCode = [int]$_.Exception.Response.StatusCode.value__
    Write-Host "HTTP状态码: $statusCode" -ForegroundColor Red
    if ($_.Exception.Response.GetResponseStream()) {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $errorBody = $reader.ReadToEnd()
      Write-Host "响应体: $errorBody" -ForegroundColor Red
    }
  }
  exit 1
}
