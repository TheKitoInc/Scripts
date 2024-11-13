@echo off

net session >nul 2>&1
if %errorLevel% == 0 (
	cls
	echo Instalando/Actualizando Zabbix Agent

	set MSIInstall=%~dp0install.msi

	IF NOT EXIST "%MSIInstall%" (
		powershell -Command "(New-Object Net.WebClient).DownloadFile('https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.4/zabbix_agent-7.0.4-windows-amd64-openssl.msi', '%MSIInstall%')"
	)

	msiexec /passive /i "%MSIInstall%" SERVER=127.0.0.1

	net stop "Zabbix Agent"

	echo. > "%ProgramFiles%\Zabbix Agent\zabbix_agentd.conf"

	echo LogFile=%ProgramFiles%\Zabbix Agent\zabbix_agentd.log  >> "%ProgramFiles%\Zabbix Agent\zabbix_agentd.conf"	

	echo Server=127.0.0.1 >> "%ProgramFiles%\Zabbix Agent\zabbix_agentd.conf"
	echo ListenPort=10050 >> "%ProgramFiles%\Zabbix Agent\zabbix_agentd.conf"
	echo ServerActive=zabbix.%USERDNSDOMAIN%:10051 >> "%ProgramFiles%\Zabbix Agent\zabbix_agentd.conf"

	echo HostMetadataItem=system.uname >> "%ProgramFiles%\Zabbix Agent\zabbix_agentd.conf"

	echo Include=%ProgramFiles%\Zabbix Agent\zabbix_agentd.d\  >> "%ProgramFiles%\Zabbix Agent\zabbix_agentd.conf"

	net start "Zabbix Agent"

	netsh advfirewall firewall delete rule name="ZabbixAgent"
	netsh advfirewall firewall add rule name="ZabbixAgent" dir=in action=allow protocol=TCP localport=10050
) 
