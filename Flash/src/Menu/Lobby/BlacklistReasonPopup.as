package Menu.Lobby
{
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class BlacklistReasonPopup extends Sprite
	{
		private var successCallback:Function;
		private var reasonField:TextField;
		
		public function BlacklistReasonPopup(callback:Function)
		{
			super();
			
			successCallback = callback;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Please enter the reason why you are adding this player to your personal banlist";
			label.width = 230;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 50;
			
			var dialogSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 250, 200);
			dialogSprite.x = width / 2 - dialogSprite.width / 2;
			dialogSprite.y = height / 2 - dialogSprite.height / 2;
			addChild(dialogSprite);
			
			dialogSprite.addChild(label);
			
			tf.size = 18;
			
			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Add to banlist";
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 200, 26);
			editbox.x = dialogSprite.width / 2 - editbox.width / 2;
			editbox.y = 116;
			dialogSprite.addChild(editbox);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			editTF.align = TextFormatAlign.LEFT;
			
			reasonField = new TextField();
			reasonField.type = TextFieldType.INPUT;
			reasonField.defaultTextFormat = editTF;
			reasonField.x = 10;
			reasonField.width = editbox.width - 20;
			reasonField.autoSize = TextFieldAutoSize.LEFT;
			reasonField.y = editbox.height / 2 - reasonField.height / 2;
			reasonField.autoSize = TextFieldAutoSize.NONE;
			reasonField.width = editbox.width - 20;
			reasonField.maxChars = 100;
			editbox.addChild(reasonField);
			
			var okButton:ButtonHex = new ButtonHex("BAN", onOk, "button_small_gold", 14, -1, 80);
			okButton.y = dialogSprite.height - 50;
			okButton.x = 30;
			dialogSprite.addChild(okButton);
			
			var cancelButton:ButtonHex = new ButtonHex("CANCEL", onCancel, "button_small_gray", 14, -1, 100);
			cancelButton.y = dialogSprite.height - 50;
			cancelButton.x = 120;
			dialogSprite.addChild(cancelButton);
		}
		
		private function onOk():void {
			if(successCallback != null)
				successCallback(reasonField.text);
			
			parent.removeChild(this);
		}
		
		private function onCancel():void {
			parent.removeChild(this);
		}
	}
}