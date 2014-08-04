package Menu.Login
{
	import Errors.ErrorManager;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.MutePanel;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import playerio.Client;
	import playerio.DatabaseObject;
	import playerio.PlayerIO;
	import playerio.PlayerIORegistrationError;
	
	public class RegisterScreen extends Sprite
	{
		
		private var nameField:TextField;
		private var passwordField:TextField;
		private var passwordField2:TextField;
		private var emailField:TextField;
		
		private var loading:Loading;
		
		public function RegisterScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var b:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 304, 420);
			b.x = width / 2 - b.width / 2;
			b.y = height / 2 - b.height / 2;
			addChild(b);
			
			var tf:TextFormat = new TextFormat("Arial", 20, -1, true);
			
			var title:TextField = new TextField();
			title.width = b.width;
			title.text = "REGISTER";
			title.setTextFormat(tf);
			title.autoSize = TextFieldAutoSize.CENTER;
			title.y = 20;
			title.mouseEnabled = false;
			b.addChild(title);
			
			tf.bold = false;
			tf.size = 10;
			
			var limit:TextField = new TextField();
			limit.text = "15 CHARS MAX";
			limit.setTextFormat(tf);
			limit.autoSize = TextFieldAutoSize.RIGHT;
			limit.x = 266 - limit.width;
			limit.y = 62;
			limit.mouseEnabled = false;
			b.addChild(limit);
			
			tf.size = 14;
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			
			var label:TextField = new TextField();
			label.text = "USERNAME:";
			label.setTextFormat(tf);
			label.x = 20;
			label.y = 59;
			label.mouseEnabled = false;
			b.addChild(label);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = b.width / 2 - editbox.width / 2;
			editbox.y = 79;
			b.addChild(editbox);
			
			nameField = new TextField();
			nameField.type = TextFieldType.INPUT;
			nameField.defaultTextFormat = editTF;
			nameField.maxChars = 15;
			nameField.autoSize = TextFieldAutoSize.LEFT;
			nameField.y = editbox.height / 2 - nameField.height / 2;
			nameField.autoSize = TextFieldAutoSize.NONE;
			nameField.x = 10;
			nameField.width = editbox.width - 10;
			editbox.addChild(nameField);
			
			label = new TextField();
			label.x = 20;
			label.y = 124;
			label.text = "PASSWORD:";
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			b.addChild(label);
			
			editbox = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = b.width / 2 - editbox.width / 2;
			editbox.y = 142;
			b.addChild(editbox);
			
			passwordField = new TextField();
			passwordField.type = TextFieldType.INPUT;
			passwordField.defaultTextFormat = editTF;
			passwordField.autoSize = TextFieldAutoSize.LEFT;
			passwordField.y = editbox.height / 2 - passwordField.height / 2;
			passwordField.autoSize = TextFieldAutoSize.NONE;
			passwordField.x = 10;
			passwordField.width = editbox.width - 20;
			passwordField.displayAsPassword = true;
			editbox.addChild(passwordField);
			
			label = new TextField();
			label.x = 20;
			label.y = 192;
			label.text = "REPEAT PASSWORD:";
			label.setTextFormat(tf);
			label.width = 200;
			label.mouseEnabled = false;
			b.addChild(label);
			
			editbox = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = b.width / 2 - editbox.width / 2;
			editbox.y = 212;
			b.addChild(editbox);
			
			passwordField2 = new TextField();
			passwordField2.type = TextFieldType.INPUT;
			passwordField2.defaultTextFormat = editTF;
			passwordField2.autoSize = TextFieldAutoSize.LEFT;
			passwordField2.y = editbox.height / 2 - passwordField2.height / 2;
			passwordField2.autoSize = TextFieldAutoSize.NONE;
			passwordField2.x = 10;
			passwordField2.width = editbox.width - 20;
			passwordField2.displayAsPassword = true;
			editbox.addChild(passwordField2);
			
			label = new TextField();
			label.x = 20;
			label.y = 260;
			label.text = "EMAIL:";
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			b.addChild(label);
			
			editbox = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = b.width / 2 - editbox.width / 2;
			editbox.y = 279;
			b.addChild(editbox);
			
			emailField = new TextField();
			emailField.type = TextFieldType.INPUT;
			emailField.defaultTextFormat = editTF;
			emailField.autoSize = TextFieldAutoSize.LEFT;
			emailField.y = editbox.height / 2 - emailField.height / 2;
			emailField.autoSize = TextFieldAutoSize.NONE;
			emailField.x = 10;
			emailField.width = editbox.width - 20;
			emailField.addEventListener(KeyboardEvent.KEY_UP, OnEnterPressed, false, 0, true);
			editbox.addChild(emailField);
			
			var button:ButtonHex = new ButtonHex("REGISTER", Register, "button_medium_gold", 22, -1, 220);
			button.x = b.width / 2 - button.width / 2;
			button.y = 334;
			b.addChild(button);
			
			button = new ButtonHex("BACK", Back, "button_small_gray");
			button.x = b.x - 3;
			button.y = 516;
			addChild(button);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			
			var mute:MutePanel = new MutePanel(false);
			mute.x = 592;
			mute.y = 538;
			addChild(mute);
			
			G.gatracker.trackPageview("/register");
		}
		
		public function addedToStage(event:Event):void {
			stage.focus = nameField;
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function Back():void {
			parent.addChild(G.getLoginScreen());
			parent.removeChild(this);
		}
		
		private function OnEnterPressed(event:KeyboardEvent):void {
			if(event.charCode == Input.KEY_ENTER)
				Register();
		}
		
		private function Register():void {
			if(loading) return;
			
			loading = new Loading();
			addChild(loading);
			
			//var aff:String = LoaderInfo(stage.root.loaderInfo).parameters.pio$affiliate || null;
			var aff:String = (G.loaderParams != null ? (G.loaderParams.pio$affiliate || null) : null);
			PlayerIO.quickConnect.simpleRegister(stage, G.gameID, nameField.text, passwordField.text, emailField.text, "", "", null, aff, handleRegister, handleError);
			
			G.gatracker.trackPageview("/register/start");
		}
		
		private function handleRegister(client:Client):void{
			trace("Sucessfully connected to player.io");
			
			removeChild(loading);
			loading = null;
			
			G.user.name = nameField.text;
			G.user.isGuest = false;
			
			G.client = client;
			//Set developmentsever (Comment out to connect to your server online)
			if(G.localServer)
				G.client.multiplayer.developmentServer = "localhost:8184";
			
			var login:LoginScreen = new LoginScreen();
			login.loginWith(nameField.text, passwordField.text);
			parent.addChild(login);
			parent.removeChild(this);
			
			G.gatracker.trackPageview("/register/success");
		}
		
		private function handleError(error:PlayerIORegistrationError):void{
			removeChild(loading);
			loading = null;
			
			if(error.usernameError != null)
				ErrorManager.showCustomError(error.usernameError, ErrorManager.ERROR_REGISTER);
			else if(error.emailError != null) 
				ErrorManager.showCustomError(error.emailError, ErrorManager.ERROR_REGISTER);
			else if(error.passwordError != null)
				ErrorManager.showCustomError(error.passwordError, ErrorManager.ERROR_REGISTER);
			
			G.gatracker.trackPageview("/register/error");
			
			trace("got",error)
		}
	}
}