
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
  FGrid.Anchors := [akLeft, akTop, akRight, akBottom];

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
  FAddButton.Anchors := [akLeft, akBottom];
  FAddButton.OnClick := AddModeClick;

  FEditButton := TButton.Create(Self);
  FEditButton.Parent := Self;
  FEditButton.Caption := 'Изменить';
  FEditButton.SetBounds(146, 594, 100, 30);
  FEditButton.Anchors := [akLeft, akBottom];
  FEditButton.OnClick := EditModeClick;

  FDeleteButton := TButton.Create(Self);
  FDeleteButton.Parent := Self;
  FDeleteButton.Caption := 'Удалить';
  FDeleteButton.SetBounds(256, 594, 100, 30);
  FDeleteButton.Anchors := [akLeft, akBottom];
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

end.

