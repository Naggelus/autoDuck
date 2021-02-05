function Show-MainMenu {
	param (
		
	)
	Clear-Host
	Write-Host -NoNewLine -ForegroundColor Yellow 'Username: '
	Write-Host $env:USERNAME
	Write-Host -NoNewLine -ForegroundColor Yellow 'Computername: '
	Write-Host $env:COMPUTERNAME
	Write-Host -NoNewLine -ForegroundColor Yellow 'Windows Edition: '
	gwmi win32_operatingsystem | % caption
	Write-Host -NoNewLine -ForegroundColor Yellow 'Windows Version: '
	(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId
	
	Write-Host @"

===== Options: =====
	1) Show Network Information
	2) Set Background
	3) Prepare Directory
	4) Install Default Programs
	5) Install Office
	6) Set File associations
 
"@
}

function Download-Resources {
	param (
		
	)
	Clear-Host
	if(!(Test-Path C:\SippicomInstall)) {
		mkdir C:\SippicomInstall
	}
	$ProgressPreference = 'silentlyContinue'
	wget https://github.com/Naggelus/autoDuck/raw/master/resources/Setups.zip -OutFile C:\SippicomInstall\Setups.zip
	wget https://github.com/Naggelus/autoDuck/raw/master/resources/SetUserFTA.exe -OutFile C:\SippicomInstall\SetUserFTA.exe
	wget https://github.com/Naggelus/autoDuck/raw/master/resources/Acroassoc.txt -OutFile $env:TEMP\Acroassoc.txt
	wget https://github.com/Naggelus/autoDuck/raw/master/resources/Officeassoc.txt -OutFile $env:TEMP\Officeassoc.txt
	wget https://github.com/Naggelus/autoDuck/raw/master/resources/VLCassoc.txt -OutFile $env:TEMP\VLCassoc.txt
	Expand-Archive -LiteralPath C:\SippicomInstall\Setups.zip -DestinationPath C:\SippicomInstall -Force
	del C:\SippicomInstall\Setups.zip
	
	Clear-Host
	Write-Host -BackgroundColor Green -ForegroundColor White "Done!"
}

function Install-DefaultPrograms {
	param (
		
	)
	Start-Process msiexec.exe -ArgumentList "-i C:\SippicomInstall\7zip.msi -qn" -Wait
	Write-Host -BackgroundColor Green -ForegroundColor White "7-Zip installation done!"
	Start-Process msiexec.exe -ArgumentList "-i C:\SippicomInstall\VLC.msi -qn" -Wait
	C:\SippicomInstall\SetUserFTA.exe $env:TEMP\VLCassoc.txt
	Write-Host -BackgroundColor Green -ForegroundColor White "VLC installation done!"
	Start-Process C:\SippicomInstall\readerdc_de_xa_crd_install.exe -Wait
	C:\SippicomInstall\SetUserFTA.exe $env:TEMP\Acroassoc.txt
	Write-Host -BackgroundColor Green -ForegroundColor White "Acrobat Reader installation done!"
	Write-Host -BackgroundColor Green -ForegroundColor White "All done!"
}

do {
	Show-MainMenu
	$key = $Host.UI.RawUI.ReadKey()
	switch ($key.Character) {
		'1' {
			Clear-Host
			Get-NetIPConfiguration |
			where {$_.InterfaceAlias -notlike '*Bluetooth*' -and $_.InterfaceAlias -notlike '*Virtual*' } |
			select @{Name='<==================';Expression={}},@{Name='Interface';Expression={$_.InterfaceAlias}},@{Name='IP';Expression={$_.IPv4Address}},@{Name='Gateway';Expression={$_.IPv4DefaultGateway.NextHop}},@{Name='DNS';Expression={$_.DNSServer.ServerAddresses}},@{Name='==================>';Expression={}}
		}
		'2' {
			Clear-Host
			$imgURL = "https://imgur.com/sr24Cak.jpg"
			New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value 0 -Force
			New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
			Add-Type -TypeDefinition "using System;`nusing System.Runtime.InteropServices;`npublic class Params`n{`n[DllImport(`"User32.dll`",CharSet=CharSet.Unicode)]`npublic static extern int SystemParametersInfo (Int32 uAction,`nInt32 uParam,`nString lpvParam,`nInt32 fuWinIni);`n}`n".ToString()
			Invoke-WebRequest -Uri $imgURL -OutFile $env:TEMP\PSWallpaper.jpg
			[Params]::SystemParametersInfo(0x0014, 0, "$env:TEMP\PSWallpaper.jpg", (0x01 -bor 0x02))
			
			Clear-Host
			Write-Host -BackgroundColor Green -ForegroundColor White "Done!"
		}
		'3' {
			Download-Resources
		}
		'4' {
			if(!(Test-Path C:\SippicomInstall\7zip.msi) -Or !(Test-Path C:\SippicomInstall\VLC.msi) -Or !(Test-Path C:\SippicomInstall\readerdc_de_xa_crd_install.exe)) {
				Download-Resources
			}
			Install-DefaultPrograms
		}
		'5' {
			Clear-Host
			Start-Process C:\SippicomInstall\OfficeSetup.exe -Wait
			C:\SippicomInstall\SetUserFTA.exe $env:TEMP\Officeassoc.txt
			
			Clear-Host
			Write-Host -BackgroundColor Green -ForegroundColor White "Office installation done!"
		}
		'6' {
			Clear-Host
			C:\SippicomInstall\SetUserFTA.exe $env:TEMP\VLCassoc.txt
			C:\SippicomInstall\SetUserFTA.exe $env:TEMP\Acroassoc.txt
			C:\SippicomInstall\SetUserFTA.exe $env:TEMP\Officeassoc.txt
			
			Clear-Host
			Write-Host -BackgroundColor Green -ForegroundColor White "File associations set!"
		}
	}
	pause
} until($sel -eq 'q')