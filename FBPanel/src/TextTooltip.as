package 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class TextTooltip extends BaseTooltip
	{
		private var ownerSprite:DisplayObject;
		private var timer:Timer;
		private var lastX:int, lastY:int;
		
		public function TextTooltip(text:String, owner:DisplayObject)
		{
			super(owner);

			var tf:TextFormat = new TextFormat("Arial", 12, 0, true);
			
			var label:TextField = new TextField();
			label.text = text;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.x = 2;
			label.y = 0;
			
			graphics.beginFill(0xFFEBB2);
			graphics.drawRect(0, 0, label.width + 4, label.height);
			
			addChild(label);
		}
	}
}