package Menu
{
	import IreUtils.ResList;
	
	import Menu.Upgrades.ShopScreen;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class SaleScreen extends Sprite
	{
		public function SaleScreen()
		{
			super();
			
			graphics.beginFill(0, 0.6);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 400, 380);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "SALE!";
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			//bg.addChild(label);
			
			tf.size = 22;
			tf.color = 0xFF9400;
			
			label = new TextField();
			label.text = "HALLOWEEN SALE!";
			label.setTextFormat(tf);
			label.width = bg.width;
			label.y = 50;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 16;
			tf.color = -1;
			
			label = new TextField();
			label.text = "We can't give you candy but we can\noffer you something else.";
			label.setTextFormat(tf);
			label.width = bg.width;
			label.y = 90;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.color = 0x3DB7FF;
			tf.size = 26;
			
			label = new TextField();
			label.text = "50% off";
			label.setTextFormat(tf);
			label.width = bg.width;
			label.y = 154;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.color = -1;
			tf.size = 16;
			
			label = new TextField();
			label.text = "all coin prices for all items in shop!\nAvailable only until end of Halloween.\n\nGet them while they last!";
			label.setTextFormat(tf);
			label.width = bg.width;
			label.y = 190;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			var self:Sprite = this;
			var button:ButtonHex = new ButtonHex("CLOSE", function():void { parent.removeChild(self); }, "button_small_gray");
			button.x = bg.width / 2 - button.width / 2;
			button.y = bg.height - 44;
			bg.addChild(button);
			
			button = new ButtonHex("VISIT SHOP", onVisitShop, "button_medium_gold", 20);
			button.x = bg.width / 2 - button.width / 2;
			button.y = bg.height - 104;
			bg.addChild(button);
		}
		
		private function onVisitShop():void {
			parent.removeChild(this);
			G.gameSprite.removeChildAt(0);
			G.gameSprite.addChild(new ShopScreen());
			//parent.parent.removeChild(parent);
		}
	}
}