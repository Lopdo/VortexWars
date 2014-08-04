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
	
	public class NewTurnPanel extends Sprite
	{
		public function NewTurnPanel(player:Player)
		{
			super();
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 24;
			tf.bold = true;
			if(player == null) {
				tf.color = G.nameColors[G.user.colorID];
			}
			else {
				tf.color = G.nameColors[player.colorID];
			}
			//tf.color = -1;
			tf.align = TextFormatAlign.CENTER;
			
			var text:TextField = new TextField();
			text.defaultTextFormat = tf;
			if(player == null) {
				text.text = "Your turn!";
			}
			else {
				text.text = player.name + "'s turn";
			}
			text.autoSize = TextFieldAutoSize.LEFT;
			text.mouseEnabled = false;
			addChild(text);
			
			var outline:GlowFilter = new GlowFilter(0x000000,1.0,2.0,2.0,10);
			outline.quality=BitmapFilterQuality.MEDIUM;
			text.filters = [outline];
			
			y = 20;				

			var timer:Timer = new Timer(2500, 1);
			timer.addEventListener(TimerEvent.TIMER, remove);
			timer.start();
		}
		
		private function remove(event:TimerEvent):void {
			if(parent)
				Game(parent).removeNewTurnPanel(this);
		}
	}
}