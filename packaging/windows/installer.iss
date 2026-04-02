#define MyAppName "HashChecker"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Axawys"
#define MyAppExeName "hashchecker.exe"

[Setup]
AppId={{8E2A2F7A-4E4B-4E9D-9B3A-1D8F56C1B111}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=dist
OutputBaseFilename=HashChecker-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=C:\Users\axawys\Documents\flutter\hash_checker\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "C:\Users\axawys\Documents\flutter\hash_checker\build\windows\x64\runner\Release\hashchecker.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\axawys\Documents\flutter\hash_checker\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\axawys\Documents\flutter\hash_checker\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "C:\Users\axawys\Documents\flutter\hash_checker\windows\runner\resources\app_icon.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "C:\Users\axawys\Documents\flutter\hash_checker\windows\runner\resources\app_icon.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Запустить {#MyAppName}"; Flags: nowait postinstall skipifsilent