package
{
	import IreUtils.ResList;
	
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class AchievementWindow extends Sprite
	{
		public function AchievementWindow(Id:int, name:String, xpReward:int, shardReward:int)
		{
			super();
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 320, 136);
			addChild(bg);
			
			x = 400 - width / 2;
			y = -50;
			
			var achievLvl:int = Id % 100;
			var achievIndex:int = Id / 100;
			
			var achievSprite:Sprite = new Sprite();
			achievSprite.addChild(ResList.GetArtResource("achiev_lvl" + achievLvl));
			achievSprite.addChild(ResList.GetArtResource("achiev_icon" + achievIndex));
			achievSprite.x = 10;
			achievSprite.y = 60;
			achievSprite.height = 60;
			achievSprite.width = 80;
			bg.addChild(achievSprite);
			
			var tf:TextFormat = new TextFormat("Arial", 14, 0xAAAAAA, true);
			
			var label:TextField = new TextField();
			label.text = "Achievement unlocked";
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.x = 80 + (width - 80) / 2 - label.width / 2;
			label.y = 58;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.color = -1;
			tf.size = 18;
			
			label = new TextField();
			label.text = name;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.x = 80 + (width - 80) / 2 - label.width / 2;
			label.y = 80;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 16;
			tf.color = 0x00ff00;
			
			var xpLabel:TextField = new TextField();
			xpLabel.text = "+ " + xpReward + " xp";
			xpLabel.setTextFormat(tf);
			xpLabel.autoSize = TextFieldAutoSize.CENTER;
			//xpLabel.x = 80 + (width - 80) / 4 - xpLabel.width / 2;
			xpLabel.y = 108;
			xpLabel.mouseEnabled = false;
			bg.addChild(xpLabel);
			
			tf.color = 0x3DB7FF;
			
			var shardLabel:TextField = new TextField();
			shardLabel.text = "+ " + shardReward;
			shardLabel.setTextFormat(tf);
			shardLabel.autoSize = TextFieldAutoSize.CENTER;
			//shardLabel.x = 80 + 3 * (width - 80) / 4 - label.width / 2;
			shardLabel.y = 108;
			shardLabel.mouseEnabled = false;
			bg.addChild(shardLabel);
			
			var icon:Sprite = new Sprite();
			icon.addChild(ResList.GetArtResource("shop_shard"));
			icon.x = label.width + label.x + 2;
			icon.y = shardLabel.y + shardLabel.height / 2 - icon.height / 2 - 2;
			bg.addChild(icon);

			xpLabel.x = 80 + (width - 80) / 2  - (xpLabel.width + shardLabel.width + icon.width + 12) / 2;
			shardLabel.x = xpLabel.x + xpLabel.width + 10;
			icon.x = shardLabel.width + shardLabel.x + 2;
			
			G.errorSprite.addChild(this);
			
			var timer:Timer = new Timer(6000, 1);
			timer.addEventListener(TimerEvent.TIMER, hide, false, 0, true);
			timer.start();
		}
		
		private function hide(event:TimerEvent):void {
			parent.removeChild(this);
		}
	}
}