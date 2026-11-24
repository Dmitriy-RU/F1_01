
unit EditForms;

interface

uses
System.Generics.Collections,
System.Math,
Vcl.ExtCtrls,
Vcl.Grids,
Vcl.Dialogs,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  FrequencyBandDialogFrm,
  DataModel;

type
  TGeneralInformationEditor = class(TScrollBox)
  private
    FInfo: TGeneralInformation;
    FUpdating: Boolean;

    FCodeEdit: TEdit;
    FNameEdit: TEdit;
    FTypeAndNatureEdit: TEdit;
    FInstallationLocationEdit: TEdit;
    FPurposeMemo: TMemo;
    FUsageAreaMemo: TMemo;
    FUserEdit: TEdit;
    FSystemNameEdit: TEdit;
    FITURegistrationCombo: TComboBox;

    procedure AddLabel(const ACaption: string; ATop: Integer);

    function AddEdit(
      const ACaption: string;
      ATop, ATag: Integer
    ): TEdit;

    function AddMemo(
      const ACaption: string;
      ATop, ATag: Integer
    ): TMemo;

    procedure EditChanged(Sender: TObject);
    procedure MemoChanged(Sender: TObject);
    procedure RegistrationChanged(Sender: TObject);

    procedure UpdateTextField(ATag: Integer; const AValue: string);

  public
    procedure Init;
    procedure Bind(AInfo: TGeneralInformation);
  end;


type
  TBandTableControls = record
    GroupBox: TGroupBox;
    Grid: TStringGrid;
    AddButton: TButton;
    EditButton: TButton;
    DeleteButton: TButton;
  end;

  TFrequencyBandsEditor = class(TPanel)
  private
    FTransmitterBands: TObjectList<TFrequencyBand>;
    FReceiverBands: TObjectList<TFrequencyBand>;

    FTransmitterView: TBandTableControls;
    FReceiverView: TBandTableControls;

    procedure CreateTable(
      var AView: TBandTableControls;
      const ACaption: string;
      ATag: Integer
    );

    procedure LayoutControls(Sender: TObject);
    procedure LayoutTable(
      var AView: TBandTableControls;
      ALeft, AWidth: Integer
    );

    function GetBands(ATag: Integer): TObjectList<TFrequencyBand>;
    function GetView(ATag: Integer): TBandTableControls;

    procedure RefreshGrid(ATag: Integer);

    procedure AddBandClick(Sender: TObject);
    procedure EditBandClick(Sender: TObject);
    procedure DeleteBandClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);

  public
    procedure Init;

    procedure Bind(
      ATransmitterBands,
      AReceiverBands: TObjectList<TFrequencyBand>
    );
  end;



type
  TEquipmentModeDialog = class(TForm)
  private
    FEdits: array[0..12] of TEdit;

    procedure SetModeValues(AMode: TEquipmentMode);
    procedure GetModeValues(AMode: TEquipmentMode);

  public
    constructor Create(AOwner: TComponent); override;
    function Execute(AMode: TEquipmentMode): Boolean;
  end;

  TEquipmentCompositionEditor = class(TPanel)
  private
    FComposition: TEquipmentComposition;

    FTransmitterEdit: TEdit;
    FReceiverEdit: TEdit;
    FAntennaEdit: TEdit;
    FDiagramEdit: TEdit;

    FGrid: TStringGrid;
    FAddButton: TButton;
    FEditButton: TButton;
    FDeleteButton: TButton;

    FUpdating: Boolean;

    function AddHeaderEdit(
      const ACaption: string;
      ATop, ATag: Integer
    ): TEdit;

    procedure HeaderChanged(Sender: TObject);

    procedure AddModeClick(Sender: TObject);
    procedure EditModeClick(Sender: TObject);
    procedure DeleteModeClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);

    procedure RefreshGrid;

  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(AComposition: TEquipmentComposition);
  end;



type
  TTransmitterModeDialog = class(TForm)
  private
    FEdits: array[0..10] of TEdit;
    FModulationGrid: TStringGrid;

  FCurrentMode: TTransmitterMode;
  FWorkingParameters: TObjectList<TModulationParameter>;

    procedure LoadMode(AMode: TTransmitterMode);
    function SaveMode(AMode: TTransmitterMode): Boolean;

  procedure RefreshModulationGrid;
    procedure AddModulationClick(Sender: TObject);
    procedure EditModulationClick(Sender: TObject);
    procedure DeleteModulationClick(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(AMode: TTransmitterMode): Boolean;
  end;

  TTransmitterEditor = class(TPanel)
  private
    FTransmitter: TTransmitter;
    FUpdating: Boolean;

    FEdits: array[0..8] of TEdit;
    FGrid: TStringGrid;

    FAddButton: TButton;
    FEditButton: TButton;
    FDeleteButton: TButton;

    procedure GeneralChanged(Sender: TObject);
    procedure RefreshGrid;

    procedure AddModeClick(Sender: TObject);
    procedure EditModeClick(Sender: TObject);
    procedure DeleteModeClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(ATransmitter: TTransmitter);
  end;


type
  TModulationParameterDialog = class(TForm)
  private
    FNameEdit: TEdit;
    FValueEdit: TEdit;
    FUnitEdit: TEdit;

  public
    constructor Create(AOwner: TComponent); override;
    function Execute(AParameter: TModulationParameter): Boolean;
  end;


type
  TReceiverModeDialog = class(TForm)
  private
    FEdits: array[0..14] of TEdit;

    procedure LoadMode(AMode: TReceiverMode);
    function SaveMode(AMode: TReceiverMode): Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    function Execute(AMode: TReceiverMode): Boolean;
  end;

  TReceiverEditor = class(TPanel)
  private
    FReceiver: TReceiver;
    FUpdating: Boolean;

    FEdits: array[0..10] of TEdit;
    FGrid: TStringGrid;

    FAddButton: TButton;
    FEditButton: TButton;
    FDeleteButton: TButton;

    procedure GeneralChanged(Sender: TObject);
    procedure RefreshGrid;

    procedure AddModeClick(Sender: TObject);
    procedure EditModeClick(Sender: TObject);
    procedure DeleteModeClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(AReceiver: TReceiver);
  end;


type
  TAntennaDialog = class(TForm)
  private
    FEdits: array[0..14] of TEdit;
FAntenna: TAntenna;
    function GetEditValue(AIndex: Integer): string;
    procedure SetEditValue(AIndex: Integer; const AValue: string);
    procedure LoadAntenna(AAntenna: TAntenna);
    function SaveAntenna(AAntenna: TAntenna): Boolean;
procedure AcceptClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    function Execute(AAntenna: TAntenna): Boolean;
  end;

  TAntennaEditor = class(TPanel)
  private
    FAntennas: TObjectList<TAntenna>;
    FGrid: TStringGrid;
    FAddButton: TButton;
    FEditButton: TButton;
    FDeleteButton: TButton;

    procedure RefreshGrid;
procedure AddAntenna(Sender: TObject);
procedure EditAntenna(Sender: TObject);
procedure DeleteAntenna(Sender: TObject);
procedure GridDblClick(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(AAntennas: TObjectList<TAntenna>);
  end;

type
  TFeederEditor = class(TPanel)
  private
    FFeeder: TFeeder;
    FEdits: array[0..5] of TEdit;

    procedure GeneralChanged(Sender: TObject);
    procedure LoadData;
    procedure SaveData;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(AFeeder: TFeeder);
  end;

type
  TEmcEditor = class(TPanel)
  private
    FEmcInformation: TEmcInformation;
    FMemo: TMemo;
    FLabel: TLabel;

    procedure SaveData(Sender: TObject);
    procedure LoadData;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(AEmcInformation: TEmcInformation);
  end;

type
  TOrganizationsEditor = class(TScrollBox)
  private
    FCustomer: TOrganizationInfo;
    FDeveloper: TOrganizationInfo;
    FManufacturer: TOrganizationInfo;

    FEdits: array[0..2, 0..2] of TMemo;

    procedure SaveData(Sender: TObject);
    procedure LoadData;
    procedure CreateOrganizationBlock(
      AIndex, ATop: Integer;
      const ATitle: string);
    function GetOrganization(AIndex: Integer): TOrganizationInfo;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(
      ACustomer, ADeveloper, AManufacturer: TOrganizationInfo);
  end;

          implementation

uses
  System.SysUtils;

procedure TGeneralInformationEditor.Init;
var
  Y: Integer;
begin
//  inherited Create(AOwner);

  Align := alClient;
  BorderStyle := bsNone;
  VertScrollBar.Tracking := True;

  FUpdating := False;
  FInfo := nil;

  Y := 16;

  FCodeEdit := AddEdit('1.1. Код РЭС', Y, 1);
  Inc(Y, 58);

  FNameEdit := AddEdit('1.2. Наименование РЭС', Y, 2);
  Inc(Y, 58);

  FTypeAndNatureEdit := AddEdit(
    '1.3. Тип и характер работы РЭС', Y, 3
  );
  Inc(Y, 58);

  FInstallationLocationEdit := AddEdit(
    '1.4. Место установки РЭС', Y, 4
  );
  Inc(Y, 58);

  FPurposeMemo := AddMemo(
    '1.5. Назначение РЭС', Y, 5
  );
  Inc(Y, 108);

  FUsageAreaMemo := AddMemo(
    '1.6. Область применения', Y, 6
  );
  Inc(Y, 108);

  FUserEdit := AddEdit('1.7. Пользователь', Y, 7);
  Inc(Y, 58);

  FSystemNameEdit := AddEdit(
    '1.8. Наименование системы', Y, 8
  );
  Inc(Y, 58);

  AddLabel('1.9. Требуется ли регистрация в МСЭ', Y);

  FITURegistrationCombo := TComboBox.Create(Self);
  FITURegistrationCombo.Parent := Self;
  FITURegistrationCombo.SetBounds(16, Y + 22, 300, 25);
  FITURegistrationCombo.Anchors := [akLeft, akTop];
  FITURegistrationCombo.Style := csDropDownList;
  FITURegistrationCombo.Items.Add('Не указано');
  FITURegistrationCombo.Items.Add('Да');
  FITURegistrationCombo.Items.Add('Нет');
  FITURegistrationCombo.ItemIndex := 0;
  FITURegistrationCombo.OnChange := RegistrationChanged;
end;

procedure TGeneralInformationEditor.AddLabel(
  const ACaption: string;
  ATop: Integer
);
var
  L: TLabel;
begin
  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := ACaption;
  L.Left := 16;
  L.Top := ATop;
end;

function TGeneralInformationEditor.AddEdit(
  const ACaption: string;
  ATop, ATag: Integer
): TEdit;
begin
  AddLabel(ACaption, ATop);

  Result := TEdit.Create(Self);
  Result.Parent := Self;
  Result.SetBounds(16, ATop + 22, 700, 25);
  Result.Anchors := [akLeft, akTop, akRight];
  Result.Tag := ATag;
  Result.OnChange := EditChanged;
end;

function TGeneralInformationEditor.AddMemo(
  const ACaption: string;
  ATop, ATag: Integer
): TMemo;
begin
  AddLabel(ACaption, ATop);

  Result := TMemo.Create(Self);
  Result.Parent := Self;
  Result.SetBounds(16, ATop + 22, 700, 76);
  Result.Anchors := [akLeft, akTop, akRight];
  Result.Tag := ATag;
  Result.ScrollBars := ssVertical;
  Result.WordWrap := True;
  Result.OnChange := MemoChanged;
end;

procedure TGeneralInformationEditor.UpdateTextField(
  ATag: Integer;
  const AValue: string
);
begin
  if FInfo = nil then
    Exit;

  case ATag of
    1: FInfo.Code := AValue;
    2: FInfo.Name := AValue;
    3: FInfo.TypeAndNature := AValue;
    4: FInfo.InstallationLocation := AValue;
    5: FInfo.Purpose := AValue;
    6: FInfo.UsageArea := AValue;
    7: FInfo.User := AValue;
    8: FInfo.SystemName := AValue;
  end;
end;

procedure TGeneralInformationEditor.EditChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;

  UpdateTextField(
    TEdit(Sender).Tag,
    TEdit(Sender).Text
  );
end;

procedure TGeneralInformationEditor.MemoChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;

  UpdateTextField(
    TMemo(Sender).Tag,
    TMemo(Sender).Text
  );
end;

procedure TGeneralInformationEditor.RegistrationChanged(Sender: TObject);
begin
  if FUpdating or (FInfo = nil) then
    Exit;

  FInfo.ITURegistrationRequired.HasValue :=
    FITURegistrationCombo.ItemIndex <> 0;

  if FInfo.ITURegistrationRequired.HasValue then
    FInfo.ITURegistrationRequired.Value :=
      FITURegistrationCombo.ItemIndex = 1;
end;

procedure TGeneralInformationEditor.Bind(AInfo: TGeneralInformation);
begin
  FUpdating := True;
  try
    FInfo := AInfo;

    if FInfo = nil then
    begin
      FCodeEdit.Clear;
      FNameEdit.Clear;
      FTypeAndNatureEdit.Clear;
      FInstallationLocationEdit.Clear;
      FPurposeMemo.Clear;
      FUsageAreaMemo.Clear;
      FUserEdit.Clear;
      FSystemNameEdit.Clear;
      FITURegistrationCombo.ItemIndex := 0;
      Exit;
    end;

    FCodeEdit.Text := FInfo.Code;
    FNameEdit.Text := FInfo.Name;
    FTypeAndNatureEdit.Text := FInfo.TypeAndNature;
    FInstallationLocationEdit.Text := FInfo.InstallationLocation;
    FPurposeMemo.Text := FInfo.Purpose;
    FUsageAreaMemo.Text := FInfo.UsageArea;
    FUserEdit.Text := FInfo.User;
    FSystemNameEdit.Text := FInfo.SystemName;

    if not FInfo.ITURegistrationRequired.HasValue then
      FITURegistrationCombo.ItemIndex := 0
    else if FInfo.ITURegistrationRequired.Value then
      FITURegistrationCombo.ItemIndex := 1
    else
      FITURegistrationCombo.ItemIndex := 2;
  finally
    FUpdating := False;
  end;
end;


procedure TFrequencyBandsEditor.Init;
begin
//  inherited Create(AOwner);

  Align := alClient;
  BevelOuter := bvNone;

  FTransmitterBands := nil;
  FReceiverBands := nil;

  CreateTable(
    FTransmitterView,
    'Полосы частот передатчика (ПРД)',
    0
  );

  CreateTable(
    FReceiverView,
    'Полосы частот приёмника (ПРМ)',
    1
  );

  OnResize := LayoutControls;
  LayoutControls(Self);
end;

procedure TFrequencyBandsEditor.CreateTable(
  var AView: TBandTableControls;
  const ACaption: string;
  ATag: Integer
);
begin
  AView.GroupBox := TGroupBox.Create(Self);
  AView.GroupBox.Parent := Self;
  AView.GroupBox.Caption := ACaption;

  AView.Grid := TStringGrid.Create(Self);
  AView.Grid.Parent := AView.GroupBox;
  AView.Grid.Tag := ATag;

  AView.Grid.ColCount := 3;
  AView.Grid.RowCount := 2;
  AView.Grid.FixedRows := 1;
  AView.Grid.FixedCols := 0;

  AView.Grid.Cells[0, 0] := 'Номер';
  AView.Grid.Cells[1, 0] := 'От, МГц';
  AView.Grid.Cells[2, 0] := 'До, МГц';

  AView.Grid.ColWidths[0] := 90;
  AView.Grid.ColWidths[1] := 110;
  AView.Grid.ColWidths[2] := 110;

  AView.Grid.Options := [
    goFixedVertLine,
    goFixedHorzLine,
    goVertLine,
    goHorzLine,
    goRowSelect
  ];

  AView.Grid.OnDblClick := GridDblClick;

  AView.AddButton := TButton.Create(Self);
  AView.AddButton.Parent := AView.GroupBox;
  AView.AddButton.Caption := 'Добавить';
  AView.AddButton.Tag := ATag;
  AView.AddButton.OnClick := AddBandClick;

  AView.EditButton := TButton.Create(Self);
  AView.EditButton.Parent := AView.GroupBox;
  AView.EditButton.Caption := 'Изменить';
  AView.EditButton.Tag := ATag;
  AView.EditButton.OnClick := EditBandClick;

  AView.DeleteButton := TButton.Create(Self);
  AView.DeleteButton.Parent := AView.GroupBox;
  AView.DeleteButton.Caption := 'Удалить';
  AView.DeleteButton.Tag := ATag;
  AView.DeleteButton.OnClick := DeleteBandClick;
end;

procedure TFrequencyBandsEditor.LayoutControls(Sender: TObject);
var
  W: Integer;
begin
  if ClientWidth < 400 then
    Exit;

  W := (ClientWidth - 24) div 2;

  LayoutTable(FTransmitterView, 8, W);
  LayoutTable(FReceiverView, 16 + W, W);
end;

procedure TFrequencyBandsEditor.LayoutTable(
  var AView: TBandTableControls;
  ALeft, AWidth: Integer
);
var
  H: Integer;
begin
  H := ClientHeight - 16;

  AView.GroupBox.SetBounds(ALeft, 8, AWidth, H);

  AView.Grid.SetBounds(
    12, 24,
    AWidth - 24,
    H - 72
  );

  AView.AddButton.SetBounds(12, H - 38, 90, 28);
  AView.EditButton.SetBounds(110, H - 38, 90, 28);
  AView.DeleteButton.SetBounds(208, H - 38, 90, 28);
end;

function TFrequencyBandsEditor.GetBands(
  ATag: Integer
): TObjectList<TFrequencyBand>;
begin
  if ATag = 0 then
    Result := FTransmitterBands
  else
    Result := FReceiverBands;
end;

function TFrequencyBandsEditor.GetView(
  ATag: Integer
): TBandTableControls;
begin
  if ATag = 0 then
    Result := FTransmitterView
  else
    Result := FReceiverView;
end;

procedure TFrequencyBandsEditor.Bind(
  ATransmitterBands,
  AReceiverBands: TObjectList<TFrequencyBand>
);
begin
  FTransmitterBands := ATransmitterBands;
  FReceiverBands := AReceiverBands;

  RefreshGrid(0);
  RefreshGrid(1);
end;

procedure TFrequencyBandsEditor.RefreshGrid(ATag: Integer);
var
  Bands: TObjectList<TFrequencyBand>;
  View: TBandTableControls;
  I: Integer;
begin
  Bands := GetBands(ATag);
  View := GetView(ATag);

  View.Grid.RowCount := Max(2, Bands.Count + 1);

  for I := 0 to Bands.Count - 1 do
  begin
    View.Grid.Cells[0, I + 1] := Bands[I].Number;

    if Bands[I].MinFrequencyHz.HasValue then
      View.Grid.Cells[1, I + 1] :=
        FormatFloat(
          '0.########',
          Bands[I].MinFrequencyHz.Value / 1000000
        )
    else
      View.Grid.Cells[1, I + 1] := '';

    if Bands[I].MaxFrequencyHz.HasValue then
      View.Grid.Cells[2, I + 1] :=
        FormatFloat(
          '0.########',
          Bands[I].MaxFrequencyHz.Value / 1000000
        )
    else
      View.Grid.Cells[2, I + 1] := '';
  end;

  View.EditButton.Enabled := Bands.Count > 0;
  View.DeleteButton.Enabled := Bands.Count > 0;
end;

procedure TFrequencyBandsEditor.AddBandClick(Sender: TObject);
var
  TagValue: Integer;
  Bands: TObjectList<TFrequencyBand>;
  Band: TFrequencyBand;
  Dialog: TFrequencyBandDialog;
begin
  TagValue := TButton(Sender).Tag;
  Bands := GetBands(TagValue);

  Band := TFrequencyBand.Create;
  try
    Dialog := TFrequencyBandDialog.Create(Self);
    try
      if Dialog.Execute(Band) then
      begin
        Bands.Add(Band);
        Band := nil;
        RefreshGrid(TagValue);
      end;
    finally
      Dialog.Free;
    end;
  finally
    Band.Free;
  end;
end;

procedure TFrequencyBandsEditor.EditBandClick(Sender: TObject);
var
  TagValue: Integer;
  Bands: TObjectList<TFrequencyBand>;
  View: TBandTableControls;
  Index: Integer;
  Dialog: TFrequencyBandDialog;
begin
  TagValue := TButton(Sender).Tag;
  Bands := GetBands(TagValue);
  View := GetView(TagValue);

  Index := View.Grid.Row - 1;

  if (Index < 0) or (Index >= Bands.Count) then
    Exit;

  Dialog := TFrequencyBandDialog.Create(Self);
  try
    if Dialog.Execute(Bands[Index]) then
      RefreshGrid(TagValue);
  finally
    Dialog.Free;
  end;
end;

procedure TFrequencyBandsEditor.DeleteBandClick(Sender: TObject);
var
  TagValue: Integer;
  Bands: TObjectList<TFrequencyBand>;
  View: TBandTableControls;
  Index: Integer;
begin
  TagValue := TButton(Sender).Tag;
  Bands := GetBands(TagValue);
  View := GetView(TagValue);

  Index := View.Grid.Row - 1;

  if (Index < 0) or (Index >= Bands.Count) then
    Exit;

  if MessageDlg(
    'Удалить выбранную полосу частот?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) <> mrYes then
    Exit;

  Bands.Delete(Index);
  RefreshGrid(TagValue);
end;

procedure TFrequencyBandsEditor.GridDblClick(Sender: TObject);
var
  TagValue: Integer;
  View: TBandTableControls;
begin
  TagValue := TStringGrid(Sender).Tag;
  View := GetView(TagValue);

  if View.EditButton.Enabled then
    EditBandClick(View.EditButton);
end;


constructor TEquipmentModeDialog.Create(AOwner: TComponent);
const
  Captions: array[0..12] of string = (
    '3.5. Номер режима',
    '3.6. Краткая характеристика режима',
    '3.6. Тип передачи',
    '3.7. Номер полосы частот',
    '3.8. Номер элементарного оборудования',
    '3.9. Номер элементарной антенны',
    '3.10. Номер связанной антенны',
    '3.11. Наименование связанного оборудования',
    '3.12. Наименование характеристики',
    '3.13. Значение характеристики',
    '3.14. Единица измерения',
    '',
    ''
  );
var
  Scroll: TScrollBox;
  L: TLabel;
  B: TButton;
  I: Integer;
  Y: Integer;
begin
  inherited CreateNew(AOwner);

  Caption := 'Режим работы';
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 520;
  ClientHeight := 560;

  Scroll := TScrollBox.Create(Self);
  Scroll.Parent := Self;
  Scroll.SetBounds(0, 0, ClientWidth, 490);
  Scroll.Anchors := [akLeft, akTop, akRight, akBottom];

  Y := 12;

  for I := 0 to 10 do
  begin
    L := TLabel.Create(Self);
    L.Parent := Scroll;
    L.Caption := Captions[I];
    L.SetBounds(16, Y, 470, 18);

    FEdits[I] := TEdit.Create(Self);
    FEdits[I].Parent := Scroll;
    FEdits[I].SetBounds(16, Y + 21, 470, 25);
    FEdits[I].Anchors := [akLeft, akTop, akRight];

    Inc(Y, 58);
  end;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'OK';
  B.ModalResult := mrOK;
  B.SetBounds(330, 510, 80, 30);
  B.Default := True;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Отмена';
  B.ModalResult := mrCancel;
  B.SetBounds(420, 510, 80, 30);
  B.Cancel := True;
end;

procedure TEquipmentModeDialog.SetModeValues(
  AMode: TEquipmentMode
);
begin
  FEdits[0].Text := AMode.ModeNumber;
  FEdits[1].Text := AMode.ModeDescription;
  FEdits[2].Text := AMode.TransmissionType;
  FEdits[3].Text := AMode.FrequencyBandNumber;
  FEdits[4].Text := AMode.ElementaryEquipmentNumber;
  FEdits[5].Text := AMode.ElementaryAntennaNumber;
  FEdits[6].Text := AMode.RelatedAntennaNumber;
  FEdits[7].Text := AMode.RelatedEquipmentName;
  FEdits[8].Text := AMode.CharacteristicName;
  FEdits[9].Text := AMode.CharacteristicValue;
  FEdits[10].Text := AMode.CharacteristicUnit;
end;

procedure TEquipmentModeDialog.GetModeValues(
  AMode: TEquipmentMode
);
begin
  AMode.ModeNumber := Trim(FEdits[0].Text);
  AMode.ModeDescription := Trim(FEdits[1].Text);
  AMode.TransmissionType := Trim(FEdits[2].Text);
  AMode.FrequencyBandNumber := Trim(FEdits[3].Text);
  AMode.ElementaryEquipmentNumber := Trim(FEdits[4].Text);
  AMode.ElementaryAntennaNumber := Trim(FEdits[5].Text);
  AMode.RelatedAntennaNumber := Trim(FEdits[6].Text);
  AMode.RelatedEquipmentName := Trim(FEdits[7].Text);
  AMode.CharacteristicName := Trim(FEdits[8].Text);
  AMode.CharacteristicValue := Trim(FEdits[9].Text);
  AMode.CharacteristicUnit := Trim(FEdits[10].Text);
end;

function TEquipmentModeDialog.Execute(
  AMode: TEquipmentMode
): Boolean;
begin
  SetModeValues(AMode);

  repeat
    Result := ShowModal = mrOK;

    if not Result then
      Exit;

    if Trim(FEdits[0].Text) = '' then
    begin
      MessageDlg(
        'Укажите номер режима.',
        mtWarning, [mbOK], 0
      );
      Continue;
    end;

    GetModeValues(AMode);
    Exit(True);
  until False;
end;


constructor TEquipmentCompositionEditor.Create(
  AOwner: TComponent
);
var
  L: TLabel;
begin
  inherited Create(AOwner);

  Align := alClient;
  BevelOuter := bvNone;

  FComposition := nil;
  FUpdating := False;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := '3.1. Обозначение передатчика';
  L.SetBounds(16, 12, 300, 18);

  FTransmitterEdit := AddHeaderEdit('', 34, 1);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := '3.2. Обозначение приёмника';
  L.SetBounds(16, 72, 300, 18);

  FReceiverEdit := AddHeaderEdit('', 94, 2);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := '3.3. Обозначение антенны';
  L.SetBounds(16, 132, 300, 18);

  FAntennaEdit := AddHeaderEdit('', 154, 3);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := '3.4. Лист структурной схемы';
  L.SetBounds(16, 192, 300, 18);

  FDiagramEdit := AddHeaderEdit('', 214, 4);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Режимы работы';
  L.SetBounds(16, 258, 300, 20);

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.SetBounds(16, 282, 900, 300);
  //FGrid.Anchors := [akLeft, akTop, akRight, akBottom];

  FGrid.ColCount := 6;
  FGrid.RowCount := 2;
  FGrid.FixedRows := 1;
  FGrid.FixedCols := 0;

  FGrid.Cells[0, 0] := 'Режим';
  FGrid.Cells[1, 0] := 'Описание';
  FGrid.Cells[2, 0] := 'Полоса';
  FGrid.Cells[3, 0] := 'Характеристика';
  FGrid.Cells[4, 0] := 'Значение';
  FGrid.Cells[5, 0] := 'Единица';

  FGrid.ColWidths[0] := 65;
  FGrid.ColWidths[1] := 190;
  FGrid.ColWidths[2] := 65;
  FGrid.ColWidths[3] := 190;
  FGrid.ColWidths[4] := 100;
  FGrid.ColWidths[5] := 75;

  FGrid.Options := [
    goFixedVertLine,
    goFixedHorzLine,
    goVertLine,
    goHorzLine,
    goRowSelect
  ];

  FGrid.OnDblClick := GridDblClick;

  FAddButton := TButton.Create(Self);
  FAddButton.Parent := Self;
  FAddButton.Caption := 'Добавить режим';
  FAddButton.SetBounds(16, 594, 120, 30);
 // FAddButton.Anchors := [akLeft, akBottom];
  FAddButton.OnClick := AddModeClick;

  FEditButton := TButton.Create(Self);
  FEditButton.Parent := Self;
  FEditButton.Caption := 'Изменить';
  FEditButton.SetBounds(146, 594, 100, 30);
//  FEditButton.Anchors := [akLeft, akBottom];
  FEditButton.OnClick := EditModeClick;

  FDeleteButton := TButton.Create(Self);
  FDeleteButton.Parent := Self;
  FDeleteButton.Caption := 'Удалить';
  FDeleteButton.SetBounds(256, 594, 100, 30);
 // FDeleteButton.Anchors := [akLeft, akBottom];
  FDeleteButton.OnClick := DeleteModeClick;
end;

function TEquipmentCompositionEditor.AddHeaderEdit(
  const ACaption: string;
  ATop, ATag: Integer
): TEdit;
begin
  Result := TEdit.Create(Self);
  Result.Parent := Self;
  Result.SetBounds(16, ATop, 700, 25);
  Result.Anchors := [akLeft, akTop, akRight];
  Result.Tag := ATag;
  Result.OnChange := HeaderChanged;
end;

procedure TEquipmentCompositionEditor.HeaderChanged(Sender: TObject);
begin
  if FUpdating or (FComposition = nil) then
    Exit;

  case TEdit(Sender).Tag of
    1: FComposition.TransmitterReference := TEdit(Sender).Text;
    2: FComposition.ReceiverReference := TEdit(Sender).Text;
    3: FComposition.AntennaReference := TEdit(Sender).Text;
    4: FComposition.StructuralDiagramSheet := TEdit(Sender).Text;
  end;
end;

procedure TEquipmentCompositionEditor.Bind(
  AComposition: TEquipmentComposition
);
begin
  FUpdating := True;
  try
    FComposition := AComposition;

    if FComposition = nil then
    begin
      FTransmitterEdit.Clear;
      FReceiverEdit.Clear;
      FAntennaEdit.Clear;
      FDiagramEdit.Clear;
    end
    else
    begin
      FTransmitterEdit.Text := FComposition.TransmitterReference;
      FReceiverEdit.Text := FComposition.ReceiverReference;
      FAntennaEdit.Text := FComposition.AntennaReference;
      FDiagramEdit.Text := FComposition.StructuralDiagramSheet;
    end;
  finally
    FUpdating := False;
  end;

  RefreshGrid;
end;

procedure TEquipmentCompositionEditor.RefreshGrid;
var
  I: Integer;
  Mode: TEquipmentMode;
begin
  if FComposition = nil then
  begin
    FGrid.RowCount := 2;
    FGrid.Cells[0, 1] := '';
    FGrid.Cells[1, 1] := '';
    FGrid.Cells[2, 1] := '';
    FGrid.Cells[3, 1] := '';
    FGrid.Cells[4, 1] := '';
    FGrid.Cells[5, 1] := '';
    FEditButton.Enabled := False;
    FDeleteButton.Enabled := False;
    Exit;
  end;

  FGrid.RowCount := Max(2, FComposition.Modes.Count + 1);

  for I := 0 to FComposition.Modes.Count - 1 do
  begin
    Mode := FComposition.Modes[I];

    FGrid.Cells[0, I + 1] := Mode.ModeNumber;
    FGrid.Cells[1, I + 1] := Mode.ModeDescription;
    FGrid.Cells[2, I + 1] := Mode.FrequencyBandNumber;
    FGrid.Cells[3, I + 1] := Mode.CharacteristicName;
    FGrid.Cells[4, I + 1] := Mode.CharacteristicValue;
    FGrid.Cells[5, I + 1] := Mode.CharacteristicUnit;
  end;

  FEditButton.Enabled := FComposition.Modes.Count > 0;
  FDeleteButton.Enabled := FComposition.Modes.Count > 0;
end;

procedure TEquipmentCompositionEditor.AddModeClick(Sender: TObject);
var
  Mode: TEquipmentMode;
  Dialog: TEquipmentModeDialog;
begin
  if FComposition = nil then
    Exit;

  Mode := TEquipmentMode.Create;
  try
    Dialog := TEquipmentModeDialog.Create(Self);
    try
      if Dialog.Execute(Mode) then
      begin
        FComposition.Modes.Add(Mode);
        Mode := nil;
        RefreshGrid;
      end;
    finally
      Dialog.Free;
    end;
  finally
    Mode.Free;
  end;
end;

procedure TEquipmentCompositionEditor.EditModeClick(Sender: TObject);
var
  Index: Integer;
  Dialog: TEquipmentModeDialog;
begin
  if FComposition = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FComposition.Modes.Count) then
    Exit;

  Dialog := TEquipmentModeDialog.Create(Self);
  try
    if Dialog.Execute(FComposition.Modes[Index]) then
      RefreshGrid;
  finally
    Dialog.Free;
  end;
end;

procedure TEquipmentCompositionEditor.DeleteModeClick(Sender: TObject);
var
  Index: Integer;
begin
  if FComposition = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FComposition.Modes.Count) then
    Exit;

  if MessageDlg(
    'Удалить выбранный режим?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) <> mrYes then
    Exit;

  FComposition.Modes.Delete(Index);
  RefreshGrid;
end;

procedure TEquipmentCompositionEditor.GridDblClick(Sender: TObject);
begin
  if FEditButton.Enabled then
    EditModeClick(FEditButton);
end;


constructor TModulationParameterDialog.Create(AOwner: TComponent);
var
  L: TLabel;
  B: TButton;
begin
  inherited CreateNew(AOwner);

  Caption := 'Параметр модуляции';
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 400;
  ClientHeight := 220;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Наименование';
  L.SetBounds(16, 12, 300, 18);

  FNameEdit := TEdit.Create(Self);
  FNameEdit.Parent := Self;
  FNameEdit.SetBounds(16, 32, 368, 25);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Значение';
  L.SetBounds(16, 66, 300, 18);

  FValueEdit := TEdit.Create(Self);
  FValueEdit.Parent := Self;
  FValueEdit.SetBounds(16, 86, 368, 25);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Единица измерения';
  L.SetBounds(16, 120, 300, 18);

  FUnitEdit := TEdit.Create(Self);
  FUnitEdit.Parent := Self;
  FUnitEdit.SetBounds(16, 140, 180, 25);

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'OK';
  B.ModalResult := mrOK;
  B.SetBounds(214, 178, 80, 30);
  B.Default := True;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Отмена';
  B.ModalResult := mrCancel;
  B.SetBounds(304, 178, 80, 30);
  B.Cancel := True;
end;

function TModulationParameterDialog.Execute(
  AParameter: TModulationParameter
): Boolean;
begin
  FNameEdit.Text := AParameter.Name;
  FValueEdit.Text := AParameter.Value;
  FUnitEdit.Text := AParameter.UnitName;

  Result := ShowModal = mrOK;

  if Result then
  begin
    AParameter.Name := Trim(FNameEdit.Text);
    AParameter.Value := Trim(FValueEdit.Text);
    AParameter.UnitName := Trim(FUnitEdit.Text);
  end;
end;


constructor TTransmitterModeDialog.Create(AOwner: TComponent);
const
  Captions: array[0..10] of string = (
    '4.4. Класс излучения',
    '4.5. Описание класса излучения',
    '4.6. Номер полосы частот',
    '4.7. Ширина полосы на уровне -3 дБ, Гц',
    '4.8. Ширина полосы на уровне -30 дБ, Гц',
    '4.9. Дополнительный уровень, дБ',
    '4.10. Вид мощности излучения',
    '4.11. Минимальная мощность, дБВт',
    '4.12. Максимальная мощность, дБВт',
    '4.13. Максимальная спектральная плотность мощности, дБВт/Гц',
    'Номер режима (ссылка на раздел 3)'
  );
var
  Scroll: TScrollBox;
  L: TLabel;
  B: TButton;
  I, Y: Integer;
begin
  inherited CreateNew(AOwner);

FWorkingParameters := TObjectList<TModulationParameter>.Create(True);
FCurrentMode := nil;

  Caption := 'Характеристики режима передатчика';
  BorderStyle := bsSizeable;
  Position := poOwnerFormCenter;
  ClientWidth := 650;
  ClientHeight := 690;

  Scroll := TScrollBox.Create(Self);
  Scroll.Parent := Self;
  Scroll.SetBounds(0, 0, 650, 490);
  Scroll.Anchors := [akLeft, akTop, akRight, akBottom];

  Y := 12;

  for I := 0 to 10 do
  begin
    L := TLabel.Create(Self);
    L.Parent := Scroll;
    L.Caption := Captions[I];
    L.SetBounds(16, Y, 580, 18);

    FEdits[I] := TEdit.Create(Self);
    FEdits[I].Parent := Scroll;
    FEdits[I].SetBounds(16, Y + 21, 580, 25);
    FEdits[I].Anchors := [akLeft, akTop, akRight];

    Inc(Y, 58);
  end;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := '4.14. Параметры модуляции';
  L.SetBounds(16, 500, 300, 18);

  FModulationGrid := TStringGrid.Create(Self);
  FModulationGrid.Parent := Self;
  FModulationGrid.SetBounds(16, 522, 450, 105);
  FModulationGrid.Anchors := [akLeft, akRight, akBottom];

  FModulationGrid.ColCount := 3;
  FModulationGrid.RowCount := 2;
  FModulationGrid.FixedRows := 1;
  FModulationGrid.FixedCols := 0;

  FModulationGrid.Cells[0, 0] := 'Наименование';
  FModulationGrid.Cells[1, 0] := 'Значение';
  FModulationGrid.Cells[2, 0] := 'Единица';

  FModulationGrid.ColWidths[0] := 190;
  FModulationGrid.ColWidths[1] := 140;
  FModulationGrid.ColWidths[2] := 90;

  FModulationGrid.Options := [
    goFixedVertLine,
    goFixedHorzLine,
    goVertLine,
    goHorzLine,
    goRowSelect
  ];

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Добавить';
  B.SetBounds(476, 522, 140, 28);
  B.Anchors := [akRight, akBottom];
  B.OnClick := AddModulationClick;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Изменить';
  B.SetBounds(476, 556, 140, 28);
  B.Anchors := [akRight, akBottom];
  B.OnClick := EditModulationClick;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Удалить';
  B.SetBounds(476, 590, 140, 28);
  B.Anchors := [akRight, akBottom];
  B.OnClick := DeleteModulationClick;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'OK';
  B.ModalResult := mrOK;
  B.SetBounds(446, 644, 80, 30);
  B.Anchors := [akRight, akBottom];
  B.Default := True;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Отмена';
  B.ModalResult := mrCancel;
  B.SetBounds(536, 644, 80, 30);
  B.Anchors := [akRight, akBottom];
  B.Cancel := True;
end;

destructor TTransmitterModeDialog.Destroy;
begin
  FWorkingParameters.Free;
  inherited Destroy;
end;

procedure TTransmitterModeDialog.LoadMode(
  AMode: TTransmitterMode
);
begin

  FCurrentMode := AMode;

  FEdits[0].Text := AMode.EmissionClass;
  FEdits[1].Text := AMode.EmissionClassDescription;
  FEdits[2].Text := AMode.FrequencyBandNumber;

  if AMode.BandwidthAt3DbHz.HasValue then
    FEdits[3].Text := FloatToStr(AMode.BandwidthAt3DbHz.Value)
  else
    FEdits[3].Clear;

  if AMode.BandwidthAt30DbHz.HasValue then
    FEdits[4].Text := FloatToStr(AMode.BandwidthAt30DbHz.Value)
  else
    FEdits[4].Clear;

  if AMode.BandwidthAdditionalLevelDb.HasValue then
    FEdits[5].Text := FloatToStr(AMode.BandwidthAdditionalLevelDb.Value)
  else
    FEdits[5].Clear;

  FEdits[6].Text := AMode.PowerEmissionKind;

  if AMode.MinPowerDbW.HasValue then
    FEdits[7].Text := FloatToStr(AMode.MinPowerDbW.Value)
  else
    FEdits[7].Clear;

  if AMode.MaxPowerDbW.HasValue then
    FEdits[8].Text := FloatToStr(AMode.MaxPowerDbW.Value)
  else
    FEdits[8].Clear;

  if AMode.MaxPowerSpectralDensityDbWHz.HasValue then
    FEdits[9].Text :=
      FloatToStr(AMode.MaxPowerSpectralDensityDbWHz.Value)
  else
    FEdits[9].Clear;

  FEdits[10].Text := AMode.ModeNumber;

FCurrentMode := AMode;

FWorkingParameters.Clear;

for var P in AMode.ModulationParameters do
begin
  var NewP := TModulationParameter.Create;
  NewP.Name := P.Name;
  NewP.Value := P.Value;
  NewP.UnitName := P.UnitName;
  FWorkingParameters.Add(NewP);
end;

RefreshModulationGrid;

end;

procedure TTransmitterModeDialog.RefreshModulationGrid;
var
  I: Integer;
begin
  FModulationGrid.RowCount :=
    Max(2, FWorkingParameters.Count + 1);

  for I := 0 to FWorkingParameters.Count - 1 do
  begin
    FModulationGrid.Cells[0, I + 1] :=
      FWorkingParameters[I].Name;

    FModulationGrid.Cells[1, I + 1] :=
      FWorkingParameters[I].Value;

    FModulationGrid.Cells[2, I + 1] :=
      FWorkingParameters[I].UnitName;
  end;
end;

function TTransmitterModeDialog.SaveMode(
  AMode: TTransmitterMode
): Boolean;
var
  V: Double;
  Optional: TOptionalValue<Double>;

  function ReadOptional(
    AIndex: Integer;
    out AValue: TOptionalValue<Double>
  ): Boolean;
  begin
    AValue.HasValue := False;
    AValue.Value := 0;

    if Trim(FEdits[AIndex].Text) = '' then
      Exit(True);

    Result := TryStrToFloat(Trim(FEdits[AIndex].Text), V);

    if not Result then
      Exit;

    AValue.HasValue := True;
    AValue.Value := V;
  end;

begin
  Result := False;

  if Trim(FEdits[10].Text) = '' then
  begin
    MessageDlg(
      'Укажите номер режима.',
      mtWarning, [mbOK], 0
    );
    Exit;
  end;

  if not ReadOptional(3, Optional) then
    Exit;
  AMode.BandwidthAt3DbHz := Optional;

  if not ReadOptional(4, Optional) then
    Exit;
  AMode.BandwidthAt30DbHz := Optional;

  if not ReadOptional(5, Optional) then
    Exit;
  AMode.BandwidthAdditionalLevelDb := Optional;

  if not ReadOptional(7, Optional) then
    Exit;
  AMode.MinPowerDbW := Optional;

  if not ReadOptional(8, Optional) then
    Exit;
  AMode.MaxPowerDbW := Optional;

  if not ReadOptional(9, Optional) then
    Exit;
  AMode.MaxPowerSpectralDensityDbWHz := Optional;

  AMode.EmissionClass := Trim(FEdits[0].Text);
  AMode.EmissionClassDescription := Trim(FEdits[1].Text);
  AMode.FrequencyBandNumber := Trim(FEdits[2].Text);
  AMode.PowerEmissionKind := Trim(FEdits[6].Text);
  AMode.ModeNumber := Trim(FEdits[10].Text);

  Result := True;
end;

function TTransmitterModeDialog.Execute(
  AMode: TTransmitterMode
): Boolean;
begin
  LoadMode(AMode);

  repeat
    Result := ShowModal = mrOK;

    if not Result then
      Exit;

    if SaveMode(AMode) then
      Exit(True);

    MessageDlg(
      'Одно или несколько числовых полей содержат некорректное значение.',
      mtWarning, [mbOK], 0
    );
  until False;
end;


procedure TTransmitterModeDialog.AddModulationClick(Sender: TObject);
var
  P: TModulationParameter;
  Dialog: TModulationParameterDialog;
begin
  if FCurrentMode = nil then
    Exit;

  P := TModulationParameter.Create;
  try
    Dialog := TModulationParameterDialog.Create(Self);
    try
      if Dialog.Execute(P) then
      begin
        FCurrentMode.ModulationParameters.Add(P);
        P := nil;
        RefreshModulationGrid;
      end;
    finally
      Dialog.Free;
    end;
  finally
    P.Free;
  end;
end;

procedure TTransmitterModeDialog.EditModulationClick(Sender: TObject);
var
  Index: Integer;
  P: TModulationParameter;
  Dialog: TModulationParameterDialog;
begin
  if FCurrentMode = nil then
    Exit;

  Index := FModulationGrid.Row - 1;

  if (Index < 0) or
     (Index >= FCurrentMode.ModulationParameters.Count) then
    Exit;

  P := FCurrentMode.ModulationParameters[Index];

  Dialog := TModulationParameterDialog.Create(Self);
  try
    if Dialog.Execute(P) then
      RefreshModulationGrid;
  finally
    Dialog.Free;
  end;
end;

procedure TTransmitterModeDialog.DeleteModulationClick(Sender: TObject);
var
  Index: Integer;
begin
  if FCurrentMode = nil then
    Exit;

  Index := FModulationGrid.Row - 1;

  if (Index < 0) or
     (Index >= FCurrentMode.ModulationParameters.Count) then
    Exit;

  if MessageDlg(
    'Удалить выбранный параметр модуляции?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) <> mrYes then
    Exit;

  FCurrentMode.ModulationParameters.Delete(Index);
  RefreshModulationGrid;
end;


constructor TTransmitterEditor.Create(AOwner: TComponent);
const
  Captions: array[0..8] of string = (
    '4.1. Рабочие частоты',
    '4.2. Шаг сетки частот',
    '4.3. Вид перестройки частоты',
    '4.15. Тип выходного устройства',
    '4.16. Относительная нестабильность частоты',
    '4.17. Гармоники ниже 3Fp, дБ',
    '4.18. Гармоники выше 3Fp, дБ',
    '4.19. Другие побочные излучения',
    '4.20. Уровень шумового излучения'
  );
var
  Scroll: TScrollBox;
  L: TLabel;
  I, Y: Integer;
begin
  inherited Create(AOwner);

  Align := alClient;
  BevelOuter := bvNone;
  FTransmitter := nil;
  FUpdating := False;

  Scroll := TScrollBox.Create(Self);
  Scroll.Parent := Self;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;

  Y := 12;

  for I := 0 to 8 do
  begin
    L := TLabel.Create(Self);
    L.Parent := Scroll;
    L.Caption := Captions[I];
    L.SetBounds(16, Y, 600, 18);

    FEdits[I] := TEdit.Create(Self);
    FEdits[I].Parent := Scroll;
    FEdits[I].SetBounds(16, Y + 22, 700, 25);
    FEdits[I].Anchors := [akLeft, akTop, akRight];
    FEdits[I].Tag := I;
    FEdits[I].OnChange := GeneralChanged;

    Inc(Y, 58);
  end;

  L := TLabel.Create(Self);
  L.Parent := Scroll;
  L.Caption := 'Характеристики по режимам';
  L.SetBounds(16, Y + 8, 400, 20);

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Scroll;
  FGrid.SetBounds(16, Y + 34, 900, 240);
  FGrid.Anchors := [akLeft, akTop, akRight];

  FGrid.ColCount := 8;
  FGrid.RowCount := 2;
  FGrid.FixedRows := 1;
  FGrid.FixedCols := 0;

  FGrid.Cells[0, 0] := 'Режим';
  FGrid.Cells[1, 0] := 'Класс излучения';
  FGrid.Cells[2, 0] := 'Полоса';
  FGrid.Cells[3, 0] := 'Ширина -3 дБ';
  FGrid.Cells[4, 0] := 'Ширина -30 дБ';
  FGrid.Cells[5, 0] := 'Вид мощности';
  FGrid.Cells[6, 0] := 'Мин. мощность';
  FGrid.Cells[7, 0] := 'Макс. мощность';

  FGrid.ColWidths[0] := 55;
  FGrid.ColWidths[1] := 120;
  FGrid.ColWidths[2] := 55;
  FGrid.ColWidths[3] := 100;
  FGrid.ColWidths[4] := 100;
  FGrid.ColWidths[5] := 90;
  FGrid.ColWidths[6] := 100;
  FGrid.ColWidths[7] := 100;

  FGrid.Options := [
    goFixedVertLine,
    goFixedHorzLine,
    goVertLine,
    goHorzLine,
    goRowSelect
  ];

  FGrid.OnDblClick := GridDblClick;

  FAddButton := TButton.Create(Self);
  FAddButton.Parent := Scroll;
  FAddButton.Caption := 'Добавить режим';
  FAddButton.SetBounds(16, Y + 284, 120, 30);

  FEditButton := TButton.Create(Self);
  FEditButton.Parent := Scroll;
  FEditButton.Caption := 'Изменить';
  FEditButton.SetBounds(146, Y + 284, 100, 30);

  FDeleteButton := TButton.Create(Self);
  FDeleteButton.Parent := Scroll;
  FDeleteButton.Caption := 'Удалить';
  FDeleteButton.SetBounds(256, Y + 284, 100, 30);

  FAddButton.OnClick := AddModeClick;
  FEditButton.OnClick := EditModeClick;
  FDeleteButton.OnClick := DeleteModeClick;
end;

procedure TTransmitterEditor.GeneralChanged(Sender: TObject);
var
  V: Double;
  Optional: TOptionalValue<Double>;
  Index: Integer;
begin
  if FUpdating or (FTransmitter = nil) then
    Exit;

  Index := TEdit(Sender).Tag;

  case Index of
    0: FTransmitter.OperatingFrequencies := TEdit(Sender).Text;
    1: FTransmitter.FrequencyGridStep := TEdit(Sender).Text;
    2: FTransmitter.FrequencyTuningType := TEdit(Sender).Text;
    3: FTransmitter.OutputDeviceType := TEdit(Sender).Text;
    4: FTransmitter.RelativeFrequencyInstability := TEdit(Sender).Text;
    5, 6, 8:
      begin
        Optional.HasValue := False;
        Optional.Value := 0;

        if Trim(TEdit(Sender).Text) <> '' then
        begin
          if not TryStrToFloat(Trim(TEdit(Sender).Text), V) then
            Exit;

          Optional.HasValue := True;
          Optional.Value := V;
        end;

        case Index of
          5: FTransmitter.HarmonicsBelow3FpDb := Optional;
          6: FTransmitter.HarmonicsAbove3FpDb := Optional;
          8: FTransmitter.NoiseEmissionLevel := Optional;
        end;
      end;
    7: FTransmitter.OtherSpuriousEmissions := TEdit(Sender).Text;
  end;
end;

procedure TTransmitterEditor.Bind(ATransmitter: TTransmitter);
begin
  FUpdating := True;
  try
    FTransmitter := ATransmitter;

    if FTransmitter = nil then
    begin
      for var I := 0 to 8 do
        FEdits[I].Clear;
    end
    else
    begin
      FEdits[0].Text := FTransmitter.OperatingFrequencies;
      FEdits[1].Text := FTransmitter.FrequencyGridStep;
      FEdits[2].Text := FTransmitter.FrequencyTuningType;
      FEdits[3].Text := FTransmitter.OutputDeviceType;
      FEdits[4].Text := FTransmitter.RelativeFrequencyInstability;

      if FTransmitter.HarmonicsBelow3FpDb.HasValue then
        FEdits[5].Text :=
          FloatToStr(FTransmitter.HarmonicsBelow3FpDb.Value)
      else
        FEdits[5].Clear;

      if FTransmitter.HarmonicsAbove3FpDb.HasValue then
        FEdits[6].Text :=
          FloatToStr(FTransmitter.HarmonicsAbove3FpDb.Value)
      else
        FEdits[6].Clear;

      FEdits[7].Text := FTransmitter.OtherSpuriousEmissions;

      if FTransmitter.NoiseEmissionLevel.HasValue then
        FEdits[8].Text :=
          FloatToStr(FTransmitter.NoiseEmissionLevel.Value)
      else
        FEdits[8].Clear;
    end;
  finally
    FUpdating := False;
  end;

  RefreshGrid;
end;

procedure TTransmitterEditor.RefreshGrid;
var
  I: Integer;
  Mode: TTransmitterMode;
begin
  if FTransmitter = nil then
  begin
    FGrid.RowCount := 2;
    FEditButton.Enabled := False;
    FDeleteButton.Enabled := False;
    Exit;
  end;

  FGrid.RowCount := Max(2, FTransmitter.Modes.Count + 1);

  for I := 0 to FTransmitter.Modes.Count - 1 do
  begin
    Mode := FTransmitter.Modes[I];

    FGrid.Cells[0, I + 1] := Mode.ModeNumber;
    FGrid.Cells[1, I + 1] := Mode.EmissionClass;
    FGrid.Cells[2, I + 1] := Mode.FrequencyBandNumber;

    if Mode.BandwidthAt3DbHz.HasValue then
      FGrid.Cells[3, I + 1] :=
        FloatToStr(Mode.BandwidthAt3DbHz.Value)
    else
      FGrid.Cells[3, I + 1] := '';

    if Mode.BandwidthAt30DbHz.HasValue then
      FGrid.Cells[4, I + 1] :=
        FloatToStr(Mode.BandwidthAt30DbHz.Value)
    else
      FGrid.Cells[4, I + 1] := '';

    FGrid.Cells[5, I + 1] := Mode.PowerEmissionKind;

    if Mode.MinPowerDbW.HasValue then
      FGrid.Cells[6, I + 1] :=
        FloatToStr(Mode.MinPowerDbW.Value)
    else
      FGrid.Cells[6, I + 1] := '';

    if Mode.MaxPowerDbW.HasValue then
      FGrid.Cells[7, I + 1] :=
        FloatToStr(Mode.MaxPowerDbW.Value)
    else
      FGrid.Cells[7, I + 1] := '';
  end;

  FEditButton.Enabled := FTransmitter.Modes.Count > 0;
  FDeleteButton.Enabled := FTransmitter.Modes.Count > 0;
end;

procedure TTransmitterEditor.AddModeClick(Sender: TObject);
var
  Mode: TTransmitterMode;
  Dialog: TTransmitterModeDialog;
begin
  if FTransmitter = nil then
    Exit;

  Mode := TTransmitterMode.Create;
  try
    Dialog := TTransmitterModeDialog.Create(Self);
    try
      if Dialog.Execute(Mode) then
      begin
        FTransmitter.Modes.Add(Mode);
        Mode := nil;
        RefreshGrid;
      end;
    finally
      Dialog.Free;
    end;
  finally
    Mode.Free;
  end;
end;

procedure TTransmitterEditor.EditModeClick(Sender: TObject);
var
  Index: Integer;
  Dialog: TTransmitterModeDialog;
begin
  if FTransmitter = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FTransmitter.Modes.Count) then
    Exit;

  Dialog := TTransmitterModeDialog.Create(Self);
  try
    if Dialog.Execute(FTransmitter.Modes[Index]) then
      RefreshGrid;
  finally
    Dialog.Free;
  end;
end;

procedure TTransmitterEditor.DeleteModeClick(Sender: TObject);
var
  Index: Integer;
begin
  if FTransmitter = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FTransmitter.Modes.Count) then
    Exit;

  if MessageDlg(
    'Удалить характеристики выбранного режима передатчика?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) <> mrYes then
    Exit;

  FTransmitter.Modes.Delete(Index);
  RefreshGrid;
end;

procedure TTransmitterEditor.GridDblClick(Sender: TObject);
begin
  if FEditButton.Enabled then
    EditModeClick(FEditButton);
end;

// 555


constructor TReceiverModeDialog.Create(AOwner: TComponent);
const
  Captions: array[0..14] of string = (
    'Номер режима (ссылка на раздел 3)',
    '5.4. Принимаемые классы излучения',
    '5.5. Номер полосы частот',
    '5.6. Пороговая чувствительность',
    '5.7. Реальная чувствительность',
    '5.8. Защитное отношение, дБ',
    '5.9. Вид помехи',
    '5.10. Ширина полосы на уровне -3 дБ, Гц',
    '5.11. Ширина полосы на уровне -30 дБ, Гц',
    '5.12. Дополнительный уровень, дБ',
    '5.13. Перестройка гетеродина',
    '5.14. Промежуточная частота, Гц',
    '5.15. Ширина полосы ПЧ на уровне -3 дБ, Гц',
    '5.16. Ширина полосы ПЧ на уровне -30 дБ, Гц',
    '5.17. Дополнительный уровень ПЧ, дБ'
  );
var
  Scroll: TScrollBox;
  L: TLabel;
  B: TButton;
  I, Y: Integer;
begin
  inherited CreateNew(AOwner);

  Caption := 'Характеристики режима приёмника';
  BorderStyle := bsSizeable;
  Position := poOwnerFormCenter;
  ClientWidth := 620;
  ClientHeight := 650;

  Scroll := TScrollBox.Create(Self);
  Scroll.Parent := Self;
  Scroll.SetBounds(0, 0, 620, 570);
  Scroll.Anchors := [akLeft, akTop, akRight, akBottom];

  Y := 12;

  for I := 0 to 14 do
  begin
    L := TLabel.Create(Self);
    L.Parent := Scroll;
    L.Caption := Captions[I];
    L.SetBounds(16, Y, 560, 18);

    FEdits[I] := TEdit.Create(Self);
    FEdits[I].Parent := Scroll;
    FEdits[I].SetBounds(16, Y + 21, 560, 25);
    FEdits[I].Anchors := [akLeft, akTop, akRight];

    Inc(Y, 58);
  end;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'OK';
  B.ModalResult := mrOK;
  B.SetBounds(424, 594, 80, 30);
  B.Anchors := [akRight, akBottom];
  B.Default := True;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Отмена';
  B.ModalResult := mrCancel;
  B.SetBounds(514, 594, 80, 30);
  B.Anchors := [akRight, akBottom];
  B.Cancel := True;
end;

procedure TReceiverModeDialog.LoadMode(AMode: TReceiverMode);
begin
  FEdits[0].Text := AMode.ModeNumber;
  FEdits[1].Text := AMode.ReceivedEmissionClasses;
  FEdits[2].Text := AMode.FrequencyBandNumber;

  if AMode.ThresholdSensitivity.HasValue then
    FEdits[3].Text := FloatToStr(AMode.ThresholdSensitivity.Value)
  else FEdits[3].Clear;

  if AMode.RealSensitivity.HasValue then
    FEdits[4].Text := FloatToStr(AMode.RealSensitivity.Value)
  else FEdits[4].Clear;

  if AMode.ProtectionRatioDb.HasValue then
    FEdits[5].Text := FloatToStr(AMode.ProtectionRatioDb.Value)
  else FEdits[5].Clear;

  FEdits[6].Text := AMode.InterferenceType;

  if AMode.UhfBandwidthAt3DbHz.HasValue then
    FEdits[7].Text := FloatToStr(AMode.UhfBandwidthAt3DbHz.Value)
  else FEdits[7].Clear;

  if AMode.UhfBandwidthAt30DbHz.HasValue then
    FEdits[8].Text := FloatToStr(AMode.UhfBandwidthAt30DbHz.Value)
  else FEdits[8].Clear;

  if AMode.UhfBandwidthAdditionalLevelDb.HasValue then
    FEdits[9].Text :=
      FloatToStr(AMode.UhfBandwidthAdditionalLevelDb.Value)
  else FEdits[9].Clear;

  FEdits[10].Text := AMode.HeterodyneTuning;

  if AMode.IntermediateFrequencyHz.HasValue then
    FEdits[11].Text := FloatToStr(AMode.IntermediateFrequencyHz.Value)
  else FEdits[11].Clear;

  if AMode.IfBandwidthAt3DbHz.HasValue then
    FEdits[12].Text := FloatToStr(AMode.IfBandwidthAt3DbHz.Value)
  else FEdits[12].Clear;

  if AMode.IfBandwidthAt30DbHz.HasValue then
    FEdits[13].Text := FloatToStr(AMode.IfBandwidthAt30DbHz.Value)
  else FEdits[13].Clear;

  if AMode.IfBandwidthAdditionalLevelDb.HasValue then
    FEdits[14].Text :=
      FloatToStr(AMode.IfBandwidthAdditionalLevelDb.Value)
  else FEdits[14].Clear;
end;

function TReceiverModeDialog.SaveMode(AMode: TReceiverMode): Boolean;
var
  V: Double;

  function ReadOptional(
    AIndex: Integer;
    out AValue: TOptionalValue<Double>
  ): Boolean;
  begin
    AValue.HasValue := False;
    AValue.Value := 0;

    if Trim(FEdits[AIndex].Text) = '' then
      Exit(True);

    Result := TryStrToFloat(Trim(FEdits[AIndex].Text), V);

    if Result then
    begin
      AValue.HasValue := True;
      AValue.Value := V;
    end;
  end;

var
  O: TOptionalValue<Double>;
begin
  Result := False;

  if Trim(FEdits[0].Text) = '' then
  begin
    MessageDlg('Укажите номер режима.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if not ReadOptional(3, O) then Exit;
  AMode.ThresholdSensitivity := O;

  if not ReadOptional(4, O) then Exit;
  AMode.RealSensitivity := O;

  if not ReadOptional(5, O) then Exit;
  AMode.ProtectionRatioDb := O;

  if not ReadOptional(7, O) then Exit;
  AMode.UhfBandwidthAt3DbHz := O;

  if not ReadOptional(8, O) then Exit;
  AMode.UhfBandwidthAt30DbHz := O;

  if not ReadOptional(9, O) then Exit;
  AMode.UhfBandwidthAdditionalLevelDb := O;

  if not ReadOptional(11, O) then Exit;
  AMode.IntermediateFrequencyHz := O;

  if not ReadOptional(12, O) then Exit;
  AMode.IfBandwidthAt3DbHz := O;

  if not ReadOptional(13, O) then Exit;
  AMode.IfBandwidthAt30DbHz := O;

  if not ReadOptional(14, O) then Exit;
  AMode.IfBandwidthAdditionalLevelDb := O;

  AMode.ModeNumber := Trim(FEdits[0].Text);
  AMode.ReceivedEmissionClasses := Trim(FEdits[1].Text);
  AMode.FrequencyBandNumber := Trim(FEdits[2].Text);
  AMode.InterferenceType := Trim(FEdits[6].Text);
  AMode.HeterodyneTuning := Trim(FEdits[10].Text);

  Result := True;
end;

function TReceiverModeDialog.Execute(AMode: TReceiverMode): Boolean;
begin
  LoadMode(AMode);

  repeat
    Result := ShowModal = mrOK;

    if not Result then
      Exit;

    if SaveMode(AMode) then
      Exit(True);

    MessageDlg(
      'Одно или несколько числовых полей содержат некорректное значение.',
      mtWarning, [mbOK], 0
    );
  until False;
end;


constructor TReceiverEditor.Create(AOwner: TComponent);
const
  Captions: array[0..10] of string = (
    '5.1. Тип приёмника',
    '5.2. Рабочие частоты',
    '5.3. Шаг сетки частот',
    '5.18. Нестабильность частоты гетеродина',
    '5.19. Избирательность по соседнему каналу, дБ',
    '5.20. Избирательность по зеркальному каналу, дБ',
    '5.21. Избирательность по другим побочным каналам, дБ',
    '5.22. Блокирование и перекрёстная модуляция, дБ',
    '5.23. Избирательность по интермодуляции, дБ',
    '5.24. Эквивалентная шумовая температура, К',
    '5.25. Максимальное увеличение шумовой температуры, %'
  );
var
  Scroll: TScrollBox;
  L: TLabel;
  I, Y: Integer;
begin
  inherited Create(AOwner);

  Align := alClient;
  BevelOuter := bvNone;
  FReceiver := nil;
  FUpdating := False;

  Scroll := TScrollBox.Create(Self);
  Scroll.Parent := Self;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;

  Y := 12;

  for I := 0 to 10 do
  begin
    L := TLabel.Create(Self);
    L.Parent := Scroll;
    L.Caption := Captions[I];
    L.SetBounds(16, Y, 650, 18);

    FEdits[I] := TEdit.Create(Self);
    FEdits[I].Parent := Scroll;
    FEdits[I].SetBounds(16, Y + 22, 700, 25);
    FEdits[I].Anchors := [akLeft, akTop, akRight];
    FEdits[I].Tag := I;
    FEdits[I].OnChange := GeneralChanged;

    Inc(Y, 58);
  end;

  L := TLabel.Create(Self);
  L.Parent := Scroll;
  L.Caption := 'Характеристики по режимам';
  L.SetBounds(16, Y + 8, 400, 20);

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Scroll;
  FGrid.SetBounds(16, Y + 34, 1000, 240);
  FGrid.Anchors := [akLeft, akTop, akRight];

  FGrid.ColCount := 7;
  FGrid.RowCount := 2;
  FGrid.FixedRows := 1;
  FGrid.FixedCols := 0;

  FGrid.Cells[0, 0] := 'Режим';
  FGrid.Cells[1, 0] := 'Классы излучения';
  FGrid.Cells[2, 0] := 'Полоса';
  FGrid.Cells[3, 0] := 'Пороговая чувствительность';
  FGrid.Cells[4, 0] := 'Реальная чувствительность';
  FGrid.Cells[5, 0] := 'Защитное отношение';
  FGrid.Cells[6, 0] := 'Вид помехи';

  FGrid.ColWidths[0] := 60;
  FGrid.ColWidths[1] := 140;
  FGrid.ColWidths[2] := 60;
  FGrid.ColWidths[3] := 140;
  FGrid.ColWidths[4] := 140;
  FGrid.ColWidths[5] := 120;
  FGrid.ColWidths[6] := 120;

  FGrid.Options := [
    goFixedVertLine,
    goFixedHorzLine,
    goVertLine,
    goHorzLine,
    goRowSelect
  ];

  FGrid.OnDblClick := GridDblClick;

  FAddButton := TButton.Create(Self);
  FAddButton.Parent := Scroll;
  FAddButton.Caption := 'Добавить режим';
  FAddButton.SetBounds(16, Y + 284, 120, 30);

  FEditButton := TButton.Create(Self);
  FEditButton.Parent := Scroll;
  FEditButton.Caption := 'Изменить';
  FEditButton.SetBounds(146, Y + 284, 100, 30);

  FDeleteButton := TButton.Create(Self);
  FDeleteButton.Parent := Scroll;
  FDeleteButton.Caption := 'Удалить';
  FDeleteButton.SetBounds(256, Y + 284, 100, 30);

  FAddButton.OnClick := AddModeClick;
  FEditButton.OnClick := EditModeClick;
  FDeleteButton.OnClick := DeleteModeClick;
end;

procedure TReceiverEditor.GeneralChanged(Sender: TObject);
var
  V: Double;
  O: TOptionalValue<Double>;
  Index: Integer;
begin
  if FUpdating or (FReceiver = nil) then
    Exit;

  Index := TEdit(Sender).Tag;

  case Index of
    0: FReceiver.ReceiverType := TEdit(Sender).Text;
    1: FReceiver.OperatingFrequencies := TEdit(Sender).Text;
    2: FReceiver.FrequencyGridStep := TEdit(Sender).Text;
    3: FReceiver.HeterodyneFrequencyInstability := TEdit(Sender).Text;
    4..10:
      begin
        O.HasValue := False;
        O.Value := 0;

        if Trim(TEdit(Sender).Text) <> '' then
        begin
          if not TryStrToFloat(Trim(TEdit(Sender).Text), V) then
            Exit;

          O.HasValue := True;
          O.Value := V;
        end;

        case Index of
          4: FReceiver.AdjacentChannelSelectivityDb := O;
          5: FReceiver.ImageChannelSelectivityDb := O;
          6: FReceiver.OtherSpuriousResponseSelectivityDb := O;
          7: FReceiver.BlockingAndCrossModulationDb := O;
          8: FReceiver.IntermodulationSelectivityDb := O;
          9: FReceiver.EquivalentNoiseTemperatureK := O;
          10: FReceiver.MaxNoiseTemperatureIncreasePercent := O;
        end;
      end;
  end;
end;

procedure TReceiverEditor.Bind(AReceiver: TReceiver);
begin
  FUpdating := True;
  try
    FReceiver := AReceiver;

    if FReceiver = nil then
    begin
      for var I := 0 to 10 do
        FEdits[I].Clear;
    end
    else
    begin
      FEdits[0].Text := FReceiver.ReceiverType;
      FEdits[1].Text := FReceiver.OperatingFrequencies;
      FEdits[2].Text := FReceiver.FrequencyGridStep;
      FEdits[3].Text := FReceiver.HeterodyneFrequencyInstability;

      if FReceiver.AdjacentChannelSelectivityDb.HasValue then
        FEdits[4].Text :=
          FloatToStr(FReceiver.AdjacentChannelSelectivityDb.Value)
      else FEdits[4].Clear;

      if FReceiver.ImageChannelSelectivityDb.HasValue then
        FEdits[5].Text :=
          FloatToStr(FReceiver.ImageChannelSelectivityDb.Value)
      else FEdits[5].Clear;

      if FReceiver.OtherSpuriousResponseSelectivityDb.HasValue then
        FEdits[6].Text :=
          FloatToStr(FReceiver.OtherSpuriousResponseSelectivityDb.Value)
      else FEdits[6].Clear;

      if FReceiver.BlockingAndCrossModulationDb.HasValue then
        FEdits[7].Text :=
          FloatToStr(FReceiver.BlockingAndCrossModulationDb.Value)
      else FEdits[7].Clear;

      if FReceiver.IntermodulationSelectivityDb.HasValue then
        FEdits[8].Text :=
          FloatToStr(FReceiver.IntermodulationSelectivityDb.Value)
      else FEdits[8].Clear;

      if FReceiver.EquivalentNoiseTemperatureK.HasValue then
        FEdits[9].Text :=
          FloatToStr(FReceiver.EquivalentNoiseTemperatureK.Value)
      else FEdits[9].Clear;

      if FReceiver.MaxNoiseTemperatureIncreasePercent.HasValue then
        FEdits[10].Text :=
          FloatToStr(FReceiver.MaxNoiseTemperatureIncreasePercent.Value)
      else FEdits[10].Clear;
    end;
  finally
    FUpdating := False;
  end;

  RefreshGrid;
end;

procedure TReceiverEditor.RefreshGrid;
var
  I: Integer;
  M: TReceiverMode;
begin
  if FReceiver = nil then
  begin
    FGrid.RowCount := 2;
    FEditButton.Enabled := False;
    FDeleteButton.Enabled := False;
    Exit;
  end;

  FGrid.RowCount := Max(2, FReceiver.Modes.Count + 1);

  for I := 0 to FReceiver.Modes.Count - 1 do
  begin
    M := FReceiver.Modes[I];

    FGrid.Cells[0, I + 1] := M.ModeNumber;
    FGrid.Cells[1, I + 1] := M.ReceivedEmissionClasses;
    FGrid.Cells[2, I + 1] := M.FrequencyBandNumber;

    if M.ThresholdSensitivity.HasValue then
      FGrid.Cells[3, I + 1] :=
        FloatToStr(M.ThresholdSensitivity.Value)
    else FGrid.Cells[3, I + 1] := '';

    if M.RealSensitivity.HasValue then
      FGrid.Cells[4, I + 1] :=
        FloatToStr(M.RealSensitivity.Value)
    else FGrid.Cells[4, I + 1] := '';

    if M.ProtectionRatioDb.HasValue then
      FGrid.Cells[5, I + 1] :=
        FloatToStr(M.ProtectionRatioDb.Value)
    else FGrid.Cells[5, I + 1] := '';

    FGrid.Cells[6, I + 1] := M.InterferenceType;
  end;

  FEditButton.Enabled := FReceiver.Modes.Count > 0;
  FDeleteButton.Enabled := FReceiver.Modes.Count > 0;
end;

procedure TReceiverEditor.AddModeClick(Sender: TObject);
var
  M: TReceiverMode;
  Dialog: TReceiverModeDialog;
begin
  if FReceiver = nil then
    Exit;

  M := TReceiverMode.Create;
  try
    Dialog := TReceiverModeDialog.Create(Self);
    try
      if Dialog.Execute(M) then
      begin
        FReceiver.Modes.Add(M);
        M := nil;
        RefreshGrid;
      end;
    finally
      Dialog.Free;
    end;
  finally
    M.Free;
  end;
end;

procedure TReceiverEditor.EditModeClick(Sender: TObject);
var
  Index: Integer;
  Dialog: TReceiverModeDialog;
begin
  if FReceiver = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FReceiver.Modes.Count) then
    Exit;

  Dialog := TReceiverModeDialog.Create(Self);
  try
    if Dialog.Execute(FReceiver.Modes[Index]) then
      RefreshGrid;
  finally
    Dialog.Free;
  end;
end;

procedure TReceiverEditor.DeleteModeClick(Sender: TObject);
var
  Index: Integer;
begin
  if FReceiver = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FReceiver.Modes.Count) then
    Exit;

  if MessageDlg(
    'Удалить характеристики выбранного режима приёмника?',
    mtConfirmation, [mbYes, mbNo], 0
  ) <> mrYes then
    Exit;

  FReceiver.Modes.Delete(Index);
  RefreshGrid;
end;

procedure TReceiverEditor.GridDblClick(Sender: TObject);
begin
  if FEditButton.Enabled then
    EditModeClick(FEditButton);
end;

// 6666

constructor TAntennaDialog.Create(AOwner: TComponent);
const
  FieldNames: array[0..14] of string = (
    'Номер антенны (6.0)',
    'Назначение (6.1)',
    'Тип антенны (6.2)',
    'Габариты (6.3)',
    'Номера режимов (ссылка на 3.5)',
    'Ссылка на диаграмму направленности (6.4)',
    'Пространственное положение ДН (6.5)',
    'Частота, Гц (6.6)',
    'Коэффициент усиления, дБ (6.7)',
    'Ширина ДН по горизонтали, град. (6.8)',
    'Ширина ДН по вертикали, град. (6.9)',
    'Угловой сектор, град. (6.10)',
    'Уровень боковых лепестков, дБ (6.11)',
    'Точность наведения, град. (6.12)',
    'Зона покрытия (6.13)'
  );
var
  Scroll: TScrollBox;
  Lbl: TLabel;
  I, Y: Integer;
  BtnOK, BtnCancel: TButton;
begin
  inherited CreateNew(AOwner);

  Caption := 'Характеристики антенны';
  Width := 660;
  Height := 720;
  Position := poScreenCenter;
  BorderStyle := bsSizeable;

  Scroll := TScrollBox.Create(Self);
  Scroll.Parent := Self;
  Scroll.Align := alClient;
  Scroll.VertScrollBar.Tracking := True;

  for I := 0 to High(FEdits) do
  begin
    Y := 12 + I * 42;

    Lbl := TLabel.Create(Self);
    Lbl.Parent := Scroll;
    Lbl.Left := 12;
    Lbl.Top := Y + 3;
    Lbl.Caption := FieldNames[I];

    FEdits[I] := TEdit.Create(Self);
    FEdits[I].Parent := Scroll;
    FEdits[I].Left := 270;
    FEdits[I].Top := Y;
    FEdits[I].Width := 340;
  end;

  BtnOK := TButton.Create(Self);
  BtnOK.Parent := Self;
  BtnOK.Align := alBottom;
  BtnOK.Height := 36;
  BtnOK.Caption := 'ОК';
  BtnOK.ModalResult := mrNone;
  BtnOK.Default := True;
  BtnOK.OnClick := AcceptClick;

  BtnCancel := TButton.Create(Self);
  BtnCancel.Parent := Self;
  BtnCancel.Align := alBottom;
  BtnCancel.Height := 36;
  BtnCancel.Caption := 'Отмена';
  BtnCancel.Cancel := True;
  BtnCancel.ModalResult := mrCancel;
end;

procedure TAntennaDialog.AcceptClick(Sender: TObject);
begin
  if SaveAntenna(FAntenna) then
    ModalResult := mrOk;
end;

function TAntennaDialog.GetEditValue(AIndex: Integer): string;
begin
  Result := FEdits[AIndex].Text;
end;

procedure TAntennaDialog.SetEditValue(
  AIndex: Integer; const AValue: string);
begin
  FEdits[AIndex].Text := AValue;
end;

procedure TAntennaDialog.LoadAntenna(AAntenna: TAntenna);
begin
  SetEditValue(0, AAntenna.AntennaNumber);
  SetEditValue(1, AAntenna.AntennaPurpose);
  SetEditValue(2, AAntenna.AntennaType);
  SetEditValue(3, AAntenna.AntennaDimensions);
  SetEditValue(4, AAntenna.ModeNumbers);
  SetEditValue(5, AAntenna.BeamReference);
  SetEditValue(6, AAntenna.BeamSpatialPosition);

  if AAntenna.FrequencyHz.HasValue then
    SetEditValue(7, FloatToStr(AAntenna.FrequencyHz.Value))
  else
    SetEditValue(7, '');

  if AAntenna.GainDb.HasValue then
    SetEditValue(8, FloatToStr(AAntenna.GainDb.Value))
  else
    SetEditValue(8, '');

  if AAntenna.BeamwidthHorizontalDeg.HasValue then
    SetEditValue(9, FloatToStr(AAntenna.BeamwidthHorizontalDeg.Value))
  else
    SetEditValue(9, '');

  if AAntenna.BeamwidthVerticalDeg.HasValue then
    SetEditValue(10, FloatToStr(AAntenna.BeamwidthVerticalDeg.Value))
  else
    SetEditValue(10, '');

  SetEditValue(11, AAntenna.AngularSectorDeg);

  if AAntenna.SideLobeLevelDb.HasValue then
    SetEditValue(12, FloatToStr(AAntenna.SideLobeLevelDb.Value))
  else
    SetEditValue(12, '');

  if AAntenna.PointingAccuracyDeg.HasValue then
    SetEditValue(13, FloatToStr(AAntenna.PointingAccuracyDeg.Value))
  else
    SetEditValue(13, '');

  SetEditValue(14, AAntenna.CoverageArea);
end;

function TAntennaDialog.SaveAntenna(AAntenna: TAntenna): Boolean;
var
  Frequency, Gain, Horizontal, Vertical, SideLobe, Accuracy:
    TOptionalValue<Double>;

  function ReadOptionalFloat(
    AIndex: Integer;
    const AFieldName: string;
    out AValue: TOptionalValue<Double>): Boolean;
  var
    S: string;
    V: Double;
  begin
    S := Trim(GetEditValue(AIndex));
    AValue.HasValue := False;
    AValue.Value := 0;

    if S = '' then
      Exit(True);

    if not TryStrToFloat(S, V) then
    begin
      MessageDlg(
        'Некорректное числовое значение: ' + AFieldName,
        mtError, [mbOK], 0);
      FEdits[AIndex].SetFocus;
      Exit(False);
    end;

    AValue.HasValue := True;
    AValue.Value := V;
    Result := True;
  end;

begin
  Result := False;

  // Сначала проверяем все числа. Модель пока не изменяется.
  if not ReadOptionalFloat(7, 'Частота', Frequency) then Exit;
  if not ReadOptionalFloat(8, 'Коэффициент усиления', Gain) then Exit;
  if not ReadOptionalFloat(9, 'Ширина ДН по горизонтали', Horizontal) then Exit;
  if not ReadOptionalFloat(10, 'Ширина ДН по вертикали', Vertical) then Exit;
  if not ReadOptionalFloat(12, 'Уровень боковых лепестков', SideLobe) then Exit;
  if not ReadOptionalFloat(13, 'Точность наведения', Accuracy) then Exit;

  // После успешной проверки переносим значения в объект.
  AAntenna.AntennaNumber := GetEditValue(0);
  AAntenna.AntennaPurpose := GetEditValue(1);
  AAntenna.AntennaType := GetEditValue(2);
  AAntenna.AntennaDimensions := GetEditValue(3);
  AAntenna.ModeNumbers := GetEditValue(4);
  AAntenna.BeamReference := GetEditValue(5);
  AAntenna.BeamSpatialPosition := GetEditValue(6);

  AAntenna.FrequencyHz := Frequency;
  AAntenna.GainDb := Gain;
  AAntenna.BeamwidthHorizontalDeg := Horizontal;
  AAntenna.BeamwidthVerticalDeg := Vertical;

  AAntenna.AngularSectorDeg := GetEditValue(11);
  AAntenna.SideLobeLevelDb := SideLobe;
  AAntenna.PointingAccuracyDeg := Accuracy;
  AAntenna.CoverageArea := GetEditValue(14);

  Result := True;
end;

function TAntennaDialog.Execute(AAntenna: TAntenna): Boolean;
begin
  FAntenna := AAntenna;
  LoadAntenna(AAntenna);
  Result := ShowModal = mrOk;
end;


constructor TAntennaEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Align := alClient;
  BevelOuter := bvNone;

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Align := alClient;
  FGrid.FixedRows := 1;
  FGrid.FixedCols := 0;
  FGrid.ColCount := 8;
  FGrid.RowCount := 2;
  FGrid.Options := FGrid.Options + [goRowSelect] - [goEditing];

  FGrid.Cells[0, 0] := '№';
  FGrid.Cells[1, 0] := 'Назначение';
  FGrid.Cells[2, 0] := 'Тип';
  FGrid.Cells[3, 0] := 'Режимы';
  FGrid.Cells[4, 0] := 'Частота, Гц';
  FGrid.Cells[5, 0] := 'Усиление, дБ';
  FGrid.Cells[6, 0] := 'Ширина ДН гор.';
  FGrid.Cells[7, 0] := 'Ширина ДН верт.';

  FGrid.ColWidths[0] := 55;
  FGrid.ColWidths[1] := 150;
  FGrid.ColWidths[2] := 120;
  FGrid.ColWidths[3] := 90;
  FGrid.ColWidths[4] := 110;
  FGrid.ColWidths[5] := 90;
  FGrid.ColWidths[6] := 110;
  FGrid.ColWidths[7] := 110;

  FGrid.OnDblClick := GridDblClick;

  // Панель кнопок располагается снизу.
  with TPanel.Create(Self) do
  begin
    Parent := Self;
    Align := alBottom;
    Height := 42;
    BevelOuter := bvNone;

    FAddButton := TButton.Create(Self);
    FAddButton.Parent := Self;
    FAddButton.SetBounds(8, 5, 100, 30);
    FAddButton.Caption := 'Добавить';
    FAddButton.OnClick := AddAntenna;

    FEditButton := TButton.Create(Self);
    FEditButton.Parent := Self;
    FEditButton.SetBounds(116, 5, 100, 30);
    FEditButton.Caption := 'Изменить';
    FEditButton.OnClick := EditAntenna;

    FDeleteButton := TButton.Create(Self);
    FDeleteButton.Parent := Self;
    FDeleteButton.SetBounds(224, 5, 100, 30);
    FDeleteButton.Caption := 'Удалить';
    FDeleteButton.OnClick := DeleteAntenna;
  end;
end;

procedure TAntennaEditor.Bind(AAntennas: TObjectList<TAntenna>);
begin
  FAntennas := AAntennas;
  RefreshGrid;
end;

procedure TAntennaEditor.RefreshGrid;
var
  I: Integer;
  A: TAntenna;
begin
  if FAntennas = nil then
    Exit;

  FGrid.RowCount := Max(2, FAntennas.Count + 1);

  for I := 0 to FAntennas.Count - 1 do
  begin
    A := FAntennas[I];

    FGrid.Cells[0, I + 1] := A.AntennaNumber;
    FGrid.Cells[1, I + 1] := A.AntennaPurpose;
    FGrid.Cells[2, I + 1] := A.AntennaType;
    FGrid.Cells[3, I + 1] := A.ModeNumbers;

    if A.FrequencyHz.HasValue then
      FGrid.Cells[4, I + 1] :=
        FloatToStr(A.FrequencyHz.Value)
    else
      FGrid.Cells[4, I + 1] := '';

    if A.GainDb.HasValue then
      FGrid.Cells[5, I + 1] :=
        FloatToStr(A.GainDb.Value)
    else
      FGrid.Cells[5, I + 1] := '';

    if A.BeamwidthHorizontalDeg.HasValue then
      FGrid.Cells[6, I + 1] :=
        FloatToStr(A.BeamwidthHorizontalDeg.Value)
    else
      FGrid.Cells[6, I + 1] := '';

    if A.BeamwidthVerticalDeg.HasValue then
      FGrid.Cells[7, I + 1] :=
        FloatToStr(A.BeamwidthVerticalDeg.Value)
    else
      FGrid.Cells[7, I + 1] := '';
  end;
end;

procedure TAntennaEditor.GridDblClick(Sender: TObject);
begin
  EditAntenna(Sender);
end;

procedure TAntennaEditor.AddAntenna(Sender: TObject);
var
  A: TAntenna;
  D: TAntennaDialog;
begin
  if FAntennas = nil then
    Exit;

  A := TAntenna.Create;
  try
    D := TAntennaDialog.Create(Self);
    try
      if D.Execute(A) then
      begin
        FAntennas.Add(A);
        A := nil;
        RefreshGrid;
      end;
    finally
      D.Free;
    end;
  finally
    A.Free;
  end;
end;

procedure TAntennaEditor.EditAntenna(Sender: TObject);
var
  Index: Integer;
  D: TAntennaDialog;
begin
  if FAntennas = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FAntennas.Count) then
    Exit;

  D := TAntennaDialog.Create(Self);
  try
    if D.Execute(FAntennas[Index]) then
      RefreshGrid;
  finally
    D.Free;
  end;
end;

procedure TAntennaEditor.DeleteAntenna(Sender: TObject);
var
  Index: Integer;
begin
  if FAntennas = nil then
    Exit;

  Index := FGrid.Row - 1;

  if (Index < 0) or (Index >= FAntennas.Count) then
    Exit;

  if MessageDlg(
    'Удалить выбранную антенну?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FAntennas.Delete(Index);
  RefreshGrid;
end;

/// 777

constructor TFeederEditor.Create(AOwner: TComponent);
const
  FieldNames: array[0..5] of string = (
    'Тип фидера (7.1)',
    'Критическая частота (7.2)',
    'Волновое сопротивление (7.3)',
    'Затухание при приёме, дБ (7.4)',
    'Затухание при передаче, дБ (7.5)',
    'Поляризационные характеристики (7.6)'
  );
var
  I, Y: Integer;
  Lbl: TLabel;
begin
  inherited Create(AOwner);

  Align := alClient;
  BevelOuter := bvNone;

  for I := 0 to High(FEdits) do
  begin
    Y := 16 + I * 48;

    Lbl := TLabel.Create(Self);
    Lbl.Parent := Self;
    Lbl.Left := 16;
    Lbl.Top := Y + 4;
    Lbl.Caption := FieldNames[I];

    FEdits[I] := TEdit.Create(Self);
    FEdits[I].Parent := Self;
    FEdits[I].Left := 280;
    FEdits[I].Top := Y;
    FEdits[I].Width := 320;
              FEdits[I].OnExit:=GeneralChanged;
  end;
end;

procedure TFeederEditor.Bind(AFeeder: TFeeder);
begin
  FFeeder := AFeeder;
  LoadData;
end;

procedure TFeederEditor.LoadData;
begin
  if FFeeder = nil then
    Exit;

  FEdits[0].Text := FFeeder.FeederType;
  FEdits[1].Text := FFeeder.CriticalFrequency;
  FEdits[2].Text := FFeeder.WaveImpedance;

  if FFeeder.AttenuationReceiveDb.HasValue then
    FEdits[3].Text :=
      FloatToStr(FFeeder.AttenuationReceiveDb.Value)
  else
    FEdits[3].Text := '';

  if FFeeder.AttenuationTransmitDb.HasValue then
    FEdits[4].Text :=
      FloatToStr(FFeeder.AttenuationTransmitDb.Value)
  else
    FEdits[4].Text := '';

  FEdits[5].Text := FFeeder.PolarizationCharacteristics;
end;

procedure TFeederEditor.SaveData;
var
  ReceiveValue, TransmitValue: TOptionalValue<Double>;

  function ParseOptional(
    AEdit: TEdit;
    const AFieldName: string;
    out AValue: TOptionalValue<Double>): Boolean;
  var
    S: string;
    V: Double;
  begin
    S := Trim(AEdit.Text);
    AValue.HasValue := False;
    AValue.Value := 0;

    if S = '' then
      Exit(True);

    if not TryStrToFloat(S, V) then
    begin
      MessageDlg(
        'Некорректное числовое значение: ' + AFieldName,
        mtError, [mbOK], 0);
      AEdit.SetFocus;
      Exit(False);
    end;

    AValue.HasValue := True;
    AValue.Value := V;
    Result := True;
  end;

begin
  if FFeeder = nil then
    Exit;

  if not ParseOptional(
    FEdits[3], 'Затухание при приёме', ReceiveValue) then
    Exit;

  if not ParseOptional(
    FEdits[4], 'Затухание при передаче', TransmitValue) then
    Exit;

  FFeeder.FeederType := FEdits[0].Text;
  FFeeder.CriticalFrequency := FEdits[1].Text;
  FFeeder.WaveImpedance := FEdits[2].Text;
  FFeeder.AttenuationReceiveDb := ReceiveValue;
  FFeeder.AttenuationTransmitDb := TransmitValue;
  FFeeder.PolarizationCharacteristics := FEdits[5].Text;
end;

procedure TFeederEditor.GeneralChanged(Sender: TObject);
begin
  SaveData;
end;

/// 888

constructor TEmcEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Align := alClient;
  BevelOuter := bvNone;

  FLabel := TLabel.Create(Self);
  FLabel.Parent := Self;
  FLabel.Left := 12;
  FLabel.Top := 12;
  FLabel.Caption := 'Мероприятия по обеспечению ЭМС (8.1)';

  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.Left := 12;
  FMemo.Top := 36;
  FMemo.Width := 700;
  FMemo.Height := 400;
  FMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  FMemo.ScrollBars := ssVertical;
  FMemo.WordWrap := True;
  FMemo.WantReturns := True;
  FMemo.OnExit := SaveData;
end;

procedure TEmcEditor.Bind(AEmcInformation: TEmcInformation);
begin
  FEmcInformation := AEmcInformation;
  LoadData;
end;

procedure TEmcEditor.LoadData;
begin
  if FEmcInformation = nil then
    Exit;

  FMemo.Text := FEmcInformation.EmcMeasures;
end;

procedure TEmcEditor.SaveData(Sender: TObject);
begin
  if FEmcInformation = nil then
    Exit;

  FEmcInformation.EmcMeasures := FMemo.Text;
end;

// 999

constructor TOrganizationsEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Align := alClient;
  VertScrollBar.Tracking := True;

  CreateOrganizationBlock(0, 12, 'Заказчик');
  CreateOrganizationBlock(1, 270, 'Разработчик');
  CreateOrganizationBlock(2, 528, 'Изготовитель');
end;

procedure TOrganizationsEditor.CreateOrganizationBlock(
  AIndex, ATop: Integer;
  const ATitle: string);
const
  FieldNames: array[0..2] of string = (
    'Наименование организации',
    'Адрес и телефон',
    'Сведения о подписи'
  );
var
  Group: TGroupBox;
  Lbl: TLabel;
  I, Y: Integer;
begin
  Group := TGroupBox.Create(Self);
  Group.Parent := Self;
  Group.Caption := ATitle;
  Group.SetBounds(12, ATop, 720, 245);

  for I := 0 to 2 do
  begin
    Y := 28 + I * 68;

    Lbl := TLabel.Create(Self);
    Lbl.Parent := Group;
    Lbl.Left := 12;
    Lbl.Top := Y + 3;
    Lbl.Caption := FieldNames[I];

    FEdits[AIndex, I] := TMemo.Create(Self);
    FEdits[AIndex, I].Parent := Group;
    FEdits[AIndex, I].SetBounds(190, Y, 510, 54);
    FEdits[AIndex, I].ScrollBars := ssVertical;
    FEdits[AIndex, I].WordWrap := True;
    FEdits[AIndex, I].OnExit := SaveData;
  end;
end;

function TOrganizationsEditor.GetOrganization(
  AIndex: Integer): TOrganizationInfo;
begin
  case AIndex of
    0: Result := FCustomer;
    1: Result := FDeveloper;
    2: Result := FManufacturer;
  else
    Result := nil;
  end;
end;

procedure TOrganizationsEditor.Bind(
  ACustomer, ADeveloper, AManufacturer: TOrganizationInfo);
begin
  FCustomer := ACustomer;
  FDeveloper := ADeveloper;
  FManufacturer := AManufacturer;

  LoadData;
end;

procedure TOrganizationsEditor.LoadData;
var
  I: Integer;
  Org: TOrganizationInfo;
begin
  for I := 0 to 2 do
  begin
    Org := GetOrganization(I);

    if Org = nil then
      Continue;

    FEdits[I, 0].Text := Org.OrganizationName;
    FEdits[I, 1].Text := Org.AddressAndPhone;
    FEdits[I, 2].Text := Org.SignatureDetails;
  end;
end;

procedure TOrganizationsEditor.SaveData(Sender: TObject);
var
  I: Integer;
  Org: TOrganizationInfo;
begin
  for I := 0 to 2 do
  begin
    Org := GetOrganization(I);

    if Org = nil then
      Continue;

    Org.OrganizationName := FEdits[I, 0].Text;
    Org.AddressAndPhone := FEdits[I, 1].Text;
    Org.SignatureDetails := FEdits[I, 2].Text;
  end;
end;


end.

