object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 409
  ClientWidth = 829
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 185
    Width = 829
    Height = 3
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ResizeStyle = rsUpdate
    ExplicitWidth = 224
  end
  object RichEdit: TRichEdit
    Left = 0
    Top = 0
    Width = 829
    Height = 185
    Align = alTop
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Panel: TPanel
    Left = 0
    Top = 188
    Width = 829
    Height = 221
    Align = alClient
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      829
      221)
    object DBNavigator1: TDBNavigator
      Left = 8
      Top = 6
      Width = 240
      Height = 25
      DataSource = DataSource
      TabOrder = 0
    end
    object DBGrid1: TDBGrid
      Left = 0
      Top = 45
      Width = 617
      Height = 176
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = DataSource
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object cbTblChoose: TComboBox
      Left = 280
      Top = 6
      Width = 145
      Height = 22
      Style = csOwnerDrawFixed
      TabOrder = 2
      OnSelect = cbTblChooseChange
    end
    object btnStart: TButton
      Left = 700
      Top = 183
      Width = 117
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1047#1072#1087#1091#1089#1082' '#1089#1077#1088#1074#1077#1088#1072
      TabOrder = 3
      OnClick = btnStartClick
    end
  end
  object ServerSocket: TServerSocket
    Active = False
    Port = 3000
    ServerType = stNonBlocking
    OnClientConnect = ServerSocketClientConnect
    OnClientDisconnect = ServerSocketClientDisconnect
    OnClientRead = ServerSocketClientRead
    Left = 24
    Top = 16
  end
  object SQLConnection: TSQLConnection
    DriverName = 'MySQL'
    GetDriverFunc = 'getSQLDriverMYSQL'
    LibraryName = 'dbxmys.dll'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=DBXMySQL'
      
        'DriverPackageLoader=TDBXDynalinkDriverLoader,DbxCommonDriver150.' +
        'bpl'
      
        'DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borla' +
        'nd.Data.DbxCommonDriver,Version=15.0.0.0,Culture=neutral,PublicK' +
        'eyToken=91d62ebb5b0d1b1b'
      
        'MetaDataPackageLoader=TDBXMySqlMetaDataCommandFactory,DbxMySQLDr' +
        'iver150.bpl'
      
        'MetaDataAssemblyLoader=Borland.Data.TDBXMySqlMetaDataCommandFact' +
        'ory,Borland.Data.DbxMySQLDriver,Version=15.0.0.0,Culture=neutral' +
        ',PublicKeyToken=91d62ebb5b0d1b1b'
      'GetDriverFunc=getSQLDriverMYSQL'
      'LibraryName=dbxmys.dll'
      'VendorLib=LIBMYSQL.dll'
      'HostName=localhost'
      'Database=farm'
      'User_Name=root'
      'Password=2713'
      'MaxBlobSize=-1'
      'LocaleCode=0000'
      'Compressed=False'
      'Encrypted=False'
      'BlobSize=-1'
      'ErrorResourceFile='
      'ServerCharSet=WIN1251')
    VendorLib = 'LIBMYSQL.dll'
    Left = 24
    Top = 72
  end
  object SimpleDataSet: TSimpleDataSet
    Aggregates = <>
    Connection = SQLConnection
    DataSet.CommandText = 'select * from plants'
    DataSet.MaxBlobSize = 1
    DataSet.Params = <>
    Params = <>
    Left = 88
    Top = 72
  end
  object DataSource: TDataSource
    DataSet = SimpleDataSet
    Left = 136
    Top = 72
  end
  object XMLDocument: TXMLDocument
    Left = 24
    Top = 120
    DOMVendorDesc = 'MSXML'
  end
  object ServerSocketBinary: TServerSocket
    Active = False
    Port = 4000
    ServerType = stNonBlocking
    OnClientConnect = ServerSocketClientConnect
    OnClientDisconnect = ServerSocketClientDisconnect
    OnClientRead = ServerSocketClientRead
    Left = 88
    Top = 16
  end
end
