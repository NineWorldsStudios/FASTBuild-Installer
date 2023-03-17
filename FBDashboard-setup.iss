; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

; TODO: CHANGE THE BASE PROJECT PATH BEFORE BUILDING THE INSTALLER !! 
#define ProjectPath "E:\projects\fastbuild"

#define FBBrokerPath "\\datasan\FASTBuild\broker"
#define FBCachePath "\\datasan\FASTBuild\cache"

#define MyAppId "{9F23EDC4-F98F-433A-8914-FA2E8CFDCDFD}" 
#define MyAppName "FASTBuild Dashboard"
#define MyAppVersion "0.94.1.104"
#define MyAppPublisher "Nine Worlds Studios GmbH"
#define MyAppURL "https://www.nineworldsstudios.com/"
#define MyAppExeName "FBDashboard.exe"    

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\FBDashboard
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
PrivilegesRequired=admin
;PrivilegesRequiredOverridesAllowed=dialog
OutputDir={#ProjectPath}\FASTBuild Installer
OutputBaseFilename=FBDashboard-setup
SetupIconFile={#ProjectPath}\FASTBuild-Dashboard\Source\Resources\Icons\app.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{app}"; Permissions: users-modify
Name: "{app}\FBuild"; Permissions: users-modify

[Files]
Source: "{#ProjectPath}\FASTBuild-Dashboard\Source\bin\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectPath}\FASTBuild\tmp\x64-Release\Tools\FBuild\FBuildWorker\FBuildWorker.exe"; DestDir: "{app}\FBuild"; Flags: ignoreversion    
Source: "{#ProjectPath}\FASTBuild-Installer\Prerequisites\UEPrereqSetup_x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; AfterInstall: InstallUEPrereq
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall
                              
[CustomMessages]
english.NewerVersionExists=A newer version of {#MyAppName} is already installed.%n%nInstaller version: {#MyAppVersion}%nCurrent version:

[Code]
var
  FBConfigDirPage: TInputDirWizardPage;
     
function InitializeSetup: Boolean;
var Version: String;
begin
  if RegValueExists(HKLM,'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'DisplayVersion') then
  begin
    RegQueryStringValue(HKLM,'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'DisplayVersion', Version);
    if Version >= '{#MyAppVersion}' then
    begin
      SuppressibleMsgBox(ExpandConstant('{cm:NewerVersionExists} '+Version), mbInformation, MB_OK, 0);
      Result := False;
    end
    else
    begin
      Result := True;
    end
  end
  else
  begin
    Result := True;
  end
end;

procedure DirBrowseBrokerClick(Sender: TObject);
var
  Path: String;
begin
  Path := FBConfigDirPage.Values[0];
  if BrowseForFolder(SetupMessage(msgBrowseDialogLabel), Path, True) then
  begin
    FBConfigDirPage.Values[0] := Path;
  end;
end;

procedure DirBrowseCacheClick(Sender: TObject);
var
  Path: String;
begin
  Path := FBConfigDirPage.Values[1];
  if BrowseForFolder(SetupMessage(msgBrowseDialogLabel), Path, True) then
  begin
    FBConfigDirPage.Values[1] := Path;
  end;
end;

procedure AddFBConfigPage();
begin
  FBConfigDirPage := CreateInputDirPage(wpWelcome,
  'FASTBuild configuration', '',
  'To continue, click Next. If you would like to select a different folder for the brokerage and the cache, click Browse.',
  True, '');

  FBConfigDirPage.Add('Workers are discovered through a brokerage location. The brokerage location is a network path accessible from both the host and workers. Windows and UNC format paths are supported.'#13#10 + 'Brokerage path:');
  FBConfigDirPage.Add('The cache location can be a local or network path. On Windows UNC format paths are also supported.'#13#10 + 'Cache path:');
  
  FBConfigDirPage.Buttons[0].OnClick := @DirBrowseBrokerClick;
  FBConfigDirPage.Buttons[1].OnClick := @DirBrowseCacheClick;

  FBConfigDirPage.Values[0] := ExpandConstant('{#FBBrokerPath}');
  FBConfigDirPage.Values[1] := ExpandConstant('{#FBCachePath}');
end;

procedure InitializeWizard();
begin
  AddFBConfigPage();
end;

procedure InstallUEPrereq;
var
  StatusText: string;        
var
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := 'Installing Unreal Engine Prerequisites...';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try   
    if not Exec(ExpandConstant('{tmp}\UEPrereqSetup_x64.exe'), '/install /passive /quiet /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
      MsgBox('Unreal Engine Prerequisites installation failed with code: ' + IntToStr(ResultCode) + '.',
        mbError, MB_OK);
    end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;

function GetBrokerPath(param: String): String;
begin
  Result := FBConfigDirPage.Values[0];
end;  
function GetCachePath(param: String): String;
begin
  Result := FBConfigDirPage.Values[1];
end;

[Registry]                
Root: "HKLM"; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "FBDashboard"; ValueData: """{app}\{#MyAppExeName}"" -minimized"; Flags: createvalueifdoesntexist uninsdeletekeyifempty uninsdeletevalue
Root: "HKLM"; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "FASTBUILD_BROKERAGE_PATH"; ValueData: {code:GetBrokerPath}; Flags: createvalueifdoesntexist uninsdeletekeyifempty uninsdeletevalue
Root: "HKLM"; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "FASTBUILD_CACHE_PATH"; ValueData: {code:GetCachePath}; Flags: createvalueifdoesntexist uninsdeletekeyifempty uninsdeletevalue      

