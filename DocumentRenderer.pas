
unit DocumentRenderer;

interface

uses
DocumentImage,
  DataModel;

procedure DrawGeneralInformation(
  const ADocument: TTechnicalDocument;
  AImage: TDocumentImage
);

implementation

uses
  System.SysUtils;

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

begin
  if not Assigned(ADocument) then
    Exit;

  if not Assigned(AImage) then
    Exit;

  Info := ADocument.GeneralInformation;

  if not Assigned(Info) then
    Exit;

  // 1.1. Шифр РЭС
  DrawField(55, 13.5, Info.Code);

  // 1.2. Наименование РЭС
  DrawField(55, 20.0, Info.Name);

  // 1.3. Тип и характер РЭС
  DrawField(50, 33.5, Info.TypeAndNature);

  // 1.4. Место установки РЭС
  DrawField(235, 33.5, Info.InstallationLocation);

  // 1.5. Назначение РЭС
  DrawField(50, 42.5, Info.Purpose);

  // 1.6. Район использования
  DrawField(50, 53.5, Info.UsageArea);

  // 1.7. Пользователь РЭС
  DrawField(210, 53.5, Info.User);

  // 1.8. Система (комплекс)
  DrawField(82, 61.0, Info.SystemName);

  // 1.9. Необходимость регистрации в МСЭ
  if Info.ITURegistrationRequired.HasValue then
  begin
    if Info.ITURegistrationRequired.Value then
      DrawField(235, 61.0, 'Да')
    else
      DrawField(235, 61.0, 'Нет');
  end;
end;

end.

