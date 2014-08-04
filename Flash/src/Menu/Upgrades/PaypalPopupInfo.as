package Menu.Upgrades
{
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class PaypalPopupInfo extends Sprite
	{
		public function PaypalPopupInfo(url:String, okCallback:Function)
		{
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Paypal window should have opened in your browser. If you are having troubles opening that popup window, copy following link, open new tab and paste it into address bar:";
			label.width = 380;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 50;
			label.mouseEnabled = false;
		
			tf.bold = false;
			tf.underline = true;
			tf.color = 0x3DB7FF;
			
			var label2:TextField = new TextField();
			label2.defaultTextFormat = tf;
			label2.text = url;
			label2.width = 380;
			label2.x = 10;
			label2.multiline = true;
			label2.wordWrap = true;
			label2.autoSize = TextFieldAutoSize.CENTER;
			label2.y = 150;

			
			var dialogSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 400, label.height + label2.height + 150);
			dialogSprite.x = width / 2 - dialogSprite.width / 2;
			dialogSprite.y = height / 2 - dialogSprite.height / 2;
			addChild(dialogSprite);
			
			dialogSprite.addChild(label);
			dialogSprite.addChild(label2);
			
			var self:Sprite = this;
			
			var okButton:ButtonHex = new ButtonHex("OK", function():void { parent.removeChild(self); okCallback(); }, "button_small_gold");
			okButton.y = dialogSprite.height - 40;
			okButton.x = dialogSprite.width / 2 - okButton.width / 2;
			dialogSprite.addChild(okButton);
		}
	}
}