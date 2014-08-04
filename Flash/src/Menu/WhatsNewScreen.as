package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class WhatsNewScreen extends Sprite
	{
		public function WhatsNewScreen()
		{
			super();
			
			graphics.beginFill(0, 0.6);
			graphics.drawRect(0, 0, 800, 600);
			
			var changes:Array = new Array(	"Guests can't change name of the game",
											"Added Christmas race to the shop",
											"Added Halloween race to the shop");
			var lineCount:int = 3;
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 420, 140 + lineCount*40);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "WHAT'S NEW?";
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 22;
			
			label = new TextField();
			label.text = "version " + G.gameVersion;
			label.setTextFormat(tf);
			label.width = bg.width;
			label.y = 50;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 18;
			
			var offsetY:int = 92;
			for(var i:int = 0; i < changes.length; ++i) {
				label = new TextField();
				label.text = "- " + changes[i];
				label.setTextFormat(tf);
				label.width = bg.width - 50;
				label.x = 30;
				label.y = offsetY;
				label.multiline = true;
				label.wordWrap = true;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				bg.addChild(label);
				
				offsetY += label.height + 5;
			}
			
			var self:Sprite = this;
			var button:ButtonHex = new ButtonHex("OK", function():void { parent.removeChild(self); }, "button_small_gray");
			button.x = bg.width / 2 - button.width / 2;
			button.y = bg.height - 44;
			bg.addChild(button);
		}
	}
}