package {
    import flash.display.Sprite;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.Security;

    public class FarmClient extends Sprite {

		private var xmlSock:XMLSocket;
		private var binSock:Socket;
		
		private var GameField:Sprite;
		private var ToolBar:Sprite;
		
        public function FarmClient() {
            
			Security.loadPolicyFile('xmlsocket://localhost:3000');						
			
			xmlSock = new XMLSocket;
			xmlSock.addEventListener(Event.CONNECT, onXmlSocketConnect); 
			xmlSock.addEventListener(DataEvent.DATA, onXmlSocketData);
	
			binSock = new Socket;
			binSock.addEventListener(ProgressEvent.SOCKET_DATA, onBinSocketData);
			
			xmlSock.connect("127.0.0.1", 3000);			
        }
		
		private function onXmlSocketConnect(event:Event):void 
		{ 
			trace("Соединение установлено...");
			binSock.connect("127.0.0.1", 4000);
		} 
		
		private function onXmlSocketData(event:DataEvent):void
		{
			trace(event.toString());
		}
		
		private function onBinSocketData(event:ProgressEvent):void
		{				
			trace(event.toString());
			
			var BinaryData:ByteArray = new ByteArray;
			event.target.readBytes(BinaryData);
			//loader.loadBytes(BinaryData);	
		}
    }
}

