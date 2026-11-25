
unit DocumentRenderer;

interface

uses
System.Math,

MainTypes,
DocumentImage,
  DataModel;

procedure DrawGeneralInformation(
  const ADocument: TTechnicalDocument;
  AImage: TDocumentImage
);

procedure DrawFrequencyBands(
  AImage: TDocumentImage;
  const ADocument: TTechnicalDocument
);

implementation

uses
  System.SysUtils;



type
  TPrintField = (
    // Заголовок документа
    pfDecisionNumber,
    pfDecisionDate,
    pfEquipmentCode,
    pfFrequencyAssignmentNumber,
    pfFrequencyAssignmentDate,
    pfSecurityClassification,
    pfSubmissionPurpose,
    pfDevelopmentStage,
    pfSupplementTo,
    pfSheetNumber,
    pfSheetCount,

    // Раздел 1. Общие сведения
    pfCode,
    pfName,
    pfTypeAndNature,
    pfInstallationLocation,
    pfPurpose,
    pfUsageArea,
    pfUser,
    pfSystemName,
    pfITURegistrationRequired,

    // Раздел 3. Состав и ТТХ
    pfTransmitterReference,
    pfReceiverReference,
    pfAntennaReference,
    pfStructuralDiagramSheet,

    // Раздел 4. Радиопередатчик
    pfTransmitterOperatingFrequencies,
    pfTransmitterFrequencyGridStep,
    pfTransmitterFrequencyTuningType,
    pfTransmitterOutputDeviceType,
    pfTransmitterRelativeFrequencyInstability,
    pfTransmitterHarmonicsBelow3FpDb,
    pfTransmitterHarmonicsAbove3FpDb,
    pfTransmitterOtherSpuriousEmissions,
    pfTransmitterNoiseEmissionLevel,

    // Раздел 5. Радиоприёмник
    pfReceiverType,
    pfReceiverOperatingFrequencies,
    pfReceiverFrequencyGridStep,
    pfReceiverHeterodyneFrequencyInstability,
    pfReceiverAdjacentChannelSelectivityDb,
    pfReceiverImageChannelSelectivityDb,
    pfReceiverOtherSpuriousResponseSelectivityDb,
    pfReceiverBlockingAndCrossModulationDb,
    pfReceiverIntermodulationSelectivityDb,
    pfReceiverEquivalentNoiseTemperatureK,
    pfReceiverMaxNoiseTemperatureIncreasePercent,

    // Раздел 7. Фидер
    pfFeederType,
    pfFeederCriticalFrequency,
    pfFeederWaveImpedance,
    pfFeederAttenuationReceiveDb,
    pfFeederAttenuationTransmitDb,
    pfFeederPolarizationCharacteristics,

    // Раздел 8. ЭМС
    pfEmcMeasures,

    // Раздел 9. Организации
    pfCustomerOrganizationName,
    pfCustomerAddressAndPhone,
    pfCustomerSignatureDetails,

    pfDeveloperOrganizationName,
    pfDeveloperAddressAndPhone,
    pfDeveloperSignatureDetails,

    pfManufacturerOrganizationName,
    pfManufacturerAddressAndPhone,
    pfManufacturerSignatureDetails
  );

  TPrintFieldCoordinates = record
    Page: TDocumentPage;
    X: Double;
    Y: Double;
    Width: Double;
    Height: Double;
    FontSize: Integer;
    Alignment: TPrintAlignment;
  end;


type
  TPrintRectMm = record
    X: Double;
    Y: Double;
    Width: Double;
    Height: Double;
  end;

  TFrequencyBandPrintCoordinates = record
    Number: TPrintRectMm;
    MinFrequency: TPrintRectMm;
    MaxFrequency: TPrintRectMm;
  end;

  TFrequencyBandSide = (
    fbsTransmitter,
    fbsReceiver
  );

const
  FREQUENCY_BANDS_PER_SIDE = 3;

var
  FrequencyBandCoordinates:
    array[TFrequencyBandSide, 1..FREQUENCY_BANDS_PER_SIDE]
      of TFrequencyBandPrintCoordinates;



var
  PrintFieldCoordinates: array[TPrintField]
    of TPrintFieldCoordinates;

procedure InitializePrintCoordinates;
var
  Field: TPrintField;
begin
  for Field := Low(TPrintField) to High(TPrintField) do
  begin
    PrintFieldCoordinates[Field].Page := dpFirst;
    PrintFieldCoordinates[Field].X := 0;
    PrintFieldCoordinates[Field].Y := 0;
    PrintFieldCoordinates[Field].Width := 0;
    PrintFieldCoordinates[Field].Height := 0;
    PrintFieldCoordinates[Field].FontSize := 12;
    PrintFieldCoordinates[Field].Alignment := paLeft;
  end;
  // 1.1. Шифр РЭС
  // PrintFieldCoordinates[pfCode].X := ...;
with PrintFieldCoordinates[pfCode] do
begin
  Page := dpFirst;
  X := 1039;
  Y := 163;
  Width := 1010;
  Height := 62;
end;
  // 1.2. Наименование РЭС
  // PrintFieldCoordinates[pfName].X := ...;
with PrintFieldCoordinates[pfName] do
begin
  Page := dpFirst;
  X := 1039;
  Y := 229;
  Width := 1010;
  Height := 122;
end;
  // 1.3. Тип и характер РЭС
  // PrintFieldCoordinates[pfTypeAndNature].X := ...;
with PrintFieldCoordinates[pfTypeAndNature] do
begin
  Page := dpFirst;
  X := 634;
  Y := 375;
  Width := 1540;
  Height := 64;
end;
  // 1.4. Место установки РЭС
  // PrintFieldCoordinates[pfInstallationLocation].X := ...;
with PrintFieldCoordinates[pfInstallationLocation] do
begin
  Page := dpFirst;
  X := 2643;
  Y := 375;
  Width := 704;
  Height := 65;
end;
  // 1.5. Назначение РЭС
  // PrintFieldCoordinates[pfPurpose].X := ...;
with PrintFieldCoordinates[pfPurpose] do
begin
  Page := dpFirst;
  X := 634;
  Y := 450;
  Width := 2475;
  Height := 105;
end;
   // 1.6. Район использования
  // PrintFieldCoordinates[pfUsageArea].X := ...;
with PrintFieldCoordinates[pfUsageArea] do
begin
  Page := dpFirst;
  X := 634;
  Y := 562;
  Width := 1320;
  Height := 60;
end;
  // 1.7. Пользователь РЭС
  // PrintFieldCoordinates[pfUser].X := ...;
with PrintFieldCoordinates[pfUser] do
begin
  Page := dpFirst;
  X := 2420;
  Y := 560;
  Width := 683;
  Height := 59;
end;
   // 1.8. Система (комплекс)
  // PrintFieldCoordinates[pfSystemName].X := ...;
with PrintFieldCoordinates[pfSystemName] do
begin
  Page := dpFirst;
  X := 990;
  Y := 630;
  Width := 965;
  Height := 55;
end;
  // 1.9. Регистрация в МСЭ
  // PrintFieldCoordinates[pfITURegistrationRequired].X := ...;
with PrintFieldCoordinates[pfITURegistrationRequired] do
begin
  Page := dpFirst;
  X := 2690;
  Y := 630;
  Width := 3100;
  Height := 685;
end;
end;



procedure InitializeFrequencyBandCoordinates;
var
  Side: TFrequencyBandSide;
  I: Integer;
begin
  for Side := Low(TFrequencyBandSide)
    to High(TFrequencyBandSide) do
  begin
    for I := 1 to FREQUENCY_BANDS_PER_SIDE do
    begin
      with FrequencyBandCoordinates[Side, I] do
      begin
        Number.X := 0;
        Number.Y := 0;
        Number.Width := 0;
        Number.Height := 0;

        MinFrequency.X := 0;
        MinFrequency.Y := 0;
        MinFrequency.Width := 0;
        MinFrequency.Height := 0;

        MaxFrequency.X := 0;
        MaxFrequency.Y := 0;
        MaxFrequency.Width := 0;
        MaxFrequency.Height := 0;
      end;
    end;
  end;


  with FrequencyBandCoordinates[fbsTransmitter, 1] do
begin
  Number.X := 740;
  Number.Y := 735;
  Number.Width := 350;
  Number.Height := 50;

  MinFrequency.X := 740;
  MinFrequency.Y := 790;
  MinFrequency.Width := 215;
  MinFrequency.Height := 55;

  MaxFrequency.X := 740;
  MaxFrequency.Y := 840;
  MaxFrequency.Width := 215;
  MaxFrequency.Height := 55;
end;

  with FrequencyBandCoordinates[fbsTransmitter, 2] do
begin
  Number.X := 1090;
  Number.Y := 735;
  Number.Width := 350;
  Number.Height := 50;

  MinFrequency.X := 1090;
  MinFrequency.Y := 790;
  MinFrequency.Width := 215;
  MinFrequency.Height := 55;

  MaxFrequency.X := 1090;
  MaxFrequency.Y := 840;
  MaxFrequency.Width := 215;
  MaxFrequency.Height := 55;
end;

  with FrequencyBandCoordinates[fbsReceiver, 1] do
begin
  Number.X := 2005;
  Number.Y := 735;
  Number.Width := 350;
  Number.Height := 50;

  MinFrequency.X := 2005;
  MinFrequency.Y := 790;
  MinFrequency.Width := 215;
  MinFrequency.Height := 55;

  MaxFrequency.X := 2005;
  MaxFrequency.Y := 840;
  MaxFrequency.Width := 215;
  MaxFrequency.Height := 55;
end;

end;


procedure DrawGeneralInformation(
  const ADocument: TTechnicalDocument;
  AImage: TDocumentImage
);
var
  Info: TGeneralInformation;

  procedure DrawField(X, Y: Double; const Value: string);
  begin
    if Value.Trim <> '' then
      AImage.DrawTextMm(
        dpFirst,
        X,
        Y,
        Value,
        7,
        'Arial'
      );
  end;


procedure DrawPrintField(
  Field: TPrintField;
  const Value: string
);
var
  C: TPrintFieldCoordinates;
begin
  if not Assigned(AImage) then
    Exit;

  if Value.Trim = '' then
    Exit;

  C := PrintFieldCoordinates[Field];

  if (C.Width <= 0) or (C.Height <= 0) then
    Exit;

  AImage.DrawTextInRectMm(
    C.Page,
    C.X,
    C.Y,
    C.Width,
    C.Height,
    Value,
    C.FontSize,
    C.Alignment
  );
end;



begin
  if not Assigned(ADocument) then
    Exit;

  if not Assigned(AImage) then
    Exit;

  Info := ADocument.GeneralInformation;

  if not Assigned(Info) then
    Exit;

DrawPrintField(pfCode,  Info.Code);
DrawPrintField(pfName, Info.Name);
DrawPrintField(pfTypeAndNature,  Info.TypeAndNature);
DrawPrintField(pfInstallationLocation, Info.InstallationLocation);
DrawPrintField(pfPurpose,  Info.Purpose);
DrawPrintField(pfUsageArea, Info.UsageArea);
DrawPrintField(pfUser,  Info.User);
DrawPrintField(pfSystemName, Info.SystemName);
DrawPrintField(pfITURegistrationRequired,  'Да');

//  begin
//    if Info.ITURegistrationRequired.Value then
//      DrawField(235, 61.0, 'Да')
//    else
//      DrawField(235, 61.0, 'Нет');
//  end;
end;


procedure DrawFrequencyBand(
  AImage: TDocumentImage;
  Side: TFrequencyBandSide;
  Position: Integer;
  const Band: TFrequencyBand
);
var
  C: TFrequencyBandPrintCoordinates;

function FormatFrequencyHz(
  const Value: Double
): string;
begin
  Result := FormatFloat('0.###', Value);
end;

begin
  if not Assigned(AImage) then
    Exit;

  if not Assigned(Band) then
    Exit;

  if (Position < 1) or
     (Position > FREQUENCY_BANDS_PER_SIDE) then
    Exit;

  C := FrequencyBandCoordinates[Side, Position];

  // 2.1. Номер полосы частот
  if C.Number.Width > 0 then
    AImage.DrawTextInRectMm(
      dpFirst,
      C.Number.X,
      C.Number.Y,
      C.Number.Width,
      C.Number.Height,
      Band.Number,
      7,
      paCenter
    );

  // 2.2. Минимальная частота
  if Band.MinFrequencyHz.HasValue and
     (C.MinFrequency.Width > 0) then
    AImage.DrawTextInRectMm(
      dpFirst,
      C.MinFrequency.X,
      C.MinFrequency.Y,
      C.MinFrequency.Width,
      C.MinFrequency.Height,
      FormatFrequencyHz(Band.MinFrequencyHz.Value),
      7,
      paCenter
    );

  // 2.3. Максимальная частота
  if Band.MaxFrequencyHz.HasValue and
     (C.MaxFrequency.Width > 0) then
    AImage.DrawTextInRectMm(
      dpFirst,
      C.MaxFrequency.X,
      C.MaxFrequency.Y,
      C.MaxFrequency.Width,
      C.MaxFrequency.Height,
      FormatFrequencyHz(Band.MaxFrequencyHz.Value),
      7,
      paCenter
    );
end;


procedure DrawFrequencyBands(
  AImage: TDocumentImage;
  const ADocument: TTechnicalDocument
);
var
  I: Integer;
begin
  if not Assigned(AImage) then
    Exit;

  if not Assigned(ADocument) then
    Exit;

  // Левая таблица — ПРД
  for I := 0 to Min(
    ADocument.TransmitterFrequencyBands.Count,
    FREQUENCY_BANDS_PER_SIDE
  ) - 1 do
    DrawFrequencyBand(
      AImage,
      fbsTransmitter,
      I + 1,
      ADocument.TransmitterFrequencyBands[I]
    );

  // Правая таблица — ПРМ
  for I := 0 to Min(
    ADocument.ReceiverFrequencyBands.Count,
    FREQUENCY_BANDS_PER_SIDE
  ) - 1 do
    DrawFrequencyBand(
      AImage,
      fbsReceiver,
      I + 1,
      ADocument.ReceiverFrequencyBands[I]
    );
end;



initialization

InitializePrintCoordinates;
InitializeFrequencyBandCoordinates;

end.

