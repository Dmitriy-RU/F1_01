program Formula1;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  DataStorage in 'DataStorage.pas',
  DataModel in 'DataModel.pas',
  DataValidation in 'DataValidation.pas',
  EditForms in 'EditForms.pas',
  FrequencyBandDialogFrm in 'FrequencyBandDialogFrm.pas' {FrequencyBandDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainFormInst);
  Application.CreateForm(TFrequencyBandDialog, FrequencyBandDialog);
  Application.Run;
end.
