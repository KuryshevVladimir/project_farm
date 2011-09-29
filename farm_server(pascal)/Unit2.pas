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
var
  TempString: string;
  Stream: TMemoryStream;
begin
  TempString:= Trim(Socket.ReceiveText);
  RichEdit.Lines.Append(TempString);

  if TempString = '<policy-file-request/>' then
  begin
    Socket.SendText(policyInfo);
  end
    else
  begin
    Stream:= TMemoryStream.Create;
    TBlobField(SimpleDataSet.FieldByName('image')).SaveToStream(Stream);
    Stream.Position:= 0;
    Socket.SendStream(Stream);
    Stream.Free;
  end;

  //    Socket.SendText('Send Msg' + CHR(0));
  //    TempString:= Chr(0);
  //    Stream.Write(TempString[1], 1);

end;

end.
