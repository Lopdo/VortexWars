package MapEditor
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class LogList extends Sprite
	{
		public const TYPE_ERROR:int = 1;
		public const TYPE_WARNING:int = 2;
		
		private var items:Array = new Array();
		private var textList:TextField;
		private var errorFormat:TextFormat;
		private var warningFormat:TextFormat;
		
		private var W_WIDTH:int = 200; 
		private var W_HEIGHT:int = 200;
		
		public function LogList()
		{
			super();
			this.W_WIDTH = 220;
			this.W_HEIGHT = 100;
			//this.scrollRect = new Rectangle(0, 0, W_WIDTH, W_HEIGHT);
			
			var emboss:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", W_WIDTH, W_HEIGHT);
			addChild(emboss);
			
			textList = new TextField();
			//textList.autoSize = TextFieldAutoSize.LEFT;
			textList.type = TextFieldType.DYNAMIC;
			textList.selectable = false;
			textList.multiline = textList.wordWrap = true;
			textList.x = 5;
			textList.y = 5;
			textList.width = W_WIDTH - 10;
			textList.height = W_HEIGHT - 10;
			//textList.background = true;
			//textList.backgroundColor = 0x000000;
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 12;
			tf.bold = false;
			tf.color = -1;
			tf.align = TextFormatAlign.LEFT;			
			
			textList.defaultTextFormat = tf;
			
			addChild(textList);
			
			errorFormat = new TextFormat();
			errorFormat.color = 0xe10000;
			
			warningFormat = new TextFormat();
			warningFormat.color = 0xf08800;

		}
		
		public function clearLog():void {
			for each(var i:LogItem in this.items) {
				//removeChild(i);
			}
			this.items.length = 0;
			
			this.refresh();
		}
		
		public function addError(msg:String):void {
			var item : LogItem = new LogItem(TYPE_ERROR, msg)
			item.textColor = 0xe10000;
			item.visible = false;
			item.width = W_WIDTH - 10;
			//addChild(item);
			this.items.unshift(item); 	//errors are inserted at the beginning
			this.refresh();
		}
		
		public function addWarning(msg:String):void {
			var item : LogItem = new LogItem(TYPE_WARNING, msg);
			item.textColor = 0xf08800;
			item.visible = false;
			item.width = W_WIDTH - 10;
			//addChild(item);
			this.items.push(item);	// warnings are inserted at the end
			this.refresh();
		}
		
		public function refresh():void {
			
			//graphics.beginFill(0x112233);
			//graphics.drawRect(0,0, W_WIDTH, W_HEIGHT);
			textList.text = "";
			
			if (this.items.length < 1) return;
			
			var yy:int = 10;
			for each(var i:LogItem in this.items) {
				/*i.x = 10;
				i.y = yy;
				yy += i.height + 4;
				i.visible = true;*/
				yy = textList.text.length;
				textList.appendText(i.text + "\n");
				if (i.severity == TYPE_ERROR) {
					textList.setTextFormat(errorFormat, yy, textList.text.length);					
				} else {
					textList.setTextFormat(warningFormat, yy, textList.text.length);
				}
				
			}
		}
		
		public function Update(event:Event):void {
			
		}
		
	}
	
}