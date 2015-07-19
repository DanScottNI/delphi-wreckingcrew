program WreckingCrewEditor;

uses
  Forms,
  WreckingCrew in 'WreckingCrew.pas' {frmWreckingCrew},
  Preferences in 'Preferences.pas' {frmPreferences},
  ExportLevel in 'ExportLevel.pas' {frmExportLevel},
  ImportLevel in 'ImportLevel.pas' {frmImportLevel},
  SaveStateImport in 'SaveStateImport.pas' {frmSaveStateImport},
  About in 'About.pas' {frmAbout},
  JumpTo in 'JumpTo.pas' {frmJumpTo},
  WreckingCrewData in 'WreckingCrewData.pas',
  StartLive in 'StartLive.pas' {frmLives};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Demolition v1.0';
  Application.CreateForm(TfrmWreckingCrew, frmWreckingCrew);
  Application.Run;
end.
