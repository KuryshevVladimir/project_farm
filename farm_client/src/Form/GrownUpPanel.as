package Form {
    import flash.display.*;	
	import flash.text.*;	
	import flash.filters.DropShadowFilter;
	import flash.events.MouseEvent;

    public class GrownUpPanel extends Sprite {
			
		private var _treelist:Array; 	
		private var _width:Number; 
		private var _height:Number;
		private var _labelOffset:uint
		private var _color:Number;		
		
		public function GrownUpPanel(treelist:Array, width:Number, height:Number, labelOffset:uint, color:Number) {
						
			_treelist = treelist; 
			_width = width;
			_height = height;
			_labelOffset = labelOffset;
			_color = color;			
						
			var background:Shape = new Shape;						
			background.graphics.lineStyle(1, 0x000000); 
			background.graphics.beginFill(_color); 
			background.graphics.drawRoundRect(0, 0, _width, getHeight(_height, _treelist.length, _labelOffset), 15);
			background.graphics.endFill();
			background.filters = [new DropShadowFilter(2)];									
			addChild(background);
			
			var format:TextFormat = new TextFormat(); 
			format.align = TextFormatAlign.CENTER; 
			format.underline = true;
			
			for (var i:uint = 0; i < _treelist.length; i++)
			{								
				_treelist[i].textField = new TextField();							
				_treelist[i].textField.text = _treelist[i].name;				
				_treelist[i].textField.width = _width;
				_treelist[i].textField.height = 20;
				_treelist[i].textField.y = i * _labelOffset;								
				_treelist[i].textField.setTextFormat(format); 			
				
				addChild(_treelist[i].textField);				
			}
		}
		
		private function getHeight(height:Number, count:uint, labelOffset:Number):uint
		{
			if (height == -1) 
			{
				return labelOffset * count;
			}			
			return height;
		}	
	}
}	