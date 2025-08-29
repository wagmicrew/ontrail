@echo off
echo Testing Website Accessibility
echo ============================
echo.

echo Testing dintrafikskolahlm.se...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://dintrafikskolahlm.se' -Method Head -TimeoutSec 10; Write-Host '✅ SUCCESS: HTTP' $response.StatusCode } catch { Write-Host '❌ FAILED:' $_.Exception.Message }"
echo.

echo Testing dev.dintrafikskolahlm.se...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://dev.dintrafikskolahlm.se' -Method Head -TimeoutSec 10; Write-Host '✅ SUCCESS: HTTP' $response.StatusCode } catch { Write-Host '❌ FAILED:' $_.Exception.Message }"
echo.

echo Testing ontrail.tech...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://ontrail.tech' -Method Head -TimeoutSec 10; Write-Host '✅ SUCCESS: HTTP' $response.StatusCode } catch { Write-Host '❌ FAILED:' $_.Exception.Message }"
echo.

echo.
echo Test Complete!
echo.
echo If you see SUCCESS messages, the HTTP/2 error is fixed!
echo If you see FAILED messages with SSL errors, try:
echo 1. Clear browser cache (Ctrl+Shift+R)
echo 2. Try incognito/private browsing mode
echo 3. Try a different browser
echo 4. Wait a few minutes for DNS propagation
echo.
pause

