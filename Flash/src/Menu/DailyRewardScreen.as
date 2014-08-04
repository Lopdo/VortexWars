package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class DailyRewardScreen extends Sprite
	{
		public function DailyRewardScreen(consecutiveDays:int, reward:int) {
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var dialogSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 280, 200);
			dialogSprite.x = width / 2 - dialogSprite.width / 2;
			dialogSprite.y = height / 2 - dialogSprite.height / 2;
			addChild(dialogSprite);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Daily reward";
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			tf.size = 14;
			
			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "You received " + reward + " vortex shards";
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 58;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Come back tomorrow for more!";
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 126;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);

			tf.size = 26;
			tf.color = 0x3DB7FF;
			
			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "+" + reward;
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 88;
			label.x -= 10;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			var shard:Sprite = new Sprite;
			shard.addChild(ResList.GetArtResource("shop_shard"));
			shard.x = label.x + label.width;
			shard.y = label.y + label.height / 2 - shard.height / 2;
			dialogSprite.addChild(shard);
			
			var okButton:ButtonHex = new ButtonHex("OK", onOk, "button_small_gold", 14, -1, 80);
			okButton.y = 156;
			okButton.x = dialogSprite.width / 2 - okButton.width / 2;
			dialogSprite.addChild(okButton);
		}
		
		private function onOk():void {
			this.parent.removeChild(this);
		}
	}
}