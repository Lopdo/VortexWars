package Menu.PlayerProfile
{
	import IreUtils.ResList;
	
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class LevelUpScreen extends Sprite
	{
		public function LevelUpScreen()
		{
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
			label.text = "LEVEL UP";
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			tf.size = 14;
			
			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Congratulations! You just gained level and " + G.user.level * 10 + " vortex shards as a reward";
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 58;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			tf.size = 26;
			tf.color = 0x3DB7FF;
			
			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "+" + G.user.level * 10;
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 120;
			label.x -= 10;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			var shard:Sprite = new Sprite;
			shard.addChild(ResList.GetArtResource("shop_shard"));
			shard.x = label.x + label.width;
			shard.y = label.y + label.height / 2 - shard.height / 2;
			dialogSprite.addChild(shard);
			
			var self:Sprite = this;
			
			var okButton:ButtonHex = new ButtonHex("OK", function():void { parent.removeChild(self); }, "button_small_gold", 14, -1, 90);
			okButton.y = 156;
			okButton.x = dialogSprite.width / 2 - okButton.width / 2;
			dialogSprite.addChild(okButton);
			
			/*if(G.host == G.HOST_FACEBOOK) {
				var shareButton:ButtonHex = new ButtonHex("SHARE", onSharePressed, "button_small_blue", 14, -1, 90);
				shareButton.y = 156;
				shareButton.x = 0.5 * (280 / 3.5);
				dialogSprite.addChild(shareButton);
				
				okButton.x = 2 * (280 / 3.5);
			}*/
		}
		
		/*private function onSharePressed():void {
			var title:String = "Level up!";
			var text:String = "I just reached level " + G.user.level + ". One step closer to the top";
			
			
			Facebook.ui({
				method: "feed",
				name: title,
				picture: "lost-bytes.com/vortexwars/images/logo_93x74.png",
				description: text
			}, function(response:Object):void {

			});
		} */
	}
}