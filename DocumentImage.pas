
unit DocumentImage;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Imaging.pngimage;

const
  DOCUMENT_DPI = 300;

  DOCUMENT_WIDTH_MM  = 210;
  DOCUMENT_HEIGHT_MM = 297;

  DOCUMENT_WIDTH_PX  = 2480;
  DOCUMENT_HEIGHT_PX = 3508;

type
  TDocumentPage = (dpFirst, dpSecond);

  TDocumentImage = class
  private
    FPages: array[TDocumentPage] of TBitmap;

    function MmToPixels(const Value: Double): Integer;
    procedure CheckPage(Page: TDocumentPage);

  public
    constructor Create;
    destructor Destroy; override;

    procedure ClearPage(Page: TDocumentPage);

    procedure LoadBackground(
      Page: TDocumentPage;
      const FileName: string
    );

    procedure DrawTextMm(
      Page: TDocumentPage;
      X, Y: Double;
      const Text: string;
      FontSize: Integer = 10;
      const FontName: string = 'Arial';
      FontColor: TColor = clBlack;
      FontStyle: TFontStyles = []
    );

    procedure SavePage(
      Page: TDocumentPage;
      const FileName: string
    );

    procedure SaveDocumentImages(
      const Directory: string
    );
  end;

implementation

constructor TDocumentImage.Create;
var
  Page: TDocumentPage;
begin
  inherited Create;

  for Page := Low(TDocumentPage) to High(TDocumentPage) do
  begin
    FPages[Page] := TBitmap.Create;
    FPages[Page].PixelFormat := pf24bit;
    FPages[Page].SetSize(
      DOCUMENT_WIDTH_PX,
      DOCUMENT_HEIGHT_PX
    );

    ClearPage(Page);
  end;
end;

destructor TDocumentImage.Destroy;
var
  Page: TDocumentPage;
begin
  for Page := Low(TDocumentPage) to High(TDocumentPage) do
    FPages[Page].Free;

  inherited Destroy;
end;

procedure TDocumentImage.CheckPage(Page: TDocumentPage);
begin
  if not Assigned(FPages[Page]) then
    raise Exception.Create('Страница не создана');
end;

function TDocumentImage.MmToPixels(
  const Value: Double
): Integer;
begin
  Result := Round(Value * DOCUMENT_DPI / 25.4);
end;

procedure TDocumentImage.ClearPage(Page: TDocumentPage);
begin
  CheckPage(Page);

  FPages[Page].Canvas.Brush.Color := clWhite;
  FPages[Page].Canvas.FillRect(
    Rect(0, 0, DOCUMENT_WIDTH_PX, DOCUMENT_HEIGHT_PX)
  );
end;

procedure TDocumentImage.LoadBackground(
  Page: TDocumentPage;
  const FileName: string
);
var
  PNG: TPNGImage;
begin
  CheckPage(Page);

  if not FileExists(FileName) then
    raise Exception.CreateFmt(
      'Файл шаблона не найден: %s',
      [FileName]
    );

  PNG := TPNGImage.Create;
  try
    PNG.LoadFromFile(FileName);

    FPages[Page].Canvas.StretchDraw(
      Rect(0, 0, DOCUMENT_WIDTH_PX, DOCUMENT_HEIGHT_PX),
      PNG
    );
  finally
    PNG.Free;
  end;
end;

procedure TDocumentImage.DrawTextMm(
  Page: TDocumentPage;
  X, Y: Double;
  const Text: string;
  FontSize: Integer;
  const FontName: string;
  FontColor: TColor;
  FontStyle: TFontStyles
);
begin
  CheckPage(Page);

  with FPages[Page].Canvas do
  begin
    Font.Name := FontName;
    Font.Size := FontSize;
    Font.PixelsPerInch := DOCUMENT_DPI;
    Font.Color := FontColor;
    Font.Style := FontStyle;

    Brush.Style := bsClear;

    TextOut(
      MmToPixels(X),
      MmToPixels(Y),
      Text
    );
  end;
end;

procedure TDocumentImage.SavePage(
  Page: TDocumentPage;
  const FileName: string
);
var
  PNG: TPNGImage;
begin
  CheckPage(Page);

  PNG := TPNGImage.Create;
  try
    PNG.Assign(FPages[Page]);
    PNG.SaveToFile(FileName);
  finally
    PNG.Free;
  end;
end;

procedure TDocumentImage.SaveDocumentImages(
  const Directory: string
);
var
  Path: string;
begin
  Path := IncludeTrailingPathDelimiter(Directory);

  if not ForceDirectories(Path) then
    raise Exception.CreateFmt(
      'Не удалось создать каталог: %s',
      [Path]
    );

  SavePage(dpFirst, Path + 'Page1.png');
  SavePage(dpSecond, Path + 'Page2.png');
end;

procedure TestDocumentImage;
var
  Doc: TDocumentImage;
  BasePath: string;
begin
  BasePath := ExtractFilePath(ParamStr(0));

  Doc := TDocumentImage.Create;
  try
    // Пока без фонового шаблона
    Doc.DrawTextMm(
      dpFirst,
      30, 30,
      'Проверка печати',
      14,
      'Arial',
      clBlack,
      [fsBold]
    );

    Doc.DrawTextMm(
      dpSecond,
      30, 30,
      'Вторая страница',
      14
    );

    Doc.SaveDocumentImages(BasePath + 'Output');
  finally
    Doc.Free;
  end;
end;

initialization

     TestDocumentImage;

end.

