
unit DocumentImage;

interface

uses
DataModel,
MainTypes,
  System.SysUtils,
  System.Classes,
  System.Types,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Imaging.pngimage;

const
  DOCUMENT_DPI = 300;

  DOCUMENT_WIDTH_MM  = 297;
  DOCUMENT_HEIGHT_MM = 210;

  DOCUMENT_WIDTH_PX  = 3508;
  DOCUMENT_HEIGHT_PX = 2480;

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


procedure DrawTextInRectMm(
  Page: TDocumentPage;
  X, Y, Width, Height: Double;
  const Text: string;
  FontSize: Integer = 8;
  Alignment: TPrintAlignment = paLeft;
  const FontName: string = 'Arial'
);

  end;

implementation

uses
  DocumentRenderer;

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
//  Result := Round(Value * DOCUMENT_DPI / 25.4);
  Result := Round(Value);
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
//    Doc.DrawTextMm(
//      dpFirst,
//      30, 30,
//      'Проверка печати',
//      14,
//      'Arial',
//      clBlack,
//      [fsBold]
//    );
//
//    Doc.DrawTextMm(
//      dpSecond,
//      30, 30,
//      'Вторая страница',
//      14
//    );

Doc.LoadBackground(dpFirst, 'BlankPage1.png');
Doc.LoadBackground(dpSecond, 'BlankPage2.png');
//DrawGeneralInformation(Doc, Doc);
    Doc.SaveDocumentImages(BasePath + 'Output');
  finally
    Doc.Free;
  end;
end;


procedure TDocumentImage.DrawTextInRectMm(
  Page: TDocumentPage;
  X, Y, Width, Height: Double;
  const Text: string;
  FontSize: Integer;
  Alignment: TPrintAlignment;
  const FontName: string
);
var
  R: TRect;
  Flags: Cardinal;
begin
  CheckPage(Page);

  if Text.Trim = '' then
    Exit;

  R := Rect(
    MmToPixels(X+5),
    MmToPixels(Y+2),
    MmToPixels(X+5 + Width),
    MmToPixels(Y+ 5 + Height)
  );

  with FPages[Page].Canvas do
  begin
    Font.Name := FontName;
    Font.Size := FontSize;
    Font.PixelsPerInch := DOCUMENT_DPI;
    Font.Color := clBlack;
    Font.Style := [];

    Brush.Style := bsClear;

    Flags := DT_WORDBREAK or DT_NOPREFIX or DT_EDITCONTROL;

    case Alignment of
      paLeft:
        Flags := Flags or DT_LEFT;

      paCenter:
        Flags := Flags or DT_CENTER;

      paRight:
        Flags := Flags or DT_RIGHT;
    end;

    Winapi.Windows.DrawText(
      Handle,
      PChar(Text),
      Length(Text),
      R,
      Flags
    );
  end;
end;

initialization

//     TestDocumentImage;

end.

