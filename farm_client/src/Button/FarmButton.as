package Button {
    import flash.display.*;	
	import flash.text.*;	
	import flash.filters.DropShadowFilter; 

    public class FarmButton extends SimpleButton {
			
		private var _text:String; 	
		private var _width:Number; 
		private var _height:Number;
		private var _color:Number;
		
		public function FarmButton(text:String, width:Number, height:Number, color:Number) { 

			_text = text; 
			_width = width; 
			_height = height;
			_color = color;

			upState = createUpState(); 
			overState = createOverState(); 
			downState = createDownState(); 
			hitTestState = upState;
		} 

		private function createUpState():Sprite 
		{ 
			var sprite:Sprite = new Sprite();
			var background:Shape = createdColoredRectangle(_color); 
			var textField:TextField = createTextField(false);
			sprite.addChild(background);
			sprite.addChild(textField);
			return sprite;
		} 		

		private function createOverState():Sprite 
		{ 
			var sprite:Sprite = new Sprite(); 
			var background:Shape = createdColoredRectangle(_color);
			var textField:TextField = createTextField(false);
			sprite.addChild(background);
			sprite.addChild(textField);
			return sprite; 
		}

		private function createDownState():Sprite 
		{ 
			var sprite:Sprite = new Sprite();
			var background:Shape = createdColoredRectangle(_color);
			var textField:TextField = createTextField(true);
			sprite.addChild(background);
			sprite.addChild(textField);
			return sprite;
		}

		private function createdColoredRectangle(color:uint):Shape 
		{ 
			var rect:Shape = new Shape(); 
			rect.graphics.lineStyle(1, 0x000000); 
			rect.graphics.beginFill(color); 
			rect.graphics.drawRoundRect(0, 0, _width, _height, 15);
			rect.graphics.endFill();
			rect.filters = [new DropShadowFilter(2)];
			return rect;
		}

		private function createTextField(downState:Boolean):TextField 
		{ 
			var textField:TextField = new TextField();
			textField.text = _text; 
			textField.width = _width;
			textField.height = _height;
			
			var format:TextFormat = new TextFormat(); 
			format.align = TextFormatAlign.CENTER; 
			textField.setTextFormat(format); 
			
			textField.y = (_height - textField.textHeight)/2; 
			textField.y -= 2;
			if (downState) 
			{ 
				textField.x += 1; 
				textField.y += 1; 
			}
			
			return textField; 
		} 		
	}	
}	