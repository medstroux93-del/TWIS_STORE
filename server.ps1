# ==============================================================
# Twis Store Local HTTP Server
# ==============================================================

$port = 8080
$url = "http://localhost:$port/"
$baseDir = $PSScriptRoot

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       Twis Store - Local Server (Port $port)              " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "URL: $url" -ForegroundColor Green
Write-Host "Directory: $baseDir" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)

try {
    $listener.Start()
    try { Start-Process $url } catch {}
} catch {
    Write-Host "Could not start on port ${port}" -ForegroundColor Red
    exit 1
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $relativePath = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrEmpty($relativePath) -or $relativePath -eq "/") {
            $relativePath = "index.html"
        }

        $localPath = Join-Path $baseDir ($relativePath -replace '/', '\')

        if (Test-Path $localPath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($localPath)
            
            $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
            $contentType = switch ($ext) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript; charset=utf-8" }
                ".json" { "application/json; charset=utf-8" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".svg"  { "image/svg+xml" }
                ".ico"  { "image/x-icon" }
                default { "application/octet-stream" }
            }

            $response.ContentType = $contentType
            $response.ContentLength64 = $bytes.Length
            $response.StatusCode = 200
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - File Not Found")
            $response.OutputStream.Write($msg, 0, $msg.Length)
        }
        $response.Close()
    } catch {
        # Ignore client disconnects
    }
}
