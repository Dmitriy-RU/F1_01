
unit MainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  DataModel,
  DataStorage,
  EditForms,
  DataValidation;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FDocument: TTechnicalDocument;
    FCurrentFileName: string;

    FTopPanel: TPanel;
    FPageControl: TPageControl;
    FStatusBar: TStatusBar;

    FNewButton: TButton;
    FOpenButton: TButton;
    FSaveButton: TButton;
    FSaveAsButton: TButton;
    FValidateButton: TButton;
    FPrintButton: TButton;

    FOpenDialog: TOpenDialog;
    FSaveDialog: TSaveDialog;

FGeneralEditor: TGeneralInformationEditor;
FFrequencyBandsEditor: TFrequencyBandsEditor;
FEquipmentCompositionEditor: TEquipmentCompositionEditor;
FTransmitterEditor: TTransmitterEditor;
FReceiverEditor: TReceiverEditor;
FAntennaEditor: TAntennaEditor;
FFeederEditor: TFeederEditor;
FEmcEditor: TEmcEditor;
FOrganizationsEditor: TOrganizationsEditor;

    procedure CreateInterface;
    procedure CreateTabs;
    procedure CreateToolbar;

    procedure NewDocument;
    procedure OpenDocument;
    procedure SaveDocument;
    procedure SaveDocumentAs;
    procedure ValidateDocument;
    procedure PrintDocument;

    procedure UpdateCaption;
    procedure UpdateStatus;

    procedure NewButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure SaveAsButtonClick(Sender: TObject);
    procedure ValidateButtonClick(Sender: TObject);
    procedure PrintButtonClick(Sender: TObject);

  public
    property Document: TTechnicalDocument read FDocument;
  end;

var
  MainFormInst: TMainForm;

implementation

{$R *.dfm}

// ------------------------------------------------------------
// Создание формы
// ------------------------------------------------------------

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   Timer1.Enabled:=false;
  FDocument := TTechnicalDocument.Create;

  FCurrentFileName := '';

  CreateInterface;

  UpdateCaption;
  UpdateStatus;

  //////////////////// !!!
  FGeneralEditor.Bind(FDocument.GeneralInformation);
FFrequencyBandsEditor.Bind(
  FDocument.TransmitterFrequencyBands,
  FDocument.ReceiverFrequencyBands
);
FEquipmentCompositionEditor.Bind(
  FDocument.EquipmentComposition
);
FTransmitterEditor.Bind(FDocument.Transmitter);
FReceiverEditor.Bind(FDocument.Receiver);
FAntennaEditor.Bind(FDocument.Antennas);
FFeederEditor.Bind(FDocument.Feeder);
FEmcEditor.Bind(FDocument.EmcInformation);

FOrganizationsEditor.Bind(
  FDocument.Customer,
  FDocument.Developer,
  FDocument.Manufacturer
);

  ///////////////

end;

procedure TMainForm.FormShow(Sender: TObject);
begin
end;

// ------------------------------------------------------------
// Освобождение ресурсов
// ------------------------------------------------------------

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FDocument);
end;

// ------------------------------------------------------------
// Создание интерфейса
// ------------------------------------------------------------

procedure TMainForm.CreateInterface;
begin
  Caption := 'КТТД — Тактико-технические данные';

  Width := 1100;
  Height := 750;

  Position := poScreenCenter;

  CreateToolbar;
  CreateTabs;

  FStatusBar := TStatusBar.Create(Self);
  FStatusBar.Parent := Self;
  FStatusBar.Align := alBottom;
  FStatusBar.SimplePanel := True;

  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Filter :=
    'Документы КТТД (*.json)|*.json|Все файлы (*.*)|*.*';
  FOpenDialog.DefaultExt := 'json';

  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Filter :=
    'Документы КТТД (*.json)|*.json|Все файлы (*.*)|*.*';
  FSaveDialog.DefaultExt := 'json';
  FSaveDialog.Options :=
    FSaveDialog.Options + [ofOverwritePrompt];
end;

// ------------------------------------------------------------
// Панель команд
// ------------------------------------------------------------

procedure TMainForm.CreateToolbar;
begin
  FTopPanel := TPanel.Create(Self);
  FTopPanel.Parent := Self;
  FTopPanel.Align := alTop;
  FTopPanel.Height := 48;
  FTopPanel.BevelOuter := bvNone;

  FNewButton := TButton.Create(Self);
  FNewButton.Parent := FTopPanel;
  FNewButton.SetBounds(8, 8, 85, 30);
  FNewButton.Caption := 'Новый';
  FNewButton.OnClick := NewButtonClick;

  FOpenButton := TButton.Create(Self);
  FOpenButton.Parent := FTopPanel;
  FOpenButton.SetBounds(100, 8, 85, 30);
  FOpenButton.Caption := 'Открыть';
  FOpenButton.OnClick := OpenButtonClick;

  FSaveButton := TButton.Create(Self);
  FSaveButton.Parent := FTopPanel;
  FSaveButton.SetBounds(192, 8, 85, 30);
  FSaveButton.Caption := 'Сохранить';
  FSaveButton.OnClick := SaveButtonClick;

  FSaveAsButton := TButton.Create(Self);
  FSaveAsButton.Parent := FTopPanel;
  FSaveAsButton.SetBounds(284, 8, 100, 30);
  FSaveAsButton.Caption := 'Сохранить как';
  FSaveAsButton.OnClick := SaveAsButtonClick;

  FValidateButton := TButton.Create(Self);
  FValidateButton.Parent := FTopPanel;
  FValidateButton.SetBounds(400, 8, 100, 30);
  FValidateButton.Caption := 'Проверить';
  FValidateButton.OnClick := ValidateButtonClick;

  FPrintButton := TButton.Create(Self);
  FPrintButton.Parent := FTopPanel;
  FPrintButton.SetBounds(516, 8, 85, 30);
  FPrintButton.Caption := 'Печать';
  FPrintButton.OnClick := PrintButtonClick;
end;

// ------------------------------------------------------------
// Вкладки
// ------------------------------------------------------------

procedure TMainForm.CreateTabs;
const
  TAB_NAMES: array[0..8] of string = (
    'Общие сведения',
    'Полосы частот',
    'Состав и ТТХ',
    'Передатчик',
    'Приёмник',
    'Антенны',
    'Фидер',
    'ЭМС',
    'Организации'
  );
var
  I: Integer;
  Page: TTabSheet;
  LabelControl: TLabel;
begin
  FPageControl := TPageControl.Create(Self);
  FPageControl.Parent := Self;
  FPageControl.Align := alClient;

  for I := Low(TAB_NAMES) to High(TAB_NAMES) do
  begin
    Page := TTabSheet.Create(Self);
    Page.PageControl := FPageControl;
    Page.Caption := TAB_NAMES[I];
    case I  of
0: begin
FGeneralEditor := TGeneralInformationEditor.Create(Page);
FGeneralEditor.Parent := Page;
FGeneralEditor.Init;
FGeneralEditor.Align := alClient;
FGeneralEditor.Bind(FDocument.GeneralInformation);
end;
1: begin
FFrequencyBandsEditor := TFrequencyBandsEditor.Create(Page);
FFrequencyBandsEditor.Parent := Page;
FFrequencyBandsEditor.Init;
FFrequencyBandsEditor.Align := alClient;
FFrequencyBandsEditor.Bind(FDocument.TransmitterFrequencyBands,  FDocument.ReceiverFrequencyBands);
end;
2: begin
FEquipmentCompositionEditor :=
  TEquipmentCompositionEditor.Create(Page);
FEquipmentCompositionEditor.Parent := Page;
FEquipmentCompositionEditor.Align := alClient;
FEquipmentCompositionEditor.Bind(
  FDocument.EquipmentComposition
);
end;
3: begin
FTransmitterEditor := TTransmitterEditor.Create(Page);
FTransmitterEditor.Parent := Page;
FTransmitterEditor.Align := alClient;
FTransmitterEditor.Bind(FDocument.Transmitter);
end;
4: begin
FReceiverEditor := TReceiverEditor.Create(Page);
FReceiverEditor.Parent := Page;
FReceiverEditor.Align := alClient;
FReceiverEditor.Bind(FDocument.Receiver);
end;
5: begin
 FAntennaEditor := TAntennaEditor.Create(Page);
FAntennaEditor.Parent := Page;
FAntennaEditor.Align := alClient;
FAntennaEditor.Bind(FDocument.Antennas);
end;
6: begin
FFeederEditor := TFeederEditor.Create(Page);
FFeederEditor.Parent := Page;
FFeederEditor.Align := alClient;
FFeederEditor.Bind(FDocument.Feeder);
end;
7: begin
FEmcEditor := TEmcEditor.Create(Page);
FEmcEditor.Parent := Page;
FEmcEditor.Align := alClient;
FEmcEditor.Bind(FDocument.EmcInformation);
end;
8: begin
FOrganizationsEditor := TOrganizationsEditor.Create(Page);
FOrganizationsEditor.Parent := Page;
FOrganizationsEditor.Align := alClient;
end;
9: begin
FOrganizationsEditor.Bind(
  FDocument.Customer,
  FDocument.Developer,
  FDocument.Manufacturer
);
end;
    end;


end;
end;

// ------------------------------------------------------------
// Новый документ
// ------------------------------------------------------------

procedure TMainForm.NewDocument;
begin
  if MessageDlg(
    'Создать новый документ? Текущие несохранённые данные будут потеряны.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FreeAndNil(FDocument);
  FDocument := TTechnicalDocument.Create;

  FCurrentFileName := '';

  UpdateCaption;
  UpdateStatus;
end;

// ------------------------------------------------------------
// Открытие документа
// ------------------------------------------------------------

procedure TMainForm.OpenDocument;
var
  NewData: TTechnicalDocument;
begin
  if not FOpenDialog.Execute then
    Exit;

  NewData := TDataStorage.LoadFromFile(FOpenDialog.FileName);

  try
    FreeAndNil(FDocument);
    FDocument := NewData;

  //////////////////// !!!
  FGeneralEditor.Bind(FDocument.GeneralInformation);
FFrequencyBandsEditor.Bind(
  FDocument.TransmitterFrequencyBands,
  FDocument.ReceiverFrequencyBands
);
FEquipmentCompositionEditor.Bind(
  FDocument.EquipmentComposition
);
FTransmitterEditor.Bind(FDocument.Transmitter);
FReceiverEditor.Bind(FDocument.Receiver);
FAntennaEditor.Bind(FDocument.Antennas);
FFeederEditor.Bind(FDocument.Feeder);
FEmcEditor.Bind(FDocument.EmcInformation);

FOrganizationsEditor.Bind(
  FDocument.Customer,
  FDocument.Developer,
  FDocument.Manufacturer
);

  ///////////////


    NewData := nil;

    FCurrentFileName := FOpenDialog.FileName;

    UpdateCaption;
    UpdateStatus;
  finally
    NewData.Free;
  end;
end;

// ------------------------------------------------------------
// Сохранение документа
// ------------------------------------------------------------

procedure TMainForm.SaveDocument;
begin
  if FCurrentFileName = '' then
  begin
    SaveDocumentAs;
    Exit;
  end;

  TDataStorage.SaveToFile(FDocument, FCurrentFileName);

  UpdateStatus;
end;

// ------------------------------------------------------------
// Сохранить как
// ------------------------------------------------------------

procedure TMainForm.SaveDocumentAs;
begin
  if FSaveDialog.Execute then
  begin
    TDataStorage.SaveToFile(FDocument, FSaveDialog.FileName);

    FCurrentFileName := FSaveDialog.FileName;

    UpdateCaption;
    UpdateStatus;
  end;
end;

// ------------------------------------------------------------
// Проверка документа
// ------------------------------------------------------------

procedure TMainForm.ValidateDocument;
var
  Messages: TArray<TValidationMessage>;
  ErrorExists: Boolean;
  WarningExists: Boolean;
  Item: TValidationMessage;
  Report: string;
begin
  Messages := TDataValidation.Validate(FDocument);

  ErrorExists := TDataValidation.HasErrors(Messages);
  WarningExists := False;

  for Item in Messages do
    if Item.Severity = vsWarning then
      WarningExists := True;

  Report := TDataValidation.FormatMessages(Messages);

  if ErrorExists then
    MessageDlg(Report, mtError, [mbOK], 0)
  else if WarningExists then
    MessageDlg(Report, mtWarning, [mbOK], 0)
  else
    MessageDlg(
      'Проверка завершена. Ошибок и предупреждений нет.',
      mtInformation, [mbOK], 0);
end;

// ------------------------------------------------------------
// Печать
// ------------------------------------------------------------

procedure TMainForm.PrintDocument;
var
  Messages: TArray<TValidationMessage>;
begin
  Messages := TDataValidation.Validate(FDocument);

  if TDataValidation.HasErrors(Messages) then
  begin
    MessageDlg(
      TDataValidation.FormatMessages(Messages),
      mtError, [mbOK], 0);
    Exit;
  end;

  MessageDlg(
    'Проверка пройдена. Модуль формирования PDF будет подключён на следующем этапе.',
    mtInformation, [mbOK], 0);
end;

// ------------------------------------------------------------
// Обновление заголовка
// ------------------------------------------------------------

procedure TMainForm.UpdateCaption;
begin
  if FCurrentFileName = '' then
    Caption := 'КТТД — Новый документ'
  else
    Caption := 'КТТД — ' + ExtractFileName(FCurrentFileName);
end;

// ------------------------------------------------------------
// Строка состояния
// ------------------------------------------------------------

procedure TMainForm.UpdateStatus;
begin
  if FCurrentFileName = '' then
    FStatusBar.SimpleText := 'Новый документ'
  else
    FStatusBar.SimpleText := FCurrentFileName;
end;

// ------------------------------------------------------------
// Обработчики кнопок
// ------------------------------------------------------------

procedure TMainForm.NewButtonClick(Sender: TObject);
begin
  NewDocument;
end;

procedure TMainForm.OpenButtonClick(Sender: TObject);
begin
  try
    OpenDocument;
  except
    on E: Exception do
      MessageDlg(
        'Ошибка открытия документа:' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
  end;
end;

procedure TMainForm.SaveButtonClick(Sender: TObject);
begin
  try
    SaveDocument;
  except
    on E: Exception do
      MessageDlg(
        'Ошибка сохранения документа:' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
  end;
end;

procedure TMainForm.SaveAsButtonClick(Sender: TObject);
begin
  try
    SaveDocumentAs;
  except
    on E: Exception do
      MessageDlg(
        'Ошибка сохранения документа:' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
  end;
end;

procedure TMainForm.ValidateButtonClick(Sender: TObject);
begin
  try
    ValidateDocument;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TMainForm.PrintButtonClick(Sender: TObject);
begin
  try
    PrintDocument;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.

