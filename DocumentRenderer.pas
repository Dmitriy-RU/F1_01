
unit DocumentRenderer;

interface

uses
System.Math,
System.Variants,

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

procedure DrawSection3(
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


type
  TEquipmentModeColumn = (
    emcModeNumber,                 // 3.5
    emcModeDescription,            // 3.6
    emcFrequencyBandNumber,        // 3.7
    emcElementaryEquipmentNumber,   // 3.8
    emcElementaryAntennaNumber,     // 3.9
    emcRelatedAntennaNumber,       // 3.10
    emcRelatedEquipmentName,      // 3.11
    emcCharacteristicName,        // 3.12
    emcCharacteristicValue,       // 3.13
    emcCharacteristicUnit         // 3.14
  );

const
  EQUIPMENT_MODES_VISIBLE_ROWS = 4;

var
  EquipmentModeCoordinates:
    array[1..EQUIPMENT_MODES_VISIBLE_ROWS,
          TEquipmentModeColumn] of TPrintRectMm;


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

//with PrintFieldCoordinates[XXXXXX] do
//begin
//  Page := dpFirst;
//  X := XXXX;
//  Y := YYYY;
//  Width := WWWW;
//  Height := XXXX;
//end;
with PrintFieldCoordinates[pfTransmitterReference] do
begin
  Page := dpFirst;
  X := 740;
  Y := 915;
  Width := 350;
  Height := 60;
end;
with PrintFieldCoordinates[pfReceiverReference] do
begin
  Page := dpFirst;
  X := 1360;
  Y := 915;
  Width := 367;
  Height := 60;
end;
with PrintFieldCoordinates[pfAntennaReference] do
begin
  Page := dpFirst;
  X := 1905;
  Y := 915;
  Width := 350;
  Height := 60;
end;
with PrintFieldCoordinates[pfStructuralDiagramSheet] do
begin
  Page := dpFirst;
  X := 3170;
  Y := 915;
  Width := 180;
  Height := 60;
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


procedure DrawPrintField(
  AImage: TDocumentImage;
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



procedure DrawGeneralInformation(
  const ADocument: TTechnicalDocument;
  AImage: TDocumentImage
);
var
  Info: TGeneralInformation;


begin
  if not Assigned(ADocument) then
    Exit;

  if not Assigned(AImage) then
    Exit;

  Info := ADocument.GeneralInformation;

  if not Assigned(Info) then
    Exit;

DrawPrintField(AImage, pfCode,  Info.Code);
DrawPrintField(AImage, pfName, Info.Name);
DrawPrintField(AImage, pfTypeAndNature,  Info.TypeAndNature);
DrawPrintField(AImage, pfInstallationLocation, Info.InstallationLocation);
DrawPrintField(AImage, pfPurpose,  Info.Purpose);
DrawPrintField(AImage, pfUsageArea, Info.UsageArea);
DrawPrintField(AImage, pfUser,  Info.User);
DrawPrintField(AImage, pfSystemName, Info.SystemName);
DrawPrintField(AImage, pfITURegistrationRequired,  'Да');

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


procedure DrawEquipmentCompositionReferences(
  AImage: TDocumentImage;
  const ADocument: TTechnicalDocument
);
begin
  if not Assigned(AImage) or not Assigned(ADocument) then
    Exit;

  DrawPrintField(
    AImage,
    pfTransmitterReference,
    ADocument.EquipmentComposition.TransmitterReference
  );

  DrawPrintField(
    AImage,
    pfReceiverReference,
    ADocument.EquipmentComposition.ReceiverReference
  );

  DrawPrintField(
    AImage,
    pfAntennaReference,
    ADocument.EquipmentComposition.AntennaReference
  );

  DrawPrintField(
    AImage,
    pfStructuralDiagramSheet,
    ADocument.EquipmentComposition.StructuralDiagramSheet
  );
end;



procedure InitializeEquipmentModeCoordinates;
var
  Row: Integer;
  Column: TEquipmentModeColumn;
const
  RowY:array[1..4] of integer =( 1215,1260, 1305, 1355);
  RowX:array[0..10] of integer =(   150,  280, 395 , 1105, 1305, 1495, 1660 , 2155, 2905,  3136, 3950);
begin
  for Row := 1 to EQUIPMENT_MODES_VISIBLE_ROWS do
    for Column := Low(TEquipmentModeColumn)
      to High(TEquipmentModeColumn) do
    begin
      with EquipmentModeCoordinates[Row, Column] do
      begin
        X := RowX[integer(Column)];
        Y := RowY[Row];
        Width := RowX[integer(Column)+1]- RowX[integer(Column)];
        Height := 45;
      end;
    end;
//with EquipmentModeCoordinates[1, emcModeNumber] do
//begin
//  X := 0;
//  Y := 0;
//  Width := 0;
//  Height := 0;
//end;

end;


procedure DrawEquipmentModeCell(
  AImage: TDocumentImage;
  Row: Integer;
  Column: TEquipmentModeColumn;
  const Value: string;
  FontSize: Integer = 7;
  Alignment: TPrintAlignment = paCenter
);
var
  C: TPrintRectMm;
begin
  if not Assigned(AImage) then
    Exit;

  if (Row < 1) or
     (Row > EQUIPMENT_MODES_VISIBLE_ROWS) then
    Exit;

  if Value.Trim = '' then
    Exit;

  C := EquipmentModeCoordinates[Row, Column];

  if (C.Width <= 0) or (C.Height <= 0) then
    Exit;

  AImage.DrawTextInRectMm(
    dpFirst,
    C.X,
    C.Y,
    C.Width,
    C.Height,
    Value,
    FontSize,
    Alignment
  );
end;


procedure DrawEquipmentMode(
  AImage: TDocumentImage;
  Row: Integer;
  const Mode: TEquipmentMode
);
var
  Description: string;
begin
  if not Assigned(Mode) then
    Exit;

  // 3.5. Номер режима
  DrawEquipmentModeCell(
    AImage, Row, emcModeNumber,
    Mode.ModeNumber
  );

  // 3.6. Краткая характеристика / тип передачи
  Description := Mode.ModeDescription;

  if Mode.TransmissionType.Trim <> '' then
  begin
    if Description.Trim <> '' then
      Description := Description + sLineBreak;

    Description := Description + Mode.TransmissionType;
  end;

  DrawEquipmentModeCell(
    AImage, Row, emcModeDescription,
    Description, 7, paCenter
  );

  // 3.7. Номер ПЛЧ
  DrawEquipmentModeCell(
    AImage, Row, emcFrequencyBandNumber,
    Mode.FrequencyBandNumber
  );

  // 3.8. Номер элементарного РЭС
  DrawEquipmentModeCell(
    AImage, Row, emcElementaryEquipmentNumber,
    Mode.ElementaryEquipmentNumber
  );

  // 3.9. Номер элементарной антенны
  DrawEquipmentModeCell(
    AImage, Row, emcElementaryAntennaNumber,
    Mode.ElementaryAntennaNumber
  );

  // 3.10. Номер функционально связанной антенны
  DrawEquipmentModeCell(
    AImage, Row, emcRelatedAntennaNumber,
    Mode.RelatedAntennaNumber
  );

  // 3.11. Имя функционально связанного РЭС
  DrawEquipmentModeCell(
    AImage, Row, emcRelatedEquipmentName,
    Mode.RelatedEquipmentName
  );

  // 3.12. Наименование характеристики
  DrawEquipmentModeCell(
    AImage, Row, emcCharacteristicName,
    Mode.CharacteristicName,
    7, paLeft
  );

  // 3.13. Значение характеристики
  DrawEquipmentModeCell(
    AImage, Row, emcCharacteristicValue,
    VarToStr(Mode.CharacteristicValue)
  );

  // 3.14. Размерность
  DrawEquipmentModeCell(
    AImage, Row, emcCharacteristicUnit,
    Mode.CharacteristicUnit
  );
end;


procedure DrawEquipmentModes(
  AImage: TDocumentImage;
  const ADocument: TTechnicalDocument
);
var
  I: Integer;
  Count: Integer;
begin
  if not Assigned(AImage) or not Assigned(ADocument) then
    Exit;

  Count := ADocument.EquipmentComposition.Modes.Count;

  if Count > EQUIPMENT_MODES_VISIBLE_ROWS then
    Count := EQUIPMENT_MODES_VISIBLE_ROWS;

  for I := 0 to Count - 1 do
    DrawEquipmentMode(
      AImage,
      I + 1,
      ADocument.EquipmentComposition.Modes[I]
    );
end;


procedure DrawSection3(
  AImage: TDocumentImage;
  const ADocument: TTechnicalDocument
);
begin
  if not Assigned(AImage) or not Assigned(ADocument) then
    Exit;
  DrawEquipmentCompositionReferences(AImage, ADocument);
  DrawEquipmentModes(AImage, ADocument);
end;


initialization

InitializePrintCoordinates;
InitializeFrequencyBandCoordinates;
InitializeEquipmentModeCoordinates;

end.

