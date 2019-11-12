param (
    [Parameter(Mandatory=$true)][string]$version
)

$target="YecLite-v$version"

Remove-Item -Path release/wininstaller -Recurse -ErrorAction Ignore  | Out-Null
New-Item release/wininstaller -itemtype directory                    | Out-Null

Copy-Item release/$target/yeclite.exe     release/wininstaller/
Copy-Item release/$target/LICENSE                release/wininstaller/

Get-Content src/scripts/zec-qt-wallet.wxs | ForEach-Object { $_ -replace "RELEASE_VERSION", "$version" } | Out-File -Encoding utf8 release/wininstaller/zec-qt-wallet.wxs

candle.exe release/wininstaller/zec-qt-wallet.wxs -o release/wininstaller/zec-qt-wallet.wixobj 
if (!$?) {
    exit 1;
}

light.exe -ext WixUIExtension -cultures:en-us release/wininstaller/zec-qt-wallet.wixobj -out release/wininstaller/YecLite.msi 
if (!$?) {
    exit 1;
}

New-Item artifacts -itemtype directory -Force | Out-Null
Copy-Item release/wininstaller/YecLite.msi ./artifacts/Windows-installer-$target.msi