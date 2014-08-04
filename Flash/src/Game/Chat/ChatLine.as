package Game.Chat
{
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class ChatLine extends Sprite
	{
		private static var messageNameTextFormat:TextFormat = null;
		private static var messageTextTextFormat:TextFormat = null;
		
		private var timer:Number;
		public var fading:Boolean;
		private var historyMode:Boolean;
		
		public function ChatLine(name:String, colorID:int, text:String, isModerator:Boolean)
		{
			if(messageNameTextFormat == null) {
				messageNameTextFormat = new TextFormat();
				messageNameTextFormat.bold = true;
				messageNameTextFormat.size = 14;
				messageNameTextFormat.font = "Arial";
				
				messageTextTextFormat = new TextFormat();
				messageTextTextFormat.bold = true;
				messageTextTextFormat.size = 14;
				messageTextTextFormat.font = "Arial";
				messageTextTextFormat.color = -1;
			}
			
			if(isModerator) {
				messageNameTextFormat.color = 0xc2e4f9;
			}
			else {
				if(colorID != -1)
					messageNameTextFormat.color = G.colors[colorID];
				else 
					messageNameTextFormat.color = 0xA0A0A0;
			}
			
			x = 5;
			
			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.width = 280;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.text = name + (text.length > 0 ? (": " + text) : "");
			textField.setTextFormat(messageNameTextFormat, 0, name.length);
			if(text.length > 0)
				textField.setTextFormat(messageTextTextFormat, name.length, textField.text.length);
			textField.mouseEnabled = false;
			addChild(textField);
			
			var outline:GlowFilter = new GlowFilter(0x000000,1.0,2.0,2.0,10);
			outline.quality=BitmapFilterQuality.MEDIUM;
			textField.filters = [outline];
			
			timer = 0;
			fading = true;
		}
		
		public function update(timeDelta:Number):void {
			if(fading) {
				timer += timeDelta;
				if(timer > 8 && !historyMode) {
					alpha = 1 - (timer - 8) / 3;
					if(alpha < 0) {
						alpha = 0;
						fading = false;
					}
				}
			}
		}
		
		public function setHistoryMode(history:Boolean):void {
			historyMode = history;
			
			if(!historyMode) {
				if(timer > 10) {
					alpha = 1 - (timer - 10) / 3;
					if(alpha < 0) {
						alpha = 0;
						fading = false;
					}
				}
			}
		}
	}
}