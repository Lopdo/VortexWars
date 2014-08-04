package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ConfirmationDialog extends Sprite
	{
		public var dialogSprite:NinePatchSprite;
		
		public function ConfirmationDialog(text:String, okLabel:String, okCallback:Function, cancelLabel:String = null, cancelCallback:Function = null)
		{
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;

			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = text;
			label.width = 230;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 50;
			label.mouseEnabled = false;
			
			dialogSprite = new NinePatchSprite("9patch_popup", 250, label.height + 100);
			dialogSprite.x = width / 2 - dialogSprite.width / 2;
			dialogSprite.y = height / 2 - dialogSprite.height / 2;
			addChild(dialogSprite);
			
			dialogSprite.addChild(label);
			
			var self:Sprite = this;
			
			var okButton:ButtonHex = new ButtonHex(okLabel, function():void { parent.removeChild(self); okCallback(); }, "button_small_gold");
			okButton.y = dialogSprite.height - 40;
			okButton.x = dialogSprite.width / 2 - okButton.width / 2;
			dialogSprite.addChild(okButton);
			
			if(cancelLabel) {
				var cancelButton:ButtonHex = new ButtonHex(cancelLabel, function():void { parent.removeChild(self); if(cancelCallback != null) cancelCallback(); }, "button_small_gray");
				var space:int = (250 - okButton.width - cancelButton.width) / 3;
				okButton.x = space;
				cancelButton.x = okButton.width + 2*space;
				cancelButton.y = dialogSprite.height - 40;
				dialogSprite.addChild(cancelButton);
			}
			
			G.sounds.playSound("error_dialog");
		}
	}
}