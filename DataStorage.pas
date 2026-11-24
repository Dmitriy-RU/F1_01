
unit DataStorage;

interface

uses
  System.SysUtils,
  DataModel;

type
  EDocumentStorageError = class(Exception);

  TDataStorage = class
  public
    class function SaveToString(
      ADocument: TTechnicalDocument): string; static;

    class function LoadFromString(
      const AJson: string): TTechnicalDocument; static;

    class procedure SaveToFile(
      ADocument: TTechnicalDocument;
      const AFileName: string); static;

    class function LoadFromFile(
      const AFileName: string): TTechnicalDocument; static;
  end;

implementation

uses
  System.Classes,
  System.JSON,
  System.DateUtils,
  System.Generics.Collections;

const
  CURRENT_DOCUMENT_VERSION = 1;

// ------------------------------------------------------------
// Общие функции JSON
// ------------------------------------------------------------

function NewObject: TJSONObject;
begin
  Result := TJSONObject.Create;
end;

function NewArray: TJSONArray;
begin
  Result := TJSONArray.Create;
end;

procedure AddString(
  AObject: TJSONObject;
  const AName, AValue: string);
begin
  AObject.AddPair(AName, TJSONString.Create(AValue));
end;

procedure AddNumber(
  AObject: TJSONObject;
  const AName: string;
  AValue: Double);
begin
  AObject.AddPair(AName, TJSONNumber.Create(AValue));
end;

procedure AddInteger(
  AObject: TJSONObject;
  const AName: string;
  AValue: Integer);
begin
  AObject.AddPair(AName, TJSONNumber.Create(AValue));
end;

procedure AddBoolean(
  AObject: TJSONObject;
  const AName: string;
  AValue: Boolean);
begin
  AObject.AddPair(AName, TJSONBool.Create(AValue));
end;

function GetValue(
  AObject: TJSONObject;
  const AName: string): TJSONValue;
begin
  Result := nil;

  if AObject <> nil then
    Result := AObject.FindValue(AName);
end;

function GetString(
  AObject: TJSONObject;
  const AName: string): string;
var
  V: TJSONValue;
begin
  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit('');

  Result := V.Value;
end;

function GetDouble(
  AObject: TJSONObject;
  const AName: string;
  ADefault: Double = 0): Double;
var
  V: TJSONValue;
begin
  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit(ADefault);

  if not (V is TJSONNumber) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно содержать число.', [AName]);

  Result := TJSONNumber(V).AsDouble;
end;

function GetInteger(
  AObject: TJSONObject;
  const AName: string;
  ADefault: Integer = 0): Integer;
var
  V: TJSONValue;
begin
  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit(ADefault);

  if not (V is TJSONNumber) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно содержать целое число.', [AName]);

  Result := TJSONNumber(V).AsInt;
end;

function GetBoolean(
  AObject: TJSONObject;
  const AName: string;
  ADefault: Boolean = False): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit(ADefault);

  if not (V is TJSONBool) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно содержать логическое значение.', [AName]);

  Result := TJSONBool(V).AsBoolean;
end;

function GetObject(
  AObject: TJSONObject;
  const AName: string): TJSONObject;
var
  V: TJSONValue;
begin
  V := GetValue(AObject, AName);

  if V = nil then
    Exit(nil);

  if V is TJSONNull then
    Exit(nil);

  if not (V is TJSONObject) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно быть объектом JSON.', [AName]);

  Result := TJSONObject(V);
end;

function GetArray(
  AObject: TJSONObject;
  const AName: string): TJSONArray;
var
  V: TJSONValue;
begin
  V := GetValue(AObject, AName);

  if V = nil then
    Exit(nil);

  if V is TJSONNull then
    Exit(nil);

  if not (V is TJSONArray) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно быть массивом JSON.', [AName]);

  Result := TJSONArray(V);
end;

// ------------------------------------------------------------
// Необязательные значения
// ------------------------------------------------------------

procedure AddOptionalDouble(
  AObject: TJSONObject;
  const AName: string;
  const AValue: TOptionalValue<Double>);
begin
  if AValue.HasValue then
    AObject.AddPair(AName, TJSONNumber.Create(AValue.Value))
  else
    AObject.AddPair(AName, TJSONNull.Create);
end;

procedure AddOptionalInteger(
  AObject: TJSONObject;
  const AName: string;
  const AValue: TOptionalValue<Integer>);
begin
  if AValue.HasValue then
    AObject.AddPair(AName, TJSONNumber.Create(AValue.Value))
  else
    AObject.AddPair(AName, TJSONNull.Create);
end;

procedure AddOptionalBoolean(
  AObject: TJSONObject;
  const AName: string;
  const AValue: TOptionalValue<Boolean>);
begin
  if AValue.HasValue then
    AObject.AddPair(AName, TJSONBool.Create(AValue.Value))
  else
    AObject.AddPair(AName, TJSONNull.Create);
end;

procedure AddOptionalDate(
  AObject: TJSONObject;
  const AName: string;
  const AValue: TOptionalValue<TDateTime>);
begin
  if AValue.HasValue then
    AObject.AddPair(
      AName,
      TJSONString.Create(DateToISO8601(AValue.Value, False)))
  else
    AObject.AddPair(AName, TJSONNull.Create);
end;

function ReadOptionalDouble(
  AObject: TJSONObject;
  const AName: string): TOptionalValue<Double>;
var
  V: TJSONValue;
begin
  Result.HasValue := False;
  Result.Value := 0;

  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit;

  if not (V is TJSONNumber) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно содержать число или null.', [AName]);

  Result.HasValue := True;
  Result.Value := TJSONNumber(V).AsDouble;
end;

function ReadOptionalInteger(
  AObject: TJSONObject;
  const AName: string): TOptionalValue<Integer>;
var
  V: TJSONValue;
begin
  Result.HasValue := False;
  Result.Value := 0;

  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit;

  if not (V is TJSONNumber) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно содержать число или null.', [AName]);

  Result.HasValue := True;
  Result.Value := TJSONNumber(V).AsInt;
end;

function ReadOptionalBoolean(
  AObject: TJSONObject;
  const AName: string): TOptionalValue<Boolean>;
var
  V: TJSONValue;
begin
  Result.HasValue := False;
  Result.Value := False;

  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit;

  if not (V is TJSONBool) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно содержать Boolean или null.', [AName]);

  Result.HasValue := True;
  Result.Value := TJSONBool(V).AsBoolean;
end;

function ReadOptionalDate(
  AObject: TJSONObject;
  const AName: string): TOptionalValue<TDateTime>;
var
  V: TJSONValue;
begin
  Result.HasValue := False;
  Result.Value := 0;

  V := GetValue(AObject, AName);

  if (V = nil) or (V is TJSONNull) then
    Exit;

  if not (V is TJSONString) then
    raise EDocumentStorageError.CreateFmt(
      'Поле "%s" должно содержать дату или null.', [AName]);

  Result.Value := ISO8601ToDate(V.Value, False);
  Result.HasValue := True;
end;

// ------------------------------------------------------------
// Раздел: шапка документа
// ------------------------------------------------------------

function HeaderToJson(
  AHeader: TDocumentHeader): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'DecisionNumber', AHeader.DecisionNumber);
  AddOptionalDate(Result, 'DecisionDate', AHeader.DecisionDate);
  AddString(Result, 'EquipmentCode', AHeader.EquipmentCode);
  AddString(Result, 'FrequencyAssignmentNumber',
    AHeader.FrequencyAssignmentNumber);
  AddOptionalDate(Result, 'FrequencyAssignmentDate',
    AHeader.FrequencyAssignmentDate);
  AddString(Result, 'SecurityClassification',
    AHeader.SecurityClassification);
  AddString(Result, 'SubmissionPurpose', AHeader.SubmissionPurpose);
  AddString(Result, 'DevelopmentStage', AHeader.DevelopmentStage);
  AddString(Result, 'SupplementTo', AHeader.SupplementTo);
  AddOptionalInteger(Result, 'SheetNumber', AHeader.SheetNumber);
  AddOptionalInteger(Result, 'SheetCount', AHeader.SheetCount);
end;

procedure JsonToHeader(
  AJson: TJSONObject;
  AHeader: TDocumentHeader);
begin
  if AJson = nil then
    Exit;

  AHeader.DecisionNumber := GetString(AJson, 'DecisionNumber');
  AHeader.DecisionDate := ReadOptionalDate(AJson, 'DecisionDate');
  AHeader.EquipmentCode := GetString(AJson, 'EquipmentCode');
  AHeader.FrequencyAssignmentNumber :=
    GetString(AJson, 'FrequencyAssignmentNumber');
  AHeader.FrequencyAssignmentDate :=
    ReadOptionalDate(AJson, 'FrequencyAssignmentDate');
  AHeader.SecurityClassification :=
    GetString(AJson, 'SecurityClassification');
  AHeader.SubmissionPurpose := GetString(AJson, 'SubmissionPurpose');
  AHeader.DevelopmentStage := GetString(AJson, 'DevelopmentStage');
  AHeader.SupplementTo := GetString(AJson, 'SupplementTo');
  AHeader.SheetNumber := ReadOptionalInteger(AJson, 'SheetNumber');
  AHeader.SheetCount := ReadOptionalInteger(AJson, 'SheetCount');
end;

// ------------------------------------------------------------
// Раздел 1: общие сведения
// ------------------------------------------------------------

function GeneralInformationToJson(
  AInfo: TGeneralInformation): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'Code', AInfo.Code);
  AddString(Result, 'Name', AInfo.Name);
  AddString(Result, 'TypeAndNature', AInfo.TypeAndNature);
  AddString(Result, 'InstallationLocation', AInfo.InstallationLocation);
  AddString(Result, 'Purpose', AInfo.Purpose);
  AddString(Result, 'UsageArea', AInfo.UsageArea);
  AddString(Result, 'User', AInfo.User);
  AddString(Result, 'SystemName', AInfo.SystemName);
  AddOptionalBoolean(Result, 'ITURegistrationRequired',
    AInfo.ITURegistrationRequired);
end;

procedure JsonToGeneralInformation(
  AJson: TJSONObject;
  AInfo: TGeneralInformation);
begin
  if AJson = nil then
    Exit;

  AInfo.Code := GetString(AJson, 'Code');
  AInfo.Name := GetString(AJson, 'Name');
  AInfo.TypeAndNature := GetString(AJson, 'TypeAndNature');
  AInfo.InstallationLocation := GetString(AJson, 'InstallationLocation');
  AInfo.Purpose := GetString(AJson, 'Purpose');
  AInfo.UsageArea := GetString(AJson, 'UsageArea');
  AInfo.User := GetString(AJson, 'User');
  AInfo.SystemName := GetString(AJson, 'SystemName');
  AInfo.ITURegistrationRequired :=
    ReadOptionalBoolean(AJson, 'ITURegistrationRequired');
end;

// ------------------------------------------------------------
// Раздел 2: полосы частот
// ------------------------------------------------------------

function FrequencyBandToJson(
  ABand: TFrequencyBand): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'Number', ABand.Number);
  AddOptionalDouble(Result, 'MinFrequencyHz', ABand.MinFrequencyHz);
  AddOptionalDouble(Result, 'MaxFrequencyHz', ABand.MaxFrequencyHz);
end;

procedure JsonToFrequencyBand(
  AJson: TJSONObject;
  ABand: TFrequencyBand);
begin
  ABand.Number := GetString(AJson, 'Number');
  ABand.MinFrequencyHz := ReadOptionalDouble(AJson, 'MinFrequencyHz');
  ABand.MaxFrequencyHz := ReadOptionalDouble(AJson, 'MaxFrequencyHz');
end;

function FrequencyBandsToJson(
  ABands: TObjectList<TFrequencyBand>): TJSONArray;
var
  Band: TFrequencyBand;
begin
  Result := NewArray;

  for Band in ABands do
    Result.AddElement(FrequencyBandToJson(Band));
end;

procedure JsonToFrequencyBands(
  AJson: TJSONArray;
  ABands: TObjectList<TFrequencyBand>);
var
  I: Integer;
  Band: TFrequencyBand;
begin
  if AJson = nil then
    Exit;

  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then
      raise EDocumentStorageError.Create(
        'Элемент массива частотных полос должен быть объектом.');

    Band := TFrequencyBand.Create;
    try
      JsonToFrequencyBand(TJSONObject(AJson.Items[I]), Band);
      ABands.Add(Band);
    except
      Band.Free;
      raise;
    end;
  end;
end;



// ------------------------------------------------------------
// Раздел 3: параметры модуляции
// ------------------------------------------------------------

function ModulationParameterToJson(
  AParameter: TModulationParameter): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'Name', AParameter.Name);
  AddString(Result, 'Value', AParameter.Value);
  AddString(Result, 'UnitName', AParameter.UnitName);
end;

procedure JsonToModulationParameter(
  AJson: TJSONObject;
  AParameter: TModulationParameter);
begin
  AParameter.Name := GetString(AJson, 'Name');
  AParameter.Value := GetString(AJson, 'Value');
  AParameter.UnitName := GetString(AJson, 'UnitName');
end;

function ModulationParametersToJson(
  AParameters: TObjectList<TModulationParameter>): TJSONArray;
var
  Item: TModulationParameter;
begin
  Result := NewArray;

  for Item in AParameters do
    Result.AddElement(ModulationParameterToJson(Item));
end;

procedure JsonToModulationParameters(
  AJson: TJSONArray;
  AParameters: TObjectList<TModulationParameter>);
var
  I: Integer;
  Item: TModulationParameter;
begin
  if AJson = nil then
    Exit;

  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then
      raise EDocumentStorageError.Create(
        'Элемент параметров модуляции должен быть объектом.');

    Item := TModulationParameter.Create;
    try
      JsonToModulationParameter(
        TJSONObject(AJson.Items[I]), Item);
      AParameters.Add(Item);
    except
      Item.Free;
      raise;
    end;
  end;
end;

// ------------------------------------------------------------
// Раздел 3: режим оборудования
// ------------------------------------------------------------

function EquipmentModeToJson(
  AMode: TEquipmentMode): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'ModeNumber', AMode.ModeNumber);
  AddString(Result, 'ModeDescription', AMode.ModeDescription);
  AddString(Result, 'TransmissionType', AMode.TransmissionType);
  AddString(Result, 'FrequencyBandNumber', AMode.FrequencyBandNumber);
  AddString(Result, 'ElementaryEquipmentNumber',
    AMode.ElementaryEquipmentNumber);
  AddString(Result, 'ElementaryAntennaNumber',
    AMode.ElementaryAntennaNumber);
  AddString(Result, 'RelatedAntennaNumber',
    AMode.RelatedAntennaNumber);
  AddString(Result, 'RelatedEquipmentName',
    AMode.RelatedEquipmentName);
  AddString(Result, 'CharacteristicName', AMode.CharacteristicName);
  AddString(Result, 'CharacteristicValue', AMode.CharacteristicValue);
  AddString(Result, 'CharacteristicUnit', AMode.CharacteristicUnit);
end;

procedure JsonToEquipmentMode(
  AJson: TJSONObject;
  AMode: TEquipmentMode);
begin
  AMode.ModeNumber := GetString(AJson, 'ModeNumber');
  AMode.ModeDescription := GetString(AJson, 'ModeDescription');
  AMode.TransmissionType := GetString(AJson, 'TransmissionType');
  AMode.FrequencyBandNumber := GetString(AJson, 'FrequencyBandNumber');
  AMode.ElementaryEquipmentNumber :=
    GetString(AJson, 'ElementaryEquipmentNumber');
  AMode.ElementaryAntennaNumber :=
    GetString(AJson, 'ElementaryAntennaNumber');
  AMode.RelatedAntennaNumber :=
    GetString(AJson, 'RelatedAntennaNumber');
  AMode.RelatedEquipmentName :=
    GetString(AJson, 'RelatedEquipmentName');
  AMode.CharacteristicName :=
    GetString(AJson, 'CharacteristicName');
  AMode.CharacteristicValue :=
    GetString(AJson, 'CharacteristicValue');
  AMode.CharacteristicUnit :=
    GetString(AJson, 'CharacteristicUnit');
end;

function EquipmentModesToJson(
  AModes: TObjectList<TEquipmentMode>): TJSONArray;
var
  Item: TEquipmentMode;
begin
  Result := NewArray;

  for Item in AModes do
    Result.AddElement(EquipmentModeToJson(Item));
end;

procedure JsonToEquipmentModes(
  AJson: TJSONArray;
  AModes: TObjectList<TEquipmentMode>);
var
  I: Integer;
  Item: TEquipmentMode;
begin
  if AJson = nil then
    Exit;

  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then
      raise EDocumentStorageError.Create(
        'Элемент списка режимов оборудования должен быть объектом.');

    Item := TEquipmentMode.Create;
    try
      JsonToEquipmentMode(TJSONObject(AJson.Items[I]), Item);
      AModes.Add(Item);
    except
      Item.Free;
      raise;
    end;
  end;
end;

// ------------------------------------------------------------
// Раздел 3: состав оборудования
// ------------------------------------------------------------

function EquipmentCompositionToJson(
  AComposition: TEquipmentComposition): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'TransmitterReference',
    AComposition.TransmitterReference);
  AddString(Result, 'ReceiverReference',
    AComposition.ReceiverReference);
  AddString(Result, 'AntennaReference',
    AComposition.AntennaReference);
  AddString(Result, 'StructuralDiagramSheet',
    AComposition.StructuralDiagramSheet);

  Result.AddPair('Modes',
    EquipmentModesToJson(AComposition.Modes));
end;

procedure JsonToEquipmentComposition(
  AJson: TJSONObject;
  AComposition: TEquipmentComposition);
begin
  if AJson = nil then
    Exit;

  AComposition.TransmitterReference :=
    GetString(AJson, 'TransmitterReference');
  AComposition.ReceiverReference :=
    GetString(AJson, 'ReceiverReference');
  AComposition.AntennaReference :=
    GetString(AJson, 'AntennaReference');
  AComposition.StructuralDiagramSheet :=
    GetString(AJson, 'StructuralDiagramSheet');

  JsonToEquipmentModes(
    GetArray(AJson, 'Modes'),
    AComposition.Modes);
end;

// ------------------------------------------------------------
// Раздел 4: параметры режима передатчика
// ------------------------------------------------------------

function TransmitterModeToJson(
  AMode: TTransmitterMode): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'ModeNumber', AMode.ModeNumber);
  AddString(Result, 'EmissionClass', AMode.EmissionClass);
  AddString(Result, 'EmissionClassDescription',
    AMode.EmissionClassDescription);
  AddString(Result, 'FrequencyBandNumber',
    AMode.FrequencyBandNumber);

  AddOptionalDouble(Result, 'BandwidthAt3DbHz',
    AMode.BandwidthAt3DbHz);
  AddOptionalDouble(Result, 'BandwidthAt30DbHz',
    AMode.BandwidthAt30DbHz);
  AddOptionalDouble(Result, 'BandwidthAdditionalLevelDb',
    AMode.BandwidthAdditionalLevelDb);

  AddString(Result, 'PowerEmissionKind', AMode.PowerEmissionKind);

  AddOptionalDouble(Result, 'MinPowerDbW', AMode.MinPowerDbW);
  AddOptionalDouble(Result, 'MaxPowerDbW', AMode.MaxPowerDbW);
  AddOptionalDouble(Result, 'MaxPowerSpectralDensityDbWHz',
    AMode.MaxPowerSpectralDensityDbWHz);

  Result.AddPair('ModulationParameters',
    ModulationParametersToJson(AMode.ModulationParameters));
end;

procedure JsonToTransmitterMode(
  AJson: TJSONObject;
  AMode: TTransmitterMode);
begin
  AMode.ModeNumber := GetString(AJson, 'ModeNumber');
  AMode.EmissionClass := GetString(AJson, 'EmissionClass');
  AMode.EmissionClassDescription :=
    GetString(AJson, 'EmissionClassDescription');
  AMode.FrequencyBandNumber :=
    GetString(AJson, 'FrequencyBandNumber');

  AMode.BandwidthAt3DbHz :=
    ReadOptionalDouble(AJson, 'BandwidthAt3DbHz');
  AMode.BandwidthAt30DbHz :=
    ReadOptionalDouble(AJson, 'BandwidthAt30DbHz');
  AMode.BandwidthAdditionalLevelDb :=
    ReadOptionalDouble(AJson, 'BandwidthAdditionalLevelDb');

  AMode.PowerEmissionKind := GetString(AJson, 'PowerEmissionKind');

  AMode.MinPowerDbW := ReadOptionalDouble(AJson, 'MinPowerDbW');
  AMode.MaxPowerDbW := ReadOptionalDouble(AJson, 'MaxPowerDbW');
  AMode.MaxPowerSpectralDensityDbWHz :=
    ReadOptionalDouble(AJson, 'MaxPowerSpectralDensityDbWHz');

  JsonToModulationParameters(
    GetArray(AJson, 'ModulationParameters'),
    AMode.ModulationParameters);
end;

function TransmitterModesToJson(
  AModes: TObjectList<TTransmitterMode>): TJSONArray;
var
  Item: TTransmitterMode;
begin
  Result := NewArray;

  for Item in AModes do
    Result.AddElement(TransmitterModeToJson(Item));
end;

procedure JsonToTransmitterModes(
  AJson: TJSONArray;
  AModes: TObjectList<TTransmitterMode>);
var
  I: Integer;
  Item: TTransmitterMode;
begin
  if AJson = nil then
    Exit;

  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then
      raise EDocumentStorageError.Create(
        'Элемент режимов передатчика должен быть объектом.');

    Item := TTransmitterMode.Create;
    try
      JsonToTransmitterMode(TJSONObject(AJson.Items[I]), Item);
      AModes.Add(Item);
    except
      Item.Free;
      raise;
    end;
  end;
end;

// ------------------------------------------------------------
// Раздел 4: радиопередатчик
// ------------------------------------------------------------

function TransmitterToJson(
  ATransmitter: TTransmitter): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'OperatingFrequencies',
    ATransmitter.OperatingFrequencies);
  AddString(Result, 'FrequencyGridStep',
    ATransmitter.FrequencyGridStep);
  AddString(Result, 'FrequencyTuningType',
    ATransmitter.FrequencyTuningType);
  AddString(Result, 'OutputDeviceType',
    ATransmitter.OutputDeviceType);
  AddString(Result, 'RelativeFrequencyInstability',
    ATransmitter.RelativeFrequencyInstability);

  AddOptionalDouble(Result, 'HarmonicsBelow3FpDb',
    ATransmitter.HarmonicsBelow3FpDb);
  AddOptionalDouble(Result, 'HarmonicsAbove3FpDb',
    ATransmitter.HarmonicsAbove3FpDb);

  AddString(Result, 'OtherSpuriousEmissions',
    ATransmitter.OtherSpuriousEmissions);

  AddOptionalDouble(Result, 'NoiseEmissionLevel',
    ATransmitter.NoiseEmissionLevel);

  Result.AddPair('Modes',
    TransmitterModesToJson(ATransmitter.Modes));
end;

procedure JsonToTransmitter(
  AJson: TJSONObject;
  ATransmitter: TTransmitter);
begin
  if AJson = nil then
    Exit;

  ATransmitter.OperatingFrequencies :=
    GetString(AJson, 'OperatingFrequencies');
  ATransmitter.FrequencyGridStep :=
    GetString(AJson, 'FrequencyGridStep');
  ATransmitter.FrequencyTuningType :=
    GetString(AJson, 'FrequencyTuningType');
  ATransmitter.OutputDeviceType :=
    GetString(AJson, 'OutputDeviceType');
  ATransmitter.RelativeFrequencyInstability :=
    GetString(AJson, 'RelativeFrequencyInstability');

  ATransmitter.HarmonicsBelow3FpDb :=
    ReadOptionalDouble(AJson, 'HarmonicsBelow3FpDb');
  ATransmitter.HarmonicsAbove3FpDb :=
    ReadOptionalDouble(AJson, 'HarmonicsAbove3FpDb');

  ATransmitter.OtherSpuriousEmissions :=
    GetString(AJson, 'OtherSpuriousEmissions');

  ATransmitter.NoiseEmissionLevel :=
    ReadOptionalDouble(AJson, 'NoiseEmissionLevel');

  JsonToTransmitterModes(
    GetArray(AJson, 'Modes'),
    ATransmitter.Modes);
end;



// ------------------------------------------------------------
// Раздел 5: режим приёмника
// ------------------------------------------------------------

function ReceiverModeToJson(
  AMode: TReceiverMode): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'ModeNumber', AMode.ModeNumber);
  AddString(Result, 'ReceivedEmissionClasses',
    AMode.ReceivedEmissionClasses);
  AddString(Result, 'FrequencyBandNumber',
    AMode.FrequencyBandNumber);

  AddOptionalDouble(Result, 'ThresholdSensitivity',
    AMode.ThresholdSensitivity);
  AddOptionalDouble(Result, 'RealSensitivity',
    AMode.RealSensitivity);
  AddOptionalDouble(Result, 'ProtectionRatioDb',
    AMode.ProtectionRatioDb);

  AddString(Result, 'InterferenceType', AMode.InterferenceType);

  AddOptionalDouble(Result, 'UhfBandwidthAt3DbHz',
    AMode.UhfBandwidthAt3DbHz);
  AddOptionalDouble(Result, 'UhfBandwidthAt30DbHz',
    AMode.UhfBandwidthAt30DbHz);
  AddOptionalDouble(Result, 'UhfBandwidthAdditionalLevelDb',
    AMode.UhfBandwidthAdditionalLevelDb);

  AddString(Result, 'HeterodyneTuning', AMode.HeterodyneTuning);

  AddOptionalDouble(Result, 'IntermediateFrequencyHz',
    AMode.IntermediateFrequencyHz);
  AddOptionalDouble(Result, 'IfBandwidthAt3DbHz',
    AMode.IfBandwidthAt3DbHz);
  AddOptionalDouble(Result, 'IfBandwidthAt30DbHz',
    AMode.IfBandwidthAt30DbHz);
  AddOptionalDouble(Result, 'IfBandwidthAdditionalLevelDb',
    AMode.IfBandwidthAdditionalLevelDb);
end;

procedure JsonToReceiverMode(
  AJson: TJSONObject;
  AMode: TReceiverMode);
begin
  AMode.ModeNumber := GetString(AJson, 'ModeNumber');
  AMode.ReceivedEmissionClasses :=
    GetString(AJson, 'ReceivedEmissionClasses');
  AMode.FrequencyBandNumber :=
    GetString(AJson, 'FrequencyBandNumber');

  AMode.ThresholdSensitivity :=
    ReadOptionalDouble(AJson, 'ThresholdSensitivity');
  AMode.RealSensitivity :=
    ReadOptionalDouble(AJson, 'RealSensitivity');
  AMode.ProtectionRatioDb :=
    ReadOptionalDouble(AJson, 'ProtectionRatioDb');

  AMode.InterferenceType := GetString(AJson, 'InterferenceType');

  AMode.UhfBandwidthAt3DbHz :=
    ReadOptionalDouble(AJson, 'UhfBandwidthAt3DbHz');
  AMode.UhfBandwidthAt30DbHz :=
    ReadOptionalDouble(AJson, 'UhfBandwidthAt30DbHz');
  AMode.UhfBandwidthAdditionalLevelDb :=
    ReadOptionalDouble(AJson, 'UhfBandwidthAdditionalLevelDb');

  AMode.HeterodyneTuning := GetString(AJson, 'HeterodyneTuning');

  AMode.IntermediateFrequencyHz :=
    ReadOptionalDouble(AJson, 'IntermediateFrequencyHz');
  AMode.IfBandwidthAt3DbHz :=
    ReadOptionalDouble(AJson, 'IfBandwidthAt3DbHz');
  AMode.IfBandwidthAt30DbHz :=
    ReadOptionalDouble(AJson, 'IfBandwidthAt30DbHz');
  AMode.IfBandwidthAdditionalLevelDb :=
    ReadOptionalDouble(AJson, 'IfBandwidthAdditionalLevelDb');
end;

function ReceiverModesToJson(
  AModes: TObjectList<TReceiverMode>): TJSONArray;
var
  Item: TReceiverMode;
begin
  Result := NewArray;

  for Item in AModes do
    Result.AddElement(ReceiverModeToJson(Item));
end;

procedure JsonToReceiverModes(
  AJson: TJSONArray;
  AModes: TObjectList<TReceiverMode>);
var
  I: Integer;
  Item: TReceiverMode;
begin
  if AJson = nil then
    Exit;

  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then
      raise EDocumentStorageError.Create(
        'Элемент режимов приёмника должен быть объектом.');

    Item := TReceiverMode.Create;
    try
      JsonToReceiverMode(TJSONObject(AJson.Items[I]), Item);
      AModes.Add(Item);
    except
      Item.Free;
      raise;
    end;
  end;
end;

// ------------------------------------------------------------
// Раздел 5: радиоприёмник
// ------------------------------------------------------------

function ReceiverToJson(
  AReceiver: TReceiver): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'ReceiverType', AReceiver.ReceiverType);
  AddString(Result, 'OperatingFrequencies',
    AReceiver.OperatingFrequencies);
  AddString(Result, 'FrequencyGridStep',
    AReceiver.FrequencyGridStep);

  Result.AddPair('Modes',
    ReceiverModesToJson(AReceiver.Modes));

  AddString(Result, 'HeterodyneFrequencyInstability',
    AReceiver.HeterodyneFrequencyInstability);

  AddOptionalDouble(Result, 'AdjacentChannelSelectivityDb',
    AReceiver.AdjacentChannelSelectivityDb);
  AddOptionalDouble(Result, 'ImageChannelSelectivityDb',
    AReceiver.ImageChannelSelectivityDb);
  AddOptionalDouble(Result, 'OtherSpuriousResponseSelectivityDb',
    AReceiver.OtherSpuriousResponseSelectivityDb);
  AddOptionalDouble(Result, 'BlockingAndCrossModulationDb',
    AReceiver.BlockingAndCrossModulationDb);
  AddOptionalDouble(Result, 'IntermodulationSelectivityDb',
    AReceiver.IntermodulationSelectivityDb);
  AddOptionalDouble(Result, 'EquivalentNoiseTemperatureK',
    AReceiver.EquivalentNoiseTemperatureK);
  AddOptionalDouble(Result, 'MaxNoiseTemperatureIncreasePercent',
    AReceiver.MaxNoiseTemperatureIncreasePercent);
end;

procedure JsonToReceiver(
  AJson: TJSONObject;
  AReceiver: TReceiver);
begin
  if AJson = nil then
    Exit;

  AReceiver.ReceiverType := GetString(AJson, 'ReceiverType');
  AReceiver.OperatingFrequencies :=
    GetString(AJson, 'OperatingFrequencies');
  AReceiver.FrequencyGridStep :=
    GetString(AJson, 'FrequencyGridStep');

  JsonToReceiverModes(
    GetArray(AJson, 'Modes'),
    AReceiver.Modes);

  AReceiver.HeterodyneFrequencyInstability :=
    GetString(AJson, 'HeterodyneFrequencyInstability');

  AReceiver.AdjacentChannelSelectivityDb :=
    ReadOptionalDouble(AJson, 'AdjacentChannelSelectivityDb');
  AReceiver.ImageChannelSelectivityDb :=
    ReadOptionalDouble(AJson, 'ImageChannelSelectivityDb');
  AReceiver.OtherSpuriousResponseSelectivityDb :=
    ReadOptionalDouble(AJson, 'OtherSpuriousResponseSelectivityDb');
  AReceiver.BlockingAndCrossModulationDb :=
    ReadOptionalDouble(AJson, 'BlockingAndCrossModulationDb');
  AReceiver.IntermodulationSelectivityDb :=
    ReadOptionalDouble(AJson, 'IntermodulationSelectivityDb');
  AReceiver.EquivalentNoiseTemperatureK :=
    ReadOptionalDouble(AJson, 'EquivalentNoiseTemperatureK');
  AReceiver.MaxNoiseTemperatureIncreasePercent :=
    ReadOptionalDouble(AJson, 'MaxNoiseTemperatureIncreasePercent');
end;

// ------------------------------------------------------------
// Раздел 6: антенны
// ------------------------------------------------------------

function AntennaToJson(
  AAntenna: TAntenna): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'AntennaNumber', AAntenna.AntennaNumber);
  AddString(Result, 'AntennaPurpose', AAntenna.AntennaPurpose);
  AddString(Result, 'AntennaType', AAntenna.AntennaType);
  AddString(Result, 'AntennaDimensions', AAntenna.AntennaDimensions);
  AddString(Result, 'ModeNumbers', AAntenna.ModeNumbers);
  AddString(Result, 'BeamReference', AAntenna.BeamReference);
  AddString(Result, 'BeamSpatialPosition',
    AAntenna.BeamSpatialPosition);

  AddOptionalDouble(Result, 'FrequencyHz', AAntenna.FrequencyHz);
  AddOptionalDouble(Result, 'GainDb', AAntenna.GainDb);
  AddOptionalDouble(Result, 'BeamwidthHorizontalDeg',
    AAntenna.BeamwidthHorizontalDeg);
  AddOptionalDouble(Result, 'BeamwidthVerticalDeg',
    AAntenna.BeamwidthVerticalDeg);

  AddString(Result, 'AngularSectorDeg', AAntenna.AngularSectorDeg);

  AddOptionalDouble(Result, 'SideLobeLevelDb',
    AAntenna.SideLobeLevelDb);
  AddOptionalDouble(Result, 'PointingAccuracyDeg',
    AAntenna.PointingAccuracyDeg);

  AddString(Result, 'CoverageArea', AAntenna.CoverageArea);
end;

procedure JsonToAntenna(
  AJson: TJSONObject;
  AAntenna: TAntenna);
begin
  AAntenna.AntennaNumber := GetString(AJson, 'AntennaNumber');
  AAntenna.AntennaPurpose := GetString(AJson, 'AntennaPurpose');
  AAntenna.AntennaType := GetString(AJson, 'AntennaType');
  AAntenna.AntennaDimensions := GetString(AJson, 'AntennaDimensions');
  AAntenna.ModeNumbers := GetString(AJson, 'ModeNumbers');
  AAntenna.BeamReference := GetString(AJson, 'BeamReference');
  AAntenna.BeamSpatialPosition :=
    GetString(AJson, 'BeamSpatialPosition');

  AAntenna.FrequencyHz := ReadOptionalDouble(AJson, 'FrequencyHz');
  AAntenna.GainDb := ReadOptionalDouble(AJson, 'GainDb');
  AAntenna.BeamwidthHorizontalDeg :=
    ReadOptionalDouble(AJson, 'BeamwidthHorizontalDeg');
  AAntenna.BeamwidthVerticalDeg :=
    ReadOptionalDouble(AJson, 'BeamwidthVerticalDeg');

  AAntenna.AngularSectorDeg :=
    GetString(AJson, 'AngularSectorDeg');

  AAntenna.SideLobeLevelDb :=
    ReadOptionalDouble(AJson, 'SideLobeLevelDb');
  AAntenna.PointingAccuracyDeg :=
    ReadOptionalDouble(AJson, 'PointingAccuracyDeg');

  AAntenna.CoverageArea := GetString(AJson, 'CoverageArea');
end;

function AntennasToJson(
  AAntennas: TObjectList<TAntenna>): TJSONArray;
var
  Item: TAntenna;
begin
  Result := NewArray;

  for Item in AAntennas do
    Result.AddElement(AntennaToJson(Item));
end;

procedure JsonToAntennas(
  AJson: TJSONArray;
  AAntennas: TObjectList<TAntenna>);
var
  I: Integer;
  Item: TAntenna;
begin
  if AJson = nil then
    Exit;

  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then
      raise EDocumentStorageError.Create(
        'Элемент списка антенн должен быть объектом.');

    Item := TAntenna.Create;
    try
      JsonToAntenna(TJSONObject(AJson.Items[I]), Item);
      AAntennas.Add(Item);
    except
      Item.Free;
      raise;
    end;
  end;
end;

// ------------------------------------------------------------
// Раздел 7: фидер
// ------------------------------------------------------------

function FeederToJson(
  AFeeder: TFeeder): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'FeederType', AFeeder.FeederType);
  AddString(Result, 'CriticalFrequency', AFeeder.CriticalFrequency);
  AddString(Result, 'WaveImpedance', AFeeder.WaveImpedance);

  AddOptionalDouble(Result, 'AttenuationReceiveDb',
    AFeeder.AttenuationReceiveDb);
  AddOptionalDouble(Result, 'AttenuationTransmitDb',
    AFeeder.AttenuationTransmitDb);

  AddString(Result, 'PolarizationCharacteristics',
    AFeeder.PolarizationCharacteristics);
end;

procedure JsonToFeeder(
  AJson: TJSONObject;
  AFeeder: TFeeder);
begin
  if AJson = nil then
    Exit;

  AFeeder.FeederType := GetString(AJson, 'FeederType');
  AFeeder.CriticalFrequency :=
    GetString(AJson, 'CriticalFrequency');
  AFeeder.WaveImpedance := GetString(AJson, 'WaveImpedance');

  AFeeder.AttenuationReceiveDb :=
    ReadOptionalDouble(AJson, 'AttenuationReceiveDb');
  AFeeder.AttenuationTransmitDb :=
    ReadOptionalDouble(AJson, 'AttenuationTransmitDb');

  AFeeder.PolarizationCharacteristics :=
    GetString(AJson, 'PolarizationCharacteristics');
end;

// ------------------------------------------------------------
// Раздел 8: ЭМС
// ------------------------------------------------------------

function EmcInformationToJson(
  AInfo: TEmcInformation): TJSONObject;
begin
  Result := NewObject;
  AddString(Result, 'EmcMeasures', AInfo.EmcMeasures);
end;

procedure JsonToEmcInformation(
  AJson: TJSONObject;
  AInfo: TEmcInformation);
begin
  if AJson = nil then
    Exit;

  AInfo.EmcMeasures := GetString(AJson, 'EmcMeasures');
end;

// ------------------------------------------------------------
// Раздел 9: организации
// ------------------------------------------------------------

function OrganizationToJson(
  AOrganization: TOrganizationInfo): TJSONObject;
begin
  Result := NewObject;

  AddString(Result, 'OrganizationName',
    AOrganization.OrganizationName);
  AddString(Result, 'AddressAndPhone',
    AOrganization.AddressAndPhone);
  AddString(Result, 'SignatureDetails',
    AOrganization.SignatureDetails);
end;

procedure JsonToOrganization(
  AJson: TJSONObject;
  AOrganization: TOrganizationInfo);
begin
  if AJson = nil then
    Exit;

  AOrganization.OrganizationName :=
    GetString(AJson, 'OrganizationName');
  AOrganization.AddressAndPhone :=
    GetString(AJson, 'AddressAndPhone');
  AOrganization.SignatureDetails :=
    GetString(AJson, 'SignatureDetails');
end;



// ------------------------------------------------------------
// Корневой документ
// ------------------------------------------------------------

function DocumentToJson(
  ADocument: TTechnicalDocument): TJSONObject;
begin
  Result := NewObject;

  AddInteger(Result, 'DocumentVersion', ADocument.DocumentVersion);

  Result.AddPair('Header', HeaderToJson(ADocument.Header));
  Result.AddPair('GeneralInformation',
    GeneralInformationToJson(ADocument.GeneralInformation));

  Result.AddPair('TransmitterFrequencyBands',
    FrequencyBandsToJson(ADocument.TransmitterFrequencyBands));
  Result.AddPair('ReceiverFrequencyBands',
    FrequencyBandsToJson(ADocument.ReceiverFrequencyBands));

  Result.AddPair('EquipmentComposition',
    EquipmentCompositionToJson(ADocument.EquipmentComposition));

  Result.AddPair('Transmitter',
    TransmitterToJson(ADocument.Transmitter));
  Result.AddPair('Receiver',
    ReceiverToJson(ADocument.Receiver));

  Result.AddPair('Antennas', AntennasToJson(ADocument.Antennas));

  Result.AddPair('Feeder', FeederToJson(ADocument.Feeder));
  Result.AddPair('EmcInformation',
    EmcInformationToJson(ADocument.EmcInformation));

  Result.AddPair('Customer', OrganizationToJson(ADocument.Customer));
  Result.AddPair('Developer', OrganizationToJson(ADocument.Developer));
  Result.AddPair('Manufacturer',
    OrganizationToJson(ADocument.Manufacturer));
end;

// ------------------------------------------------------------
// Проверка и миграция версии
// ------------------------------------------------------------

procedure MigrateJson(
  AJson: TJSONObject;
  var AVersion: Integer);
begin
  // Здесь будут располагаться миграции формата.
  //
  // Например, при появлении версии 2:
  //
  // if AVersion = 1 then
  // begin
  //   MigrateVersion1To2(AJson);
  //   AVersion := 2;
  // end;

  if AVersion > CURRENT_DOCUMENT_VERSION then
    raise EDocumentStorageError.CreateFmt(
      'Версия документа (%d) новее поддерживаемой приложением (%d).',
      [AVersion, CURRENT_DOCUMENT_VERSION]);

  if AVersion < 1 then
    raise EDocumentStorageError.CreateFmt(
      'Недопустимая версия документа: %d.', [AVersion]);

  // Пока существует только версия 1.
  // Реальные миграции добавляются при изменении модели.
end;

// ------------------------------------------------------------
// Загрузка корневого документа
// ------------------------------------------------------------

procedure JsonToDocument(
  AJson: TJSONObject;
  ADocument: TTechnicalDocument);
var
  V: TJSONValue;
  DocumentVersion: Integer;
begin
  V := GetValue(AJson, 'DocumentVersion');

  if (V = nil) or (V is TJSONNull) then
    raise EDocumentStorageError.Create(
      'В JSON отсутствует DocumentVersion.');

  if not (V is TJSONNumber) then
    raise EDocumentStorageError.Create(
      'DocumentVersion должен быть целым числом.');

  DocumentVersion := TJSONNumber(V).AsInt;

  MigrateJson(AJson, DocumentVersion);

  ADocument.DocumentVersion := CURRENT_DOCUMENT_VERSION;

  JsonToHeader(
    GetObject(AJson, 'Header'),
    ADocument.Header);

  JsonToGeneralInformation(
    GetObject(AJson, 'GeneralInformation'),
    ADocument.GeneralInformation);

  JsonToFrequencyBands(
    GetArray(AJson, 'TransmitterFrequencyBands'),
    ADocument.TransmitterFrequencyBands);

  JsonToFrequencyBands(
    GetArray(AJson, 'ReceiverFrequencyBands'),
    ADocument.ReceiverFrequencyBands);

  JsonToEquipmentComposition(
    GetObject(AJson, 'EquipmentComposition'),
    ADocument.EquipmentComposition);

  JsonToTransmitter(
    GetObject(AJson, 'Transmitter'),
    ADocument.Transmitter);

  JsonToReceiver(
    GetObject(AJson, 'Receiver'),
    ADocument.Receiver);

  JsonToAntennas(
    GetArray(AJson, 'Antennas'),
    ADocument.Antennas);

  JsonToFeeder(
    GetObject(AJson, 'Feeder'),
    ADocument.Feeder);

  JsonToEmcInformation(
    GetObject(AJson, 'EmcInformation'),
    ADocument.EmcInformation);

  JsonToOrganization(
    GetObject(AJson, 'Customer'),
    ADocument.Customer);

  JsonToOrganization(
    GetObject(AJson, 'Developer'),
    ADocument.Developer);

  JsonToOrganization(
    GetObject(AJson, 'Manufacturer'),
    ADocument.Manufacturer);
end;

// ------------------------------------------------------------
// TDataStorage: сохранение в строку
// ------------------------------------------------------------

class function TDataStorage.SaveToString(
  ADocument: TTechnicalDocument): string;
var
  Json: TJSONObject;
begin
  if ADocument = nil then
    raise EDocumentStorageError.Create(
      'Не передан документ для сохранения.');

  Json := DocumentToJson(ADocument);
  try
    Result := Json.Format(2);
  finally
    Json.Free;
  end;
end;

// ------------------------------------------------------------
// TDataStorage: загрузка из строки
// ------------------------------------------------------------

class function TDataStorage.LoadFromString(
  const AJson: string): TTechnicalDocument;
var
  JsonValue: TJSONValue;
  Document: TTechnicalDocument;
begin
  JsonValue := TJSONObject.ParseJSONValue(AJson);

  if JsonValue = nil then
    raise EDocumentStorageError.Create(
      'Не удалось разобрать JSON. Проверьте формат документа.');

  try
    if not (JsonValue is TJSONObject) then
      raise EDocumentStorageError.Create(
        'Корневой элемент JSON должен быть объектом.');

    Document := TTechnicalDocument.Create;
    try
      JsonToDocument(TJSONObject(JsonValue), Document);
      Result := Document;
    except
      Document.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

// ------------------------------------------------------------
// TDataStorage: сохранение в файл
// ------------------------------------------------------------

class procedure TDataStorage.SaveToFile(
  ADocument: TTechnicalDocument;
  const AFileName: string);
var
  Json: string;
  Stream: TStringStream;
begin
  Json := SaveToString(ADocument);

  Stream := TStringStream.Create(
    Json, TEncoding.UTF8);
  try
    Stream.SaveToFile(AFileName);
  finally
    Stream.Free;
  end;
end;

// ------------------------------------------------------------
// TDataStorage: загрузка из файла
// ------------------------------------------------------------

class function TDataStorage.LoadFromFile(
  const AFileName: string): TTechnicalDocument;
var
  Stream: TStringStream;
  Json: string;
begin
  if not FileExists(AFileName) then
    raise EDocumentStorageError.CreateFmt(
      'Файл документа не найден: %s', [AFileName]);

  Stream := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.LoadFromFile(AFileName);
    Json := Stream.DataString;
  finally
    Stream.Free;
  end;

  Result := LoadFromString(Json);
end;

end.

