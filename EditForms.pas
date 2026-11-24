
unit EditForms;

interface

uses
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

end.

