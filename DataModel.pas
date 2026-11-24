unit DataModel;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TOptionalValue<T> = record
    HasValue: Boolean;
    Value: T;
  end;

type
  TDocumentHeader = class
  public
    DecisionNumber: string;
    DecisionDate: TOptionalValue<TDateTime>;

    EquipmentCode: string;

    FrequencyAssignmentNumber: string;
    FrequencyAssignmentDate: TOptionalValue<TDateTime>;

    SecurityClassification: string;
    SubmissionPurpose: string;
    DevelopmentStage: string;
    SupplementTo: string;

    SheetNumber: TOptionalValue<Integer>;
    SheetCount: TOptionalValue<Integer>;
  end;

  TGeneralInformation = class
  public
    Code: string;                       // 1.1
    Name: string;                       // 1.2
    TypeAndNature: string;              // 1.3
    InstallationLocation: string;       // 1.4
    Purpose: string;                    // 1.5
    UsageArea: string;                  // 1.6
    User: string;                       // 1.7
    SystemName: string;                 // 1.8
    ITURegistrationRequired: TOptionalValue<Boolean>; // 1.9
  end;

    TFrequencyBand = class
  public
    Number: string;
    MinFrequencyHz: TOptionalValue<Double>;
    MaxFrequencyHz: TOptionalValue<Double>;
  end;

    TEquipmentMode = class
  public
    ModeNumber: string;                 // 3.5
    ModeDescription: string;            // 3.6
    TransmissionType: string;            // 3.6

    FrequencyBandNumber: string;         // 3.7
    ElementaryEquipmentNumber: string;   // 3.8
    ElementaryAntennaNumber: string;     // 3.9
    RelatedAntennaNumber: string;        // 3.10
    RelatedEquipmentName: string;        // 3.11

    CharacteristicName: string;          // 3.12
    CharacteristicValue: string;         // 3.13
    CharacteristicUnit: string;          // 3.14
  end;

  TEquipmentComposition = class
  public
    TransmitterReference: string;       // 3.1
    ReceiverReference: string;          // 3.2
    AntennaReference: string;           // 3.3
    StructuralDiagramSheet: string;     // 3.4

    Modes: TObjectList<TEquipmentMode>;

    constructor Create;
    destructor Destroy; override;
  end;


    TModulationParameter = class
  public
    Name: string;
    Value: string;
    UnitName: string;
  end;

  TTransmitterMode = class
  public
    ModeNumber: string;                 // 3.5

    EmissionClass: string;              // 4.4
    EmissionClassDescription: string;   // 4.5
    FrequencyBandNumber: string;        // 4.6

    BandwidthAt3DbHz: TOptionalValue<Double>;       // 4.7
    BandwidthAt30DbHz: TOptionalValue<Double>;      // 4.8
    BandwidthAdditionalLevelDb: TOptionalValue<Double>; // 4.9

    PowerEmissionKind: string;          // 4.10
    MinPowerDbW: TOptionalValue<Double>; // 4.11
    MaxPowerDbW: TOptionalValue<Double>; // 4.12

    MaxPowerSpectralDensityDbWHz: TOptionalValue<Double>; // 4.13

    ModulationParameters: TObjectList<TModulationParameter>; // 4.14

    constructor Create;
    destructor Destroy; override;
  end;

  TTransmitter = class
  public
    OperatingFrequencies: string;       // 4.1
    FrequencyGridStep: string;          // 4.2
    FrequencyTuningType: string;        // 4.3

    OutputDeviceType: string;           // 4.15
    RelativeFrequencyInstability: string; // 4.16

    HarmonicsBelow3FpDb: TOptionalValue<Double>; // 4.17
    HarmonicsAbove3FpDb: TOptionalValue<Double>; // 4.18
    OtherSpuriousEmissions: string;     // 4.19
    NoiseEmissionLevel: TOptionalValue<Double>; // 4.20

    Modes: TObjectList<TTransmitterMode>;

    constructor Create;
    destructor Destroy; override;
  end;

    TReceiverMode = class
  public
    ModeNumber: string;                 // 3.5

    ReceivedEmissionClasses: string;    // 5.4
    FrequencyBandNumber: string;        // 5.5

    ThresholdSensitivity: TOptionalValue<Double>; // 5.6
    RealSensitivity: TOptionalValue<Double>;      // 5.7
    ProtectionRatioDb: TOptionalValue<Double>;    // 5.8

    InterferenceType: string;           // 5.9

    UhfBandwidthAt3DbHz: TOptionalValue<Double>;  // 5.10
    UhfBandwidthAt30DbHz: TOptionalValue<Double>; // 5.11
    UhfBandwidthAdditionalLevelDb: TOptionalValue<Double>; // 5.12

    HeterodyneTuning: string;           // 5.13
    IntermediateFrequencyHz: TOptionalValue<Double>; // 5.14

    IfBandwidthAt3DbHz: TOptionalValue<Double>;  // 5.15
    IfBandwidthAt30DbHz: TOptionalValue<Double>; // 5.16
    IfBandwidthAdditionalLevelDb: TOptionalValue<Double>; // 5.17
  end;

  TReceiver = class
  public
    ReceiverType: string;               // 5.1
    OperatingFrequencies: string;       // 5.2
    FrequencyGridStep: string;          // 5.3

    Modes: TObjectList<TReceiverMode>;

    HeterodyneFrequencyInstability: string; // 5.18

    AdjacentChannelSelectivityDb: TOptionalValue<Double>; // 5.19
    ImageChannelSelectivityDb: TOptionalValue<Double>;    // 5.20
    OtherSpuriousResponseSelectivityDb: TOptionalValue<Double>; // 5.21

    BlockingAndCrossModulationDb: TOptionalValue<Double>; // 5.22
    IntermodulationSelectivityDb: TOptionalValue<Double>; // 5.23

    EquivalentNoiseTemperatureK: TOptionalValue<Double>; // 5.24
    MaxNoiseTemperatureIncreasePercent: TOptionalValue<Double>; // 5.25

    constructor Create;
    destructor Destroy; override;
  end;


    TAntenna = class
  public
    AntennaNumber: string;              // 6.0
    AntennaPurpose: string;             // 6.1
    AntennaType: string;                // 6.2
    AntennaDimensions: string;          // 6.3

    ModeNumbers: string;                // 3.5: например 1,3,5 или 1...4

    BeamReference: string;              // 6.4
    BeamSpatialPosition: string;        // 6.5

    FrequencyHz: TOptionalValue<Double>; // 6.6
    GainDb: TOptionalValue<Double>;     // 6.7

    BeamwidthHorizontalDeg: TOptionalValue<Double>; // 6.8
    BeamwidthVerticalDeg: TOptionalValue<Double>;   // 6.9

    AngularSectorDeg: string;           // 6.10
    SideLobeLevelDb: TOptionalValue<Double>; // 6.11
    PointingAccuracyDeg: TOptionalValue<Double>; // 6.12

    CoverageArea: string;               // 6.13
  end;

    TFeeder = class
  public
    FeederType: string;                 // 7.1
    CriticalFrequency: string;          // 7.2
    WaveImpedance: string;              // 7.3

    AttenuationReceiveDb: TOptionalValue<Double>;  // 7.4
    AttenuationTransmitDb: TOptionalValue<Double>; // 7.5

    PolarizationCharacteristics: string; // 7.6
  end;

    TEmcInformation = class
  public
    EmcMeasures: string;
  end;

    TOrganizationInfo = class
  public
    OrganizationName: string;
    AddressAndPhone: string;
    SignatureDetails: string;
  end;


    TTechnicalDocument = class
  public
    DocumentVersion: Integer;

    Header: TDocumentHeader;
    GeneralInformation: TGeneralInformation;

    TransmitterFrequencyBands: TObjectList<TFrequencyBand>;
    ReceiverFrequencyBands: TObjectList<TFrequencyBand>;

    EquipmentComposition: TEquipmentComposition;
    Transmitter: TTransmitter;
    Receiver: TReceiver;

    Antennas: TObjectList<TAntenna>;
    Feeder: TFeeder;
    EmcInformation: TEmcInformation;

    Customer: TOrganizationInfo;
    Developer: TOrganizationInfo;
    Manufacturer: TOrganizationInfo;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TEquipmentComposition.Create;
begin
  inherited Create;
  Modes := TObjectList<TEquipmentMode>.Create(True);
end;

destructor TEquipmentComposition.Destroy;
begin
  Modes.Free;
  inherited Destroy;
end;

constructor TTransmitterMode.Create;
begin
  inherited Create;
  ModulationParameters :=
    TObjectList<TModulationParameter>.Create(True);
end;

destructor TTransmitterMode.Destroy;
begin
  ModulationParameters.Free;
  inherited Destroy;
end;

constructor TTransmitter.Create;
begin
  inherited Create;
  Modes := TObjectList<TTransmitterMode>.Create(True);
end;

destructor TTransmitter.Destroy;
begin
  Modes.Free;
  inherited Destroy;
end;

constructor TReceiver.Create;
begin
  inherited Create;
  Modes := TObjectList<TReceiverMode>.Create(True);
end;

destructor TReceiver.Destroy;
begin
  Modes.Free;
  inherited Destroy;
end;

constructor TTechnicalDocument.Create;
begin
  inherited Create;

  DocumentVersion := 1;

  Header := TDocumentHeader.Create;
  GeneralInformation := TGeneralInformation.Create;

  TransmitterFrequencyBands := TObjectList<TFrequencyBand>.Create(True);
  ReceiverFrequencyBands := TObjectList<TFrequencyBand>.Create(True);

  EquipmentComposition := TEquipmentComposition.Create;
  Transmitter := TTransmitter.Create;
  Receiver := TReceiver.Create;

  Antennas := TObjectList<TAntenna>.Create(True);

  Feeder := TFeeder.Create;
  EmcInformation := TEmcInformation.Create;

  Customer := TOrganizationInfo.Create;
  Developer := TOrganizationInfo.Create;
  Manufacturer := TOrganizationInfo.Create;
end;

destructor TTechnicalDocument.Destroy;
begin
  Header.Free;
  GeneralInformation.Free;

  TransmitterFrequencyBands.Free;
  ReceiverFrequencyBands.Free;

  EquipmentComposition.Free;
  Transmitter.Free;
  Receiver.Free;

  Antennas.Free;

  Feeder.Free;
  EmcInformation.Free;

  Customer.Free;
  Developer.Free;
  Manufacturer.Free;

  inherited Destroy;
end;

end.
