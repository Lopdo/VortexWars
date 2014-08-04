package Tutorial
{
	import Menu.ButtonHex;
	import Menu.Lobby.Lobby;
	import Menu.MainMenu.MainMenu;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class WelcomeScreen extends Sprite
	{
		public function WelcomeScreen(mainMenu:Lobby)
		{
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var dialogSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 250, 180);
			dialogSprite.x = width / 2 - dialogSprite.width / 2;
			dialogSprite.y = height / 2 - dialogSprite.height / 2;
			addChild(dialogSprite);
			
			var tf:TextFormat = new TextFormat("Arial", 16, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "WELCOME!";
			label.width = dialogSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			dialogSprite.addChild(label);
			
			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Looks like you are here for the first time. Would you like to play tutorial level first?";
			label.width = 230;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 50;
			label.mouseEnabled = false;
			
			dialogSprite.addChild(label);
			
			var self:Sprite = this;
			
			var okButton:ButtonHex = new ButtonHex("YES", function():void { mainMenu.startTutorial(); parent.removeChild(self);}, "button_small_gold");
			okButton.y = dialogSprite.height - 48;
			okButton.x = dialogSprite.width / 2 - okButton.width / 2;
			dialogSprite.addChild(okButton);
			
			var cancelButton:ButtonHex = new ButtonHex("SKIP", function():void { parent.removeChild(self); }, "button_small_gray");
			var space:int = (250 - okButton.width - cancelButton.width) / 3;
			okButton.x = space;
			cancelButton.x = okButton.width + 2*space;
			cancelButton.y = dialogSprite.height - 48;
			dialogSprite.addChild(cancelButton);
		}
	}
}