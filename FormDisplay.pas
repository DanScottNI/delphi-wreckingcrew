unit FormDisplay;

interface

uses Forms;

Procedure ShowPreferences();
Procedure ShowAbout();
Procedure ShowExportLevel();
Procedure ShowImportLevel();
Procedure ShowSaveStateImport();
Procedure ShowJumpTo();
Procedure ShowStartingLives();

implementation



Procedure ShowPreferences();
begin
  // if the options dialog is not open then
  // create it, and show it
  if frmPreferences = nil then
  begin
    frmPreferences := TfrmPreferences.Create(Application);
  end;
  // If the options dialog is open,
  // then just show it.
  if frmPreferences <> nil then
  begin
    frmPreferences.ShowModal;
  end;
end;

Procedure ShowStartingLives();
begin
  // if the options dialog is not open then
  // create it, and show it
  if frmLives = nil then
  begin
    frmLives := TfrmLives.Create(Application);
  end;
  // If the options dialog is open,
  // then just show it.
  if frmLives <> nil then
  begin
    frmLives.ShowModal;
  end;
end;

Procedure ShowJumpTo();
begin
  // if the options dialog is not open then
  // create it, and show it
  if frmJumpTo = nil then
  begin
    frmJumpTo := TfrmJumpTo.Create(Application);
  end;
  // If the options dialog is open,
  // then just show it.
  if frmJumpTo <> nil then
  begin
    frmJumpTo.ShowModal;
  end;
end;

Procedure ShowExportLevel();
begin
  // if the options dialog is not open then
  // create it, and show it
  if frmExportLevel = nil then
  begin
    frmExportLevel := TfrmExportLevel.Create(Application);
  end;
  // If the options dialog is open,
  // then just show it.
  if frmExportLevel <> nil then
  begin
    frmExportLevel.ShowModal;
  end;
end;

Procedure ShowImportLevel();
begin
  // if the options dialog is not open then
  // create it, and show it
  if frmImportLevel = nil then
  begin
    frmImportLevel := TfrmImportLevel.Create(Application);
  end;
  // If the options dialog is open,
  // then just show it.
  if frmImportLevel <> nil then
  begin
    frmImportLevel.ShowModal;
  end;
end;

Procedure ShowAbout();
begin
  // if the options dialog is not open then
  // create it, and show it
  if frmAbout = nil then
  begin
    frmAbout := TfrmAbout.Create(Application);
  end;
  // If the options dialog is open,
  // then just show it.
  if frmAbout <> nil then
  begin
    frmAbout.ShowModal;
  end;
end;

Procedure ShowSaveStateImport();
begin
  // if the options dialog is not open then
  // create it, and show it
  if frmSaveStateImport = nil then
  begin
    frmSaveStateImport := TfrmSaveStateImport.Create(Application);
  end;
  // If the options dialog is open,
  // then just show it.
  if frmSaveStateImport <> nil then
  begin
    frmSaveStateImport.ShowModal;
  end;
end;

end.
