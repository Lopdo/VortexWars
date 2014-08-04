package Menu.Login
{
	import Errors.ErrorManager;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.ConfirmationDialog;
	import Menu.Loading;
	import Menu.MutePanel;
	import Menu.NinePatchSprite;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.ErrorLog;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	public class PasswordRecoveryScreen extends Sprite
	{
		private var emailField:TextField;
		private var loading:Loading;
		
		public function PasswordRecoveryScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 372, 232);
			bg.x = width / 2 - bg.width / 2;
			bg.y = width / 2 - bg.width / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "ENTER EMAIL ADRESS ASSOCIATED WITH YOUR ACCOUNT. WE WILL SEND YOU PASSWORD RECOVERY EMAIL";
			label.setTextFormat(tf);
			label.multiline = true;
			label.wordWrap = true;
			label.x = 20;
			label.width = bg.width - 40;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 30;
			bg.addChild(label);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = bg.width / 2 - editbox.width / 2;
			editbox.y = 100;
			bg.addChild(editbox);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			editTF.align = TextFormatAlign.LEFT;
			
			emailField = new TextField();
			emailField.type = TextFieldType.INPUT;
			emailField.defaultTextFormat = editTF;
			emailField.x = 10;
			emailField.width = editbox.width - 20;
			emailField.autoSize = TextFieldAutoSize.LEFT;
			emailField.y = editbox.height / 2 - emailField.height / 2;
			emailField.autoSize = TextFieldAutoSize.NONE;
			emailField.width = editbox.width - 20;
			emailField.addEventListener(KeyboardEvent.KEY_UP, OnEnterPressed, false, 0, true);
			editbox.addChild(emailField);
			
			var button:ButtonHex = new ButtonHex("BACK", onBack, "button_small_gray");
			button.x = editbox.x;
			button.y = 160;
			bg.addChild(button);
			
			button = new ButtonHex("SEND", onSend, "button_small_gold");
			button.x = editbox.x + editbox.width - button.width;
			button.y = 160;
			bg.addChild(button);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			
			var mute:MutePanel = new MutePanel(false);
			mute.x = width / 2 - mute.width / 2;
			mute.y = bg.y + bg.height + 20;
			addChild(mute);
			
			G.gatracker.trackPageview("/login/passwordRecovery");
		}
		
		private function OnEnterPressed(event:KeyboardEvent):void {
			if(event.charCode == Input.KEY_ENTER)
				onSend();
		}
		
		public function addedToStage(event:Event):void {
			stage.focus = emailField;
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function onBack():void {
			parent.addChild(new LoginScreen());
			parent.removeChild(this);
		}
		
		private function onSend():void {
			if(emailField.text.length == 0) {
				ErrorManager.showCustomError("Email needs to be set!", ErrorManager.ERROR_EMAIL_NOT_SET);
			}
			else {
				PlayerIO.quickConnect.simpleRecoverPassword(G.gameID, emailField.text, onRecovered, onError);
				
				loading = new Loading();
				addChild(loading);
				
				G.gatracker.trackPageview("/login/passwordRecovery/sent");
			}
		}
		
		private function onRecovered():void {
			removeChild(loading);
			loading = null;
			
			addChild(new ConfirmationDialog("EMAIL HAS BEEN SENT TO PROVIDED EMAIL ADDRESS", "OK", onBack));
			
			G.gatracker.trackPageview("/login/passwordRecovery/recovered");
		}
		
		private function onError(error:PlayerIOError):void {
			removeChild(loading);
			loading = null;
			
			ErrorManager.showPIOError(error);
			
			G.gatracker.trackPageview("/login/passwordRecovery/error");
		}
	}
}