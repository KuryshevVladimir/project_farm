unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ScktComp, DateUtils, StrUtils, DBXMySQL,
  DB, SqlExpr, DBGrids, DBClient, SimpleDS, xmldom, XMLIntf, msxmldom,
  XMLDoc, ExtCtrls, DBCtrls, Mask, Grids;

type
  TForm2 = class(TForm)
    ServerSocket: TServerSocket;
    RichEdit: TRichEdit;
    btnStart: TButton;
    DBGrid1: TDBGrid;
    SQLConnection: TSQLConnection;
    SimpleDataSet: TSimpleDataSet;
    DataSource: TDataSource;
    XMLDocument: TXMLDocument;
    DBNavigator1: TDBNavigator;
    ServerSocketBinary: TServerSocket;
    cbTblChoose: TComboBox;
    Panel: TPanel;
    Splitter: TSplitter;
    Textures: TSimpleDataSet;
    PlantsType: TSimpleDataSet;
    procedure ServerSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure btnStartClick(Sender: TObject);
    procedure ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormShow(Sender: TObject);
    procedure cbTblChooseChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const

  policyInfo = '<?xml version="1.0"?>' +
               '<cross-domain-policy>' +
               '<allow-access-from domain="*" to-ports="1000-10000" />' +
               '</cross-domain-policy>' + CHR(0);
  ServerState : array[0..1] of string = ('Запуск сервера', 'Остановка сервера');


var
  Form2: TForm2;


implementation

{$R *.dfm}

procedure TForm2.cbTblChooseChange(Sender: TObject);
begin
 SimpleDataSet.Close;
 SimpleDataSet.DataSet.CommandText:= 'select * from ' + (Sender as TComboBox).Text;
 SimpleDataSet.Open;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  btnStartClick(btnStart);
  SQLConnection.Connected:= true;
  SimpleDataSet.DataSet.CommandText:= 'show tables';
  SimpleDataSet.Open;
  Textures.Open;
  PlantsType.Open;

  while not SimpleDataSet.Eof do
  begin
    cbTblChoose.Items.Append(SimpleDataSet.Fields[0].AsString);
    SimpleDataSet.Next;
  end;
 cbTblChoose.ItemIndex:= 0;
 cbTblChooseChange(cbTblChoose);
end;

procedure TForm2.btnStartClick(Sender: TObject);
var
  isStart: Boolean;
begin
  isStart:= not ServerSocket.Active;

  ServerSocket.Active:= isStart;
  RichEdit.Lines.Append(ServerState[Integer(not isStart)] + ' ' + DateTimeToStr(Date) + ' - ' + TimeToStr(Time) + '    Порт ' + IntToStr(ServerSocket.Port));
  ServerSocketBinary.Active:= isStart;
  RichEdit.Lines.Append(ServerState[Integer(not isStart)] + ' ' + DateTimeToStr(Date) + ' - ' + TimeToStr(Time) + '    Порт ' + IntToStr(ServerSocketBinary.Port));

  (Sender as TButton).Caption:= ServerState[Integer(isStart)];
end;

procedure TForm2.ServerSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  RichEdit.Lines.Append('Клиент подключился ' + DateTimeToStr(Date) + ' - ' + TimeToStr(Time) + '    Порт ' + IntToStr(Socket.LocalPort));
end;

procedure TForm2.ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  RichEdit.Lines.Append('Клиент отключился ' + DateTimeToStr(Date) + ' - ' + TimeToStr(Time) + '    Порт ' + IntToStr(Socket.LocalPort));
end;

procedure TForm2.ServerSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);

  function DeleteLineBreaks(const S: string): string;
  var
    Source, SourceEnd: PChar;
  begin
    Source := Pointer(S);
    SourceEnd := Source + Length(S);
    while Source < SourceEnd do
    begin
      case Source^ of
        #0: Source^ := #32;
        #10: Source^ := #32;
        #13: Source^ := #32;
      end;
      Inc(Source);
    end;
    Result := S;
  end;

  function getChar(const S: string): string;
  var
    I: Integer;
  begin
    Result:= '';
    for I := 1 to Length(S) do
    begin
      Result:= Result + '#' + IntToStr(Ord(S[I]));
    end;
  end;

var
  TempString, XMLText: AnsiString;
  Stream: TMemoryStream;
  ByteArray: array[0..3] of byte;
  SizeXMLText:Integer absolute ByteArray;
  Res:Boolean;
  ReceiveXML: TXMLDocument;
begin
  TempString:= Trim(Socket.ReceiveText);
  RichEdit.Lines.Append(TempString);

  if TempString = '<policy-file-request/>' then
  begin
    Socket.SendText(policyInfo);
  end;

  if TempString = '<game-initialize/>' then
  begin
    XMLText:= '<initialize>';
    Textures.First;
    while not Textures.Eof do
    begin
      XMLText:= XMLText + Format('<texture name="%s" size_img="%s" />', [Textures.FieldByName('name_img').AsString, Textures.FieldByName('size_img').AsString]);
      Textures.Next;
    end;

    PlantsType.First;
    while not PlantsType.Eof do
    begin
      XMLText:= XMLText + Format('<tree_type id="%s" name="%s" />', [PlantsType.FieldByName('id').AsString, PlantsType.FieldByName('name').AsString]);
      PlantsType.Next;
    end;
    XMLText:= XMLText + '</initialize>';
    SizeXMLText:= Length(XMLText);

    try
      Stream:= TMemoryStream.Create;
      Stream.Write(ByteArray[0], SizeOf(SizeXMLText));
      Stream.Write(XMLText[1], SizeXMLText);

      Textures.First;
      while not Textures.Eof do
      begin
        Stream.CopyFrom(Textures.CreateBlobStream(Textures.FieldByName('image'), bmRead), 0);
        Textures.Next;
      end;

      Stream.Position:= 0;
      Res:= Socket.SendStream(Stream);
    except
      Stream.Free;
    end;
  end;

  if Pos('<tree-grown>', TempString) <> 0 then
  begin
    ReceiveXML:= TXMLDocument.Create(Self);
    ReceiveXML.XML.Text:= TempString;
    ReceiveXML.Active:= True;
    RichEdit.Lines.Append(VarToStr(ReceiveXML.DocumentElement.ChildNodes['tree_type'].Attributes['id']));
    ReceiveXML.Free;
  end;

end;

end.
