
unit DocumentRenderer;

interface

uses
MainTypes,
DocumentImage,
  DataModel;

procedure DrawGeneralInformation(
  const ADocument: TTechnicalDocument;
  AImage: TDocumentImage
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

(*
  TPrintAlignment = (
    paLeft,
    paCenter,
    paRight
  );


  TPrintFieldCoordinates = record
    X: Double;
    Y: Double;
    Width: Double;
    Height: Double;
    FontSize: Integer;
    Alignment: TPrintAlignment;
  end;

const
  PrintFieldCoordinates: array[TPrintField] of TPrintFieldCoordinates = (
    // X, Y, Width, Height, FontSize, Alignment

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.1 Code

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.2 Name

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.3 TypeAndNature

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.4 InstallationLocation

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.5 Purpose

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.6 UsageArea

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.7 User

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paLeft), // 1.8 SystemName

    (X: 0; Y: 0; Width: 0; Height: 0;
     FontSize: 8; Alignment: paCenter) // 1.9 ITURegistrationRequired
  );

  *)


var
  PrintFieldCoordinates: array[TPrintField]
    of TPrintFieldCoordinates;

procedure InitializePrintCoordinates;
var
  Field: TPrintField;
begin
  // Начальные настройки для всех полей
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

  // Здесь будут координаты полей.
  // Все размеры указаны в миллиметрах.

  // Раздел 1. Общие сведения

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

initialization

InitializePrintCoordinates

end.

