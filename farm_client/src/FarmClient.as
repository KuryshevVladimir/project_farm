package {
    import flash.display.*;
	import flash.geom.Point;
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
		private var MouseXY:Point; 
		
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
		
		private var tx:TextField;
		private var ldr:Loader;
		
        public function FarmClient() {
            
			Security.loadPolicyFile('xmlsocket://localhost:3000');												
			
			StateSockMap = new Array;
			StateSockMap[TEXT_SOCK]   = readText;
			StateSockMap[BINARY_SOCK] = readBinary;			
			
			CurrGameState = GAME_INITIALIZE;
			CurrStateSock = TEXT_SOCK;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			stage.addEventListener(Event.RESIZE, resizeDisplay);
			stage.addEventListener(Event.MOUSE_LEAVE, leaveDisplay);			
			
			MouseXY = new Point;
			GameField = new Sprite;
			BackGround = new Loader;
			GameField.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);  
			GameField.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);			
			addChild(GameField);
			GameField.addChild(BackGround);
			
			//для временного теста
			tx = new TextField;
			tx.text = '';
			addChild(tx);
			ldr = new Loader;
			ldr.load(new URLRequest('C:/Users/Admin/Desktop/test_task_resource/clover/4.png'));
			GameField.addChild(ldr);
			ldr.x = 115;
			ldr.y = 390;
			
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
				
		private function mouseDown(event:MouseEvent):void 
		{ 								
			MouseXY.x = event.localX;
			MouseXY.y = event.localY;
			
			event.currentTarget.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		}
		
		private function mouseMove(event:MouseEvent):void
		{				
			var x:int = event.stageX - MouseXY.x;
			var y:int = event.stageY - MouseXY.y;						
				
			event.currentTarget.x = (x > 0) ? 0 : x;
			event.currentTarget.y = (y > 0) ? 0 : y;
				
			if (stage.stageWidth - event.currentTarget.x > event.currentTarget.width) event.currentTarget.x = stage.stageWidth - event.currentTarget.width;
			if (stage.stageHeight - event.currentTarget.y > event.currentTarget.height) event.currentTarget.y = stage.stageHeight - event.currentTarget.height;				
		}
			
		private function mouseReleased(event:MouseEvent):void 
		{												
			if (GameField.hasEventListener(MouseEvent.MOUSE_MOVE))
					GameField.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		}
		
		private function resizeDisplay(event:Event):void 
		{ 		
			if (GameField.x != 0 || GameField.y != 0)
			{
				if (stage.stageWidth - GameField.x > GameField.width) GameField.x = stage.stageWidth - GameField.width;
				if (stage.stageHeight - GameField.y > GameField.height) GameField.y = stage.stageHeight - GameField.height;
				if (stage.stageWidth > GameField.width) stage.stageWidth = GameField.width;
				if (stage.stageHeight > GameField.height) stage.stageHeight = GameField.height; 				
			}	
		}
		
		private function leaveDisplay(event:Event):void
		{			
			mouseReleased(null);
		}
		
			
    }
}

