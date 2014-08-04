package Game
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	public class IngameInfoMessage extends Sprite
	{
		public function IngameInfoMessage(text:String)
		{
			super();
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 24;
			tf.bold = true;
			tf.color = -1;
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = text;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			addChild(label);
			
			var outline:GlowFilter = new GlowFilter(0x000000,1.0,2.0,2.0,10);
			outline.quality=BitmapFilterQuality.MEDIUM;
			label.filters = [outline];
			
			y = 50;
			
			var timer:Timer = new Timer(5000, 1);
			timer.addEventListener(TimerEvent.TIMER, remove);
			timer.start();
		}
		
		private function remove(event:TimerEvent):void {
			if(parent)
				Game(parent).removeInfoPanel(this);
		}
	}
}