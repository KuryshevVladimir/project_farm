package {
    import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.text.TextField;
	import flash.system.Security;

    public class FarmClient extends Sprite {

		private var xmlSock:XMLSocket;
		private var binSock:Socket;
		
		private var GameField:Sprite;
		private var BackGround: Loader;
		private var ToolBar:Sprite;		
		
		//Состояния игры
		private const GAME_INITIALIZE:uint = 0;		
		private const GAME_PROCESS:uint    = 1;
		//Текущее состояние игры
		private var CurrGameState:uint;
		
		//Состояние сокета
		private const TEXT_SOCK:uint   = 0;
		private const BINARY_SOCK:uint = 1;		
		//Текущее состояние сокета
		private var CurrStateSock:uint;
		
		//Карта ф-ци в зависимости от состояния сокета
		private var StateSockMap:Array;
		
        public function FarmClient() {
            
			Security.loadPolicyFile('xmlsocket://localhost:3000');												
			
			StateSockMap = new Array;
			StateSockMap[TEXT_SOCK]   = readText;
			StateSockMap[BINARY_SOCK] = readBinary;			
			
			CurrGameState = GAME_INITIALIZE;
			CurrStateSock = TEXT_SOCK;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			GameField = new Sprite;
			BackGround = new Loader;
			addChild(GameField);
			GameField.addChild(BackGround);
			
			xmlSock = new XMLSocket;
			xmlSock.addEventListener(Event.CONNECT, onXmlSocketConnect); 
			xmlSock.addEventListener(DataEvent.DATA, onXmlSocketData);
	
			binSock = new Socket;
			binSock.addEventListener(Event.CONNECT, onBinSocketConnect);
			binSock.addEventListener(ProgressEvent.SOCKET_DATA, onBinSocketData);
			
			xmlSock.connect("127.0.0.1", 3000);				
        }
		
		private function onXmlSocketConnect(event:Event):void 
		{ 
			trace("Соединение установлено...");
			binSock.connect("127.0.0.1", 4000);
		} 
		
		private function onBinSocketConnect(event:Event):void 
		{
			if (CurrGameState == GAME_INITIALIZE)
			{
				event.target.writeUTF('<game-initialize/>')
				event.target.flush();
			}			
		}
		
		private function onXmlSocketData(event:DataEvent):void
		{
			trace(event.toString());			
		}
		
		private function onBinSocketData(event:ProgressEvent):void
		{
			trace(event.toString());
			
			if (CurrStateSock == TEXT_SOCK) setTimeout(readText, 1, event);
			if (CurrStateSock == BINARY_SOCK) setTimeout(readBinary, 1, event);
		}
				
		private function readBinary(event:ProgressEvent):void
		{		
			var BinaryData:ByteArray = new ByteArray;
			event.target.readBytes(BinaryData);			
			BackGround.loadBytes(BinaryData);
			addChild(BackGround);
		}
						
		private function readText(event:ProgressEvent):void
		{								
			var SizeText:int = 0;			
			var BinaryData:ByteArray = new ByteArray;			
			
			for (var i:int = 0; i < 4; i++)
			{
				SizeText += event.target.readUnsignedByte() * Math.pow(256, i);
			}
			var receiveXML:XML = new XML(event.target.readUTFBytes(SizeText));
			trace(receiveXML.toString());
			
			for each (var element:XML in receiveXML.elements()) 
			{ 								
				if (element.@name == 'BackGround')
				{
					event.target.readBytes(BinaryData, 0, element.@size_img);
					BackGround.loadBytes(BinaryData);			
				}
			}
			CurrGameState = GAME_PROCESS;
		}
			
    }
}

