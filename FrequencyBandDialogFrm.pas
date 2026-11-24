unit FrequencyBandDialogFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.StdCtrls,
    DataModel,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

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


var
  FrequencyBandDialog: TFrequencyBandDialog;

implementation

{$R *.dfm}

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


end.
