
unit DataValidation;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  DataModel;

type
  TValidationSeverity = (vsWarning, vsError);

  TValidationMessage = record
    Severity: TValidationSeverity;
    Section: string;
    Field: string;
    Message: string;
  end;

  TDataValidation = class
  private
    class procedure AddMessage(
      AMessages: TList<TValidationMessage>;
      ASeverity: TValidationSeverity;
      const ASection, AField, AText: string); static;

    class procedure ValidateHeader(
      ADocument: TTechnicalDocument;
      AMessages: TList<TValidationMessage>); static;

    class procedure ValidateFrequencyBands(
      ADocument: TTechnicalDocument;
      AMessages: TList<TValidationMessage>); static;

    class procedure ValidateComposition(
      ADocument: TTechnicalDocument;
      AMessages: TList<TValidationMessage>); static;

    class procedure ValidateTransmitter(
      ADocument: TTechnicalDocument;
      AMessages: TList<TValidationMessage>); static;

    class procedure ValidateReceiver(
      ADocument: TTechnicalDocument;
      AMessages: TList<TValidationMessage>); static;

    class procedure ValidateAntennas(
      ADocument: TTechnicalDocument;
      AMessages: TList<TValidationMessage>); static;

  public
    class function Validate(
      ADocument: TTechnicalDocument): TArray<TValidationMessage>; static;

    class function HasErrors(
      const AMessages: TArray<TValidationMessage>): Boolean; static;

    class function FormatMessages(
      const AMessages: TArray<TValidationMessage>): string; static;
  end;

implementation



// ------------------------------------------------------------
// Добавление сообщения
// ------------------------------------------------------------

class procedure TDataValidation.AddMessage(
  AMessages: TList<TValidationMessage>;
  ASeverity: TValidationSeverity;
  const ASection, AField, AText: string);
var
  Item: TValidationMessage;
begin
  Item.Severity := ASeverity;
  Item.Section := ASection;
  Item.Field := AField;
  Item.Message := AText;

  AMessages.Add(Item);
end;

// ------------------------------------------------------------
// Проверка необязательного числа
// ------------------------------------------------------------

procedure CheckPositive(
  const AValue: TOptionalValue<Double>;
  const ASection, AField: string;
  AMessages: TList<TValidationMessage>);
begin
  if AValue.HasValue and (AValue.Value <= 0) then
    TDataValidation.AddMessage(
      AMessages, vsError, ASection, AField,
      'Значение должно быть больше нуля.');
end;

procedure CheckNonNegative(
  const AValue: TOptionalValue<Double>;
  const ASection, AField: string;
  AMessages: TList<TValidationMessage>);
begin
  if AValue.HasValue and (AValue.Value < 0) then
    TDataValidation.AddMessage(
      AMessages, vsError, ASection, AField,
      'Значение не может быть отрицательным.');
end;

// ------------------------------------------------------------
// Проверка шапки
// ------------------------------------------------------------

class procedure TDataValidation.ValidateHeader(
  ADocument: TTechnicalDocument;
  AMessages: TList<TValidationMessage>);
begin
  if ADocument.Header.DecisionDate.HasValue and
     (ADocument.Header.DecisionDate.Value <= 0) then
    AddMessage(AMessages, vsError, 'Шапка', 'DecisionDate',
      'Некорректная дата решения.');

  if ADocument.Header.FrequencyAssignmentDate.HasValue and
     (ADocument.Header.FrequencyAssignmentDate.Value <= 0) then
    AddMessage(AMessages, vsError, 'Шапка',
      'FrequencyAssignmentDate',
      'Некорректная дата присвоения частот.');

  if ADocument.Header.SheetNumber.HasValue and
     (ADocument.Header.SheetNumber.Value <= 0) then
    AddMessage(AMessages, vsError, 'Шапка', 'SheetNumber',
      'Номер листа должен быть больше нуля.');

  if ADocument.Header.SheetCount.HasValue and
     (ADocument.Header.SheetCount.Value <= 0) then
    AddMessage(AMessages, vsError, 'Шапка', 'SheetCount',
      'Количество листов должно быть больше нуля.');

  if ADocument.Header.SheetNumber.HasValue and
     ADocument.Header.SheetCount.HasValue and
     (ADocument.Header.SheetNumber.Value >
      ADocument.Header.SheetCount.Value) then
    AddMessage(AMessages, vsError, 'Шапка', 'SheetNumber',
      'Номер листа не может превышать общее количество листов.');
end;

// ------------------------------------------------------------
// Проверка частотных полос
// ------------------------------------------------------------

class procedure TDataValidation.ValidateFrequencyBands(
  ADocument: TTechnicalDocument;
  AMessages: TList<TValidationMessage>);
var
  Band: TFrequencyBand;
  I, J: Integer;
begin
  for I := 0 to ADocument.TransmitterFrequencyBands.Count - 1 do
  begin
    Band := ADocument.TransmitterFrequencyBands[I];

    CheckPositive(Band.MinFrequencyHz, 'Полосы ПРД',
      'MinFrequencyHz', AMessages);
    CheckPositive(Band.MaxFrequencyHz, 'Полосы ПРД',
      'MaxFrequencyHz', AMessages);

    if Band.MinFrequencyHz.HasValue and
       Band.MaxFrequencyHz.HasValue and
       (Band.MinFrequencyHz.Value > Band.MaxFrequencyHz.Value) then
      AddMessage(AMessages, vsError, 'Полосы ПРД', Band.Number,
        'Начальная частота превышает конечную.');

    if Trim(Band.Number) = '' then
      AddMessage(AMessages, vsWarning, 'Полосы ПРД',
        'Number', 'Не указан номер полосы.');

    for J := 0 to I - 1 do
      if SameText(Band.Number,
        ADocument.TransmitterFrequencyBands[J].Number) then
        AddMessage(AMessages, vsError, 'Полосы ПРД',
          Band.Number, 'Повторяется номер полосы частот.');
  end;

  for I := 0 to ADocument.ReceiverFrequencyBands.Count - 1 do
  begin
    Band := ADocument.ReceiverFrequencyBands[I];

    CheckPositive(Band.MinFrequencyHz, 'Полосы ПРМ',
      'MinFrequencyHz', AMessages);
    CheckPositive(Band.MaxFrequencyHz, 'Полосы ПРМ',
      'MaxFrequencyHz', AMessages);

    if Band.MinFrequencyHz.HasValue and
       Band.MaxFrequencyHz.HasValue and
       (Band.MinFrequencyHz.Value > Band.MaxFrequencyHz.Value) then
      AddMessage(AMessages, vsError, 'Полосы ПРМ', Band.Number,
        'Начальная частота превышает конечную.');

    if Trim(Band.Number) = '' then
      AddMessage(AMessages, vsWarning, 'Полосы ПРМ',
        'Number', 'Не указан номер полосы.');

    for J := 0 to I - 1 do
      if SameText(Band.Number,
        ADocument.ReceiverFrequencyBands[J].Number) then
        AddMessage(AMessages, vsError, 'Полосы ПРМ',
          Band.Number, 'Повторяется номер полосы частот.');
  end;
end;

// ------------------------------------------------------------
// Поиск номера режима
// ------------------------------------------------------------

function EquipmentModeExists(
  ADocument: TTechnicalDocument;
  const AModeNumber: string): Boolean;
var
  Item: TEquipmentMode;
begin
  Result := False;

  for Item in ADocument.EquipmentComposition.Modes do
    if SameText(Trim(Item.ModeNumber), Trim(AModeNumber)) then
      Exit(True);
end;

// ------------------------------------------------------------
// Поиск номера полосы ПРД
// ------------------------------------------------------------

function TransmitterBandExists(
  ADocument: TTechnicalDocument;
  const ANumber: string): Boolean;
var
  Item: TFrequencyBand;
begin
  Result := False;

  for Item in ADocument.TransmitterFrequencyBands do
    if SameText(Trim(Item.Number), Trim(ANumber)) then
      Exit(True);
end;

// ------------------------------------------------------------
// Поиск номера полосы ПРМ
// ------------------------------------------------------------

function ReceiverBandExists(
  ADocument: TTechnicalDocument;
  const ANumber: string): Boolean;
var
  Item: TFrequencyBand;
begin
  Result := False;

  for Item in ADocument.ReceiverFrequencyBands do
    if SameText(Trim(Item.Number), Trim(ANumber)) then
      Exit(True);
end;

// ------------------------------------------------------------
// Проверка состава оборудования и режимов
// ------------------------------------------------------------

class procedure TDataValidation.ValidateComposition(
  ADocument: TTechnicalDocument;
  AMessages: TList<TValidationMessage>);
var
  I, J: Integer;
  Item: TEquipmentMode;
begin
  for I := 0 to ADocument.EquipmentComposition.Modes.Count - 1 do
  begin
    Item := ADocument.EquipmentComposition.Modes[I];

    if Trim(Item.ModeNumber) = '' then
      AddMessage(AMessages, vsError, 'Состав и ТТХ',
        'ModeNumber', 'У режима не указан номер.');

    for J := 0 to I - 1 do
      if SameText(Trim(Item.ModeNumber),
        Trim(ADocument.EquipmentComposition.Modes[J].ModeNumber)) then
        AddMessage(AMessages, vsError, 'Состав и ТТХ',
          Item.ModeNumber, 'Номер режима повторяется.');
  end;
end;

// ------------------------------------------------------------
// Проверка передатчика
// ------------------------------------------------------------

class procedure TDataValidation.ValidateTransmitter(
  ADocument: TTechnicalDocument;
  AMessages: TList<TValidationMessage>);
var
  Item: TTransmitterMode;
begin
  CheckNonNegative(ADocument.Transmitter.HarmonicsBelow3FpDb,
    'Передатчик', 'HarmonicsBelow3FpDb', AMessages);

  CheckNonNegative(ADocument.Transmitter.HarmonicsAbove3FpDb,
    'Передатчик', 'HarmonicsAbove3FpDb', AMessages);

  for Item in ADocument.Transmitter.Modes do
  begin
    if not EquipmentModeExists(ADocument, Item.ModeNumber) then
      AddMessage(AMessages, vsError, 'Передатчик',
        Item.ModeNumber,
        'Режим не найден в разделе «Состав и ТТХ».');

    if (Trim(Item.FrequencyBandNumber) <> '') and
       not TransmitterBandExists(
         ADocument, Item.FrequencyBandNumber) then
      AddMessage(AMessages, vsError, 'Передатчик',
        Item.FrequencyBandNumber,
        'Указанная полоса отсутствует в таблице полос ПРД.');

    CheckPositive(Item.BandwidthAt3DbHz,
      'Передатчик', 'BandwidthAt3DbHz', AMessages);

    CheckPositive(Item.BandwidthAt30DbHz,
      'Передатчик', 'BandwidthAt30DbHz', AMessages);

    if Item.MinPowerDbW.HasValue and
       Item.MaxPowerDbW.HasValue and
       (Item.MinPowerDbW.Value > Item.MaxPowerDbW.Value) then
      AddMessage(AMessages, vsError, 'Передатчик',
        Item.ModeNumber,
        'Минимальная мощность превышает максимальную.');
  end;
end;

// ------------------------------------------------------------
// Проверка приёмника
// ------------------------------------------------------------

class procedure TDataValidation.ValidateReceiver(
  ADocument: TTechnicalDocument;
  AMessages: TList<TValidationMessage>);
var
  Item: TReceiverMode;
begin
  for Item in ADocument.Receiver.Modes do
  begin
    if not EquipmentModeExists(ADocument, Item.ModeNumber) then
      AddMessage(AMessages, vsError, 'Приёмник',
        Item.ModeNumber,
        'Режим не найден в разделе «Состав и ТТХ».');

    if (Trim(Item.FrequencyBandNumber) <> '') and
       not ReceiverBandExists(
         ADocument, Item.FrequencyBandNumber) then
      AddMessage(AMessages, vsError, 'Приёмник',
        Item.FrequencyBandNumber,
        'Указанная полоса отсутствует в таблице полос ПРМ.');

    CheckPositive(Item.ThresholdSensitivity,
      'Приёмник', 'ThresholdSensitivity', AMessages);

    CheckPositive(Item.RealSensitivity,
      'Приёмник', 'RealSensitivity', AMessages);

    CheckPositive(Item.UhfBandwidthAt3DbHz,
      'Приёмник', 'UhfBandwidthAt3DbHz', AMessages);

    CheckPositive(Item.UhfBandwidthAt30DbHz,
      'Приёмник', 'UhfBandwidthAt30DbHz', AMessages);

    CheckPositive(Item.IntermediateFrequencyHz,
      'Приёмник', 'IntermediateFrequencyHz', AMessages);
  end;
end;

// ------------------------------------------------------------
// Проверка антенн
// ------------------------------------------------------------

class procedure TDataValidation.ValidateAntennas(
  ADocument: TTechnicalDocument;
  AMessages: TList<TValidationMessage>);
var
  Item: TAntenna;
begin
  for Item in ADocument.Antennas do
  begin
    CheckPositive(Item.FrequencyHz,
      'Антенны', 'FrequencyHz', AMessages);

    CheckNonNegative(Item.GainDb,
      'Антенны', 'GainDb', AMessages);

    CheckPositive(Item.BeamwidthHorizontalDeg,
      'Антенны', 'BeamwidthHorizontalDeg', AMessages);

    CheckPositive(Item.BeamwidthVerticalDeg,
      'Антенны', 'BeamwidthVerticalDeg', AMessages);
  end;
end;



// ------------------------------------------------------------
// Полная проверка документа
// ------------------------------------------------------------

class function TDataValidation.Validate(
  ADocument: TTechnicalDocument): TArray<TValidationMessage>;
var
  Messages: TList<TValidationMessage>;
begin
  Messages := TList<TValidationMessage>.Create;
  try
    if ADocument = nil then
    begin
      AddMessage(Messages, vsError, 'Документ', '',
        'Документ не создан.');

      Exit(Messages.ToArray);
    end;

    ValidateHeader(ADocument, Messages);
    ValidateFrequencyBands(ADocument, Messages);
    ValidateComposition(ADocument, Messages);
    ValidateTransmitter(ADocument, Messages);
    ValidateReceiver(ADocument, Messages);
    ValidateAntennas(ADocument, Messages);

    Result := Messages.ToArray;
  finally
    Messages.Free;
  end;
end;

// ------------------------------------------------------------
// Проверка наличия ошибок
// ------------------------------------------------------------

class function TDataValidation.HasErrors(
  const AMessages: TArray<TValidationMessage>): Boolean;
var
  Item: TValidationMessage;
begin
  Result := False;

  for Item in AMessages do
    if Item.Severity = vsError then
      Exit(True);
end;

// ------------------------------------------------------------
// Формирование текстового отчёта
// ------------------------------------------------------------

class function TDataValidation.FormatMessages(
  const AMessages: TArray<TValidationMessage>): string;
var
  Item: TValidationMessage;
  Prefix: string;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    for Item in AMessages do
    begin
      if Item.Severity = vsError then
        Prefix := 'ОШИБКА'
      else
        Prefix := 'ПРЕДУПРЕЖДЕНИЕ';

      Lines.Add(Format('%s | %s | %s | %s', [
        Prefix,
        Item.Section,
        Item.Field,
        Item.Message
      ]));
    end;

    if Lines.Count = 0 then
      Result := 'Замечаний нет.'
    else
      Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

//intialization
//
//var
//  Messages: TArray<TValidationMessage>;
//begin
//  Messages := TDataValidation.Validate(FDocument);
//
//  if TDataValidation.HasErrors(Messages) then
//  begin
//    ShowMessage(
//      TDataValidation.FormatMessages(Messages));
//    Exit;
//  end;
//
//  // Переход к формированию печатного документа.
//end;

end.

