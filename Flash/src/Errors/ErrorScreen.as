package Errors
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.PlayerIOError;
	
	public class ErrorScreen extends Sprite
	{
		public var errorID:int;
		public var callback:Function;
		
		public function ErrorScreen(error:ErrorObject)
		{
			this.callback = error.callback;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;

			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = error.text;
			label.width = 230;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 45;
			
			var dialogSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 250, label.height + 100);
			dialogSprite.x = width / 2 - dialogSprite.width / 2;
			dialogSprite.y = height / 2 - dialogSprite.height / 2;
			addChild(dialogSprite);
			
			dialogSprite.addChild(label);

			tf.size = 18;

			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = error.title;
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			var self:Sprite = this;
			
			var okButton:ButtonHex = new ButtonHex("OK", onOk, "button_small_gold", 14, -1, 80);
			okButton.y = dialogSprite.height - 50;
			okButton.x = dialogSprite.width / 2 - okButton.width / 2;
			dialogSprite.addChild(okButton);
			
			errorID = error.ID;
		}
		
		private function onOk():void {
			ErrorManager.dismissError();
			if(callback != null)
				callback();
		}
	}
}