; OperChef Print Agent — Instalador NSIS silencioso
!define APPNAME "OperChef Print Agent"
!define COMPANY "OperChef"
!define VERSION "0.1.0"

Name "${APPNAME}"
OutFile "dist\OperChefPrintAgentSetup.exe"
InstallDir "$PROGRAMFILES64\OperChefPrintAgent"
RequestExecutionLevel admin
SilentInstall normal

Page directory
Page instfiles

Section "Install"
  SetOutPath "$INSTDIR"
  File "dist\OperChefPrintAgent.exe"

  ; Registra como serviço Windows usando sc.exe
  ExecWait 'sc.exe create "OperChefPrintAgent" binPath= "\"$INSTDIR\OperChefPrintAgent.exe\"" start= auto DisplayName= "${APPNAME}"'
  ExecWait 'sc.exe description "OperChefPrintAgent" "Serviço de impressão térmica local OperChef (porta 8765)."'
  ExecWait 'sc.exe start "OperChefPrintAgent"'

  ; Libera firewall na porta 8765 (LAN)
  ExecWait 'netsh advfirewall firewall add rule name="OperChef Print Agent" dir=in action=allow protocol=TCP localport=8765'

  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
  ExecWait 'sc.exe stop "OperChefPrintAgent"'
  ExecWait 'sc.exe delete "OperChefPrintAgent"'
  ExecWait 'netsh advfirewall firewall delete rule name="OperChef Print Agent"'
  Delete "$INSTDIR\OperChefPrintAgent.exe"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
SectionEnd
