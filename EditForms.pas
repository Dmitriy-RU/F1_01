
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
  TFrequencyBandDialog = class(TForm)
  private
    FNumberEdit: TEdit;
    FMinFrequencyEdit: TEdit;
    FMaxFrequencyEdit: TEdit;

    function TryReadFrequency(
      const AText: string;
      out AValue: TOptionalValue<Double>
    ): Boolean;

  public
    constructor Create(AOwner: TComponent); override;

    function Execute(ABand: TFrequencyBand): Boolean;
  end;

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


constructor TFrequencyBandDialog.Create(AOwner: TComponent);
var
  L: TLabel;
  B: TButton;
begin
  inherited Create(AOwner);

  Caption := 'Полоса частот';
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 430;
  ClientHeight := 220;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Номер полосы';
  L.SetBounds(16, 16, 180, 18);

  FNumberEdit := TEdit.Create(Self);
  FNumberEdit.Parent := Self;
  FNumberEdit.SetBounds(16, 38, 390, 25);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Нижняя граница, МГц';
  L.SetBounds(16, 76, 180, 18);

  FMinFrequencyEdit := TEdit.Create(Self);
  FMinFrequencyEdit.Parent := Self;
  FMinFrequencyEdit.SetBounds(16, 98, 180, 25);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Верхняя граница, МГц';
  L.SetBounds(216, 76, 190, 18);

  FMaxFrequencyEdit := TEdit.Create(Self);
  FMaxFrequencyEdit.Parent := Self;
  FMaxFrequencyEdit.SetBounds(216, 98, 190, 25);

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'OK';
  B.ModalResult := mrOK;
  B.SetBounds(236, 166, 80, 30);
  B.Default := True;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Отмена';
  B.ModalResult := mrCancel;
  B.SetBounds(326, 166, 80, 30);
  B.Cancel := True;
end;

function TFrequencyBandDialog.TryReadFrequency(
  const AText: string;
  out AValue: TOptionalValue<Double>
): Boolean;
var
  V: Double;
begin
  AValue.HasValue := False;
  AValue.Value := 0;

  if Trim(AText) = '' then
    Exit(True);

  Result := TryStrToFloat(Trim(AText), V);

  if not Result then
    Exit;

  if V <= 0 then
    Exit(False);

  AValue.HasValue := True;
  AValue.Value := V * 1000000;
end;

function TFrequencyBandDialog.Execute(
  ABand: TFrequencyBand
): Boolean;
var
  MinValue: TOptionalValue<Double>;
  MaxValue: TOptionalValue<Double>;
begin
  FNumberEdit.Text := ABand.Number;

  if ABand.MinFrequencyHz.HasValue then
    FMinFrequencyEdit.Text :=
      FormatFloat(
        '0.########',
        ABand.MinFrequencyHz.Value / 1000000
      )
  else
    FMinFrequencyEdit.Clear;

  if ABand.MaxFrequencyHz.HasValue then
    FMaxFrequencyEdit.Text :=
      FormatFloat(
        '0.########',
        ABand.MaxFrequencyHz.Value / 1000000
      )
  else
    FMaxFrequencyEdit.Clear;

  repeat
    Result := ShowModal = mrOK;

    if not Result then
      Exit;

    if Trim(FNumberEdit.Text) = '' then
    begin
      MessageDlg(
        'Укажите номер полосы частот.',
        mtWarning, [mbOK], 0
      );
      Continue;
    end;

    if not TryReadFrequency(FMinFrequencyEdit.Text, MinValue) then
    begin
      MessageDlg(
        'Некорректная нижняя граница частоты.',
        mtWarning, [mbOK], 0
      );
      Continue;
    end;

    if not TryReadFrequency(FMaxFrequencyEdit.Text, MaxValue) then
    begin
      MessageDlg(
        'Некорректная верхняя граница частоты.',
        mtWarning, [mbOK], 0
      );
      Continue;
    end;

    if MinValue.HasValue and MaxValue.HasValue and
       (MinValue.Value > MaxValue.Value) then
    begin
      MessageDlg(
        'Нижняя граница не может быть больше верхней.',
        mtWarning, [mbOK], 0
      );
      Continue;
    end;

    ABand.Number := Trim(FNumberEdit.Text);
    ABand.MinFrequencyHz := MinValue;
    ABand.MaxFrequencyHz := MaxValue;

    Exit(True);
  until False;
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

end.

