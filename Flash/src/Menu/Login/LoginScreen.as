package Menu.Login
{
	import Errors.ErrorManager;
	
	import Game.Races.Race;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.Lobby.Lobby;
	import Menu.MainMenu.MainMenu;
	import Menu.MutePanel;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.DatabaseObject;
	import playerio.ErrorLog;
	import playerio.Message;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	public class LoginScreen extends Sprite
	{
		private var nameField:TextField;
		private var passwordField:TextField;
		
		private var guestNameField:TextField;
		
		private var rememberButton:Sprite;
		private var rememberMe:Boolean;
		
		private var loading:Loading = null;
	
		private var usernameInitialized:Boolean = false;
		private var payvaultInitialized:Boolean = false;
		
		public function LoginScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			/*var vsPanel:Sprite = new Sprite();
			vsPanel.addChild(ResList.GetArtResource("login_or"));
			vsPanel.x = width / 2 - vsPanel.width / 2;
			vsPanel.y = 176;
			addChild(vsPanel);*/
			
			var leftPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 304, 420);
			leftPanel.x = 50;
			leftPanel.y = 20;
			addChild(leftPanel);
			
			var rightPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 304, 420);
			rightPanel.x = 445;
			rightPanel.y = 20;
			addChild(rightPanel);
			
			var bottomPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 364, 122);
			bottomPanel.x = width / 2 - bottomPanel.width / 2;
			bottomPanel.y = 454;
			addChild(bottomPanel);
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var registerLabel:TextField = new TextField();
			registerLabel.text = "REGISTER FOR FREE TO GET XP, TRACK YOUR STATS AND MUCH MORE";
			registerLabel.setTextFormat(tf);
			registerLabel.x = 20;
			registerLabel.width = bottomPanel.width - 40;
			registerLabel.multiline = true;
			registerLabel.wordWrap = true;
			registerLabel.autoSize = TextFieldAutoSize.CENTER;
			registerLabel.y = 10;
			registerLabel.mouseEnabled = false;
			bottomPanel.addChild(registerLabel);
			
			var button:ButtonHex = new ButtonHex("CREATE FREE ACCOUNT", Register, "button_medium_gray", 22);
			button.x = bottomPanel.width / 2 - button.width / 2;
			button.y = 48;
			bottomPanel.addChild(button);

			tf.size = 20;
			
			var guestLabel:TextField = new TextField();
			guestLabel.text = "PLAY AS GUEST";
			guestLabel.x = 0;
			guestLabel.width = leftPanel.width;
			guestLabel.setTextFormat(tf);
			guestLabel.autoSize = TextFieldAutoSize.CENTER;
			guestLabel.y = 20;
			guestLabel.mouseEnabled = false;
			leftPanel.addChild(guestLabel);
			
			var loginLabel:TextField = new TextField();
			loginLabel.text = "LOGIN";
			loginLabel.x = 0;
			loginLabel.width = rightPanel.width;
			loginLabel.setTextFormat(tf);
			loginLabel.autoSize = TextFieldAutoSize.CENTER;
			loginLabel.y = 20;
			loginLabel.mouseEnabled = false;
			rightPanel.addChild(loginLabel);
			
			tf.size = 16;
			tf.color = 0xDDDDDD;
			
			var guestText:TextField = new TextField();
			guestText.text = "AS GUEST, YOU WILL MISS OUT ON THESE AWESOME FEATURES:";
			guestText.x = 15;
			guestText.width = leftPanel.width - 30;
			guestText.multiline = true;
			guestText.wordWrap = true;
			guestText.setTextFormat(tf);
			guestText.autoSize = TextFieldAutoSize.CENTER;
			guestText.y = 60;
			guestText.mouseEnabled = false;
			leftPanel.addChild(guestText);
			
			tf.size = 14;
			
			var featuresPanel:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 252, 136);
			featuresPanel.x = leftPanel.width / 2 - featuresPanel.width / 2;
			featuresPanel.y = 118;
			leftPanel.addChild(featuresPanel);
			
			guestText = new TextField();
			guestText.text = "- GAINING XP";
			guestText.setTextFormat(tf);
			guestText.x = 30;
			guestText.y = 126;
			guestText.autoSize = TextFieldAutoSize.LEFT
			guestText.mouseEnabled = false;
			leftPanel.addChild(guestText);
			
			guestText = new TextField();
			guestText.text = "- LEVELING UP";
			guestText.setTextFormat(tf);
			guestText.x = 30;
			guestText.y = 151;
			guestText.mouseEnabled = false;
			guestText.autoSize = TextFieldAutoSize.LEFT
			leftPanel.addChild(guestText);
			
			guestText = new TextField();
			guestText.text = "- TRACKING YOUR STATS";
			guestText.setTextFormat(tf);
			guestText.x = 30;
			guestText.y = 176;
			guestText.autoSize = TextFieldAutoSize.LEFT
			guestText.mouseEnabled = false;
			leftPanel.addChild(guestText);
			
			guestText = new TextField();
			guestText.text = "- UNLOCKING NEW RACES";
			guestText.setTextFormat(tf);
			guestText.x = 30;
			guestText.y = 201;
			guestText.mouseEnabled = false;
			guestText.autoSize = TextFieldAutoSize.LEFT
			leftPanel.addChild(guestText);
			
			guestText = new TextField();
			guestText.text = "   AND MUCH MORE...";
			guestText.setTextFormat(tf);
			guestText.x = 30;
			guestText.y = 226;
			guestText.mouseEnabled = false;
			guestText.autoSize = TextFieldAutoSize.LEFT
			leftPanel.addChild(guestText);
			
			tf.color = -1;
			tf.bold = false;
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = leftPanel.width / 2 - editbox.width / 2;
			editbox.y = 285;
			leftPanel.addChild(editbox);
			
			var guestNameLabel:TextField = new TextField();
			guestNameLabel.text = "NAME:";
			guestNameLabel.setTextFormat(tf);
			guestNameLabel.x = 20;
			guestNameLabel.y = 265;
			guestNameLabel.mouseEnabled = false;
			guestNameLabel.autoSize = TextFieldAutoSize.LEFT;
			leftPanel.addChild(guestNameLabel);
			
			tf.size = 10;

			guestNameLabel = new TextField();
			guestNameLabel.text = "MAX 10 CHARS";
			guestNameLabel.setTextFormat(tf);
			guestNameLabel.y = 265;
			guestNameLabel.mouseEnabled = false;
			guestNameLabel.autoSize = TextFieldAutoSize.RIGHT;
			guestNameLabel.x = leftPanel.width - 25 - guestNameLabel.width;
			leftPanel.addChild(guestNameLabel);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			editTF.align = TextFormatAlign.LEFT;
			
			guestNameField = new TextField();
			guestNameField.type = TextFieldType.INPUT;
			guestNameField.defaultTextFormat = editTF;
			guestNameField.x = 10;
			guestNameField.width = editbox.width - 20;
			guestNameField.autoSize = TextFieldAutoSize.LEFT;
			guestNameField.y = editbox.height / 2 - guestNameField.height / 2;
			guestNameField.autoSize = TextFieldAutoSize.NONE;
			guestNameField.width = editbox.width - 20;
			guestNameField.maxChars = 10;
			guestNameField.text = "Guest" + (int)(Math.random() * 10000);
			guestNameField.restrict = "a-zA-Z0-9";
			editbox.addChild(guestNameField);
			
			button = new ButtonHex("PLAY AS GUEST", ConnectAsGuest, "button_medium_gold", 22);
			button.x = leftPanel.width / 2 - button.width / 2;
			button.y = 330;
			leftPanel.addChild(button);
		
			tf.size = 14;
			tf.bold = false;

			guestNameLabel = new TextField();
			guestNameLabel.text = "NAME:";
			guestNameLabel.setTextFormat(tf);
			guestNameLabel.x = 20;
			guestNameLabel.y = 95;
			guestNameLabel.mouseEnabled = false;
			guestNameLabel.autoSize = TextFieldAutoSize.LEFT;
			rightPanel.addChild(guestNameLabel);
			
			tf.size = 10;
			
			guestNameLabel = new TextField();
			guestNameLabel.text = "MAX 15 CHARS";
			guestNameLabel.setTextFormat(tf);
			guestNameLabel.y = 95;
			guestNameLabel.mouseEnabled = false;
			guestNameLabel.autoSize = TextFieldAutoSize.RIGHT;
			guestNameLabel.x = rightPanel.width - 25 - guestNameLabel.width;
			rightPanel.addChild(guestNameLabel);
			
			editbox = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = rightPanel.width / 2 - editbox.width / 2;
			editbox.y = 114;
			rightPanel.addChild(editbox);
			
			nameField = new TextField();
			nameField.type = TextFieldType.INPUT;
			nameField.defaultTextFormat = editTF;
			nameField.x = 10;
			nameField.width = editbox.width - 20;
			nameField.autoSize = TextFieldAutoSize.LEFT;
			nameField.y = editbox.height / 2 - nameField.height / 2;
			nameField.autoSize = TextFieldAutoSize.NONE;
			nameField.width = editbox.width - 20;
			nameField.maxChars = 15;
			editbox.addChild(nameField);
			
			tf.size = 14;
			
			guestNameLabel = new TextField();
			guestNameLabel.text = "PASSWORD:";
			guestNameLabel.setTextFormat(tf);
			guestNameLabel.x = 20;
			guestNameLabel.y = 175;
			guestNameLabel.mouseEnabled = false;
			guestNameLabel.autoSize = TextFieldAutoSize.LEFT;
			rightPanel.addChild(guestNameLabel);
			
			editbox = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = rightPanel.width / 2 - editbox.width / 2;
			editbox.y = 195;
			rightPanel.addChild(editbox);
			
			passwordField = new TextField();
			passwordField.type = TextFieldType.INPUT;
			passwordField.defaultTextFormat = editTF;
			passwordField.x = 10;
			passwordField.width = editbox.width - 20;
			passwordField.autoSize = TextFieldAutoSize.LEFT;
			passwordField.y = editbox.height / 2 - passwordField.height / 2;
			passwordField.autoSize = TextFieldAutoSize.NONE;
			passwordField.width = editbox.width - 20;
			passwordField.displayAsPassword = true;
			passwordField.addEventListener(KeyboardEvent.KEY_UP, OnEnterPressed, false, 0, true);
			editbox.addChild(passwordField);
			
			button = new ButtonHex("LOG IN", Login, "button_medium_gold", 22, -1, 220);
			button.x = rightPanel.width / 2 - button.width / 2;
			button.y = 330;
			rightPanel.addChild(button);
			
			button = new ButtonHex("FORGOT\nPASSWORD ?", onForgotPassword, "button_small_gray", 10, -1, 108);
			button.x = 22;
			button.y = 240;
			rightPanel.addChild(button);
			
			try {
				var so:SharedObject = SharedObject.getLocal("prefs");
				if(!so.data.hasOwnProperty("rememberMe")) {
					so.data.rememberMe = 0;
				}
				so.flush();
			}
			catch(errObject:Error) {
				// nothing
			}
			
			rememberButton = new Sprite();
			rememberButton.x = 140;
			//rememberButton.y = 258;
			rememberButton.addEventListener(MouseEvent.CLICK, onRememberMe, false, 0, true);
			rememberButton.useHandCursor = true;
			rememberButton.buttonMode = true;
			rightPanel.addChild(rememberButton);
			
			var checkbox:Sprite = new Sprite();
			checkbox.addChild(ResList.GetArtResource(so.data.rememberMe == 0 ? "checkbox" : "checkbox_selected"));
			checkbox.x = 110;
			rememberButton.addChild(checkbox);
			
			tf.color = 0xAAAAAA;
			tf.size = 13;
			var rememberText:TextField = new TextField();
			rememberText.x = 14;
			rememberText.text = "Remember me";
			rememberText.setTextFormat(tf);
			rememberText.autoSize = TextFieldAutoSize.LEFT;
			rememberText.y = rememberButton.height / 2 - rememberText.height / 2;
			rememberText.mouseEnabled = false;
			rememberButton.addChild(rememberText);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			
			rememberButton.y = button.y + button.height / 2 - rememberButton.height / 2;
			
			tf.color = -1;
			
			var mute:MutePanel = new MutePanel(false);
			mute.x = 592;
			mute.y = 538;
			addChild(mute);
			
			G.gatracker.trackPageview("/login");
		}
		
		private static var firstInit:Boolean = true;
		public function addedToStage(event:Event):void {
			stage.focus = nameField;
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			// try to log in from saved data
			var so:SharedObject = SharedObject.getLocal("prefs");
			if(so.data.rememberMe == 1) {
				if(so.data.loginName != null)
					nameField.text = so.data.loginName;
				if(so.data.loginPass != null)
					passwordField.text = so.data.loginPass;
				if(firstInit)
					Login()
				firstInit = false;
			}
		}
		
		private function onForgotPassword():void {
			if(loading) return;
			
			parent.addChild(new PasswordRecoveryScreen());
			parent.removeChild(this);
		}
		
		private function onRememberMe(event:MouseEvent):void {
			var so:SharedObject = SharedObject.getLocal("prefs");
			so.data.rememberMe = 1 - so.data.rememberMe;

			rememberButton.removeChildAt(0)
			var checkbox:Sprite = new Sprite();
			checkbox.addChild(ResList.GetArtResource(so.data.rememberMe == 0 ? "checkbox" : "checkbox_selected"));
			checkbox.x = 110;
			rememberButton.addChildAt(checkbox, 0);
			
			try {
				so.flush();
			}
			catch(errObject:Error) {
				// nothing
			}
			
			G.sounds.playSound("button_click0");
		}
		
		private function OnEnterPressed(event:KeyboardEvent):void {
			if(event.charCode == Input.KEY_ENTER)
				Login();
		}
		
		private function Login():void {
			if(loading) return;
			
			PlayerIO.quickConnect.simpleConnect(stage, G.gameID, nameField.text, passwordField.text, handleConnect, handleError);
			loading = new Loading();
			addChild(loading);
			
			G.gatracker.trackPageview("/login/start");
		}
		
		private function Register():void {
			if(loading) return;
			
			parent.addChild(new RegisterScreen());
			parent.removeChild(this);
		}
		
		private function ConnectAsGuest():void {
			if(loading) return;
			
			if(guestNameField.text.substr(0, 5) == "Guest")
				G.user.name = guestNameField.text;
			else
				G.user.name = "Guest " + guestNameField.text;
			
			G.user.isGuest = true;
			
			trace("connect guest");
			PlayerIO.quickConnect.simpleConnect(
				stage,					//Referance to stage
				G.gameID,				//Game id (Get your own at playerio.com)
				"guestaccount",			//Username
				"guestaccountvw11",		//User auth. Can be left blank if authentication is disabled on connection
				handleGuestConnect,		//Function executed on successful connect
				handleError				//Function executed if we recive an error
			);
			
			loading = new Loading();
			addChild(loading);
			
			G.gatracker.trackPageview("/login/guest");
		}
		
		public function ConnectionSuccesful():void {
			// just to rename this so we can use it inside that anon function
			var self:DisplayObject = this;
			
			if(G.user.isGuest) {
				if(loading) {
					removeChild(loading);
					loading = null;
				}
				
				if(parent) {
					if(G.user.isGuest)
						parent.addChild(new Lobby());
					else 
						parent.addChild(new MainMenu());
					parent.removeChild(self);
				}
			}
			else {
				G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void{
					try {
						G.user.premiumUntil = playerobject.PremiumUntil;
						G.user.xp = playerobject.XP;
						G.user.totalXP = playerobject.TotalXP;
						G.user.rating = playerobject.RankingRating;
						G.user.level = playerobject.Level;
						G.user.race = Race.Create(playerobject.Race);
						G.user.achievements = playerobject.Achievements;
						G.user.stats = playerobject.Stats;
						G.user.shards = playerobject.Shards;
						G.user.background = playerobject.Background;
						G.user.playerObject = playerobject;
						G.user.blackList = playerobject.Blacklist;
						
						//if(playerobject.hasOwnProperty("TutorialFinished"))
							//G.showTutorial = false;
						
						if(loading) {
							removeChild(loading);
							loading = null;
						}
						
						if(parent) {
							parent.addChild(new MainMenu());
							parent.removeChild(self);
						}
					}
					catch(errObject:Error) {
						G.client.errorLog.writeError("connection success load my player objects", "", errObject.message, null);
					}
				});
			}
		}
		
		public function loginWith(name:String, password:String):void {
			nameField.text = name;
			passwordField.text = password;
			joinUserRoom();
		}
		
		private function joinUserRoom():void {
			if(loading == null) {
				loading = new Loading();
				addChild(loading);
			}
			
			G.client.multiplayer.createJoinRoom(
				G.user.name,						//Room id. If set to null a random roomid is used
				"UserRoom" + G.gameVersion,			//The game type started on the server
				false,								//Should the room be visible in the lobby?
				null,					//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{Name:G.user.name},									//User join data
				handleUserRoomJoin,					//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		private function handleConnect(client:Client):void{
			try {
				trace("Sucessfully connected to player.io");
				G.user.name = nameField.text;
				G.user.isGuest = false;
				G.client = client;
				
				//Set developmentsever (Comment out to connect to your server online)
				if(G.localServer)
					G.client.multiplayer.developmentServer = "localhost:8184";
				
				try {
					// save account data
					var so:SharedObject = SharedObject.getLocal("prefs");
					so.data.loginName = nameField.text;
					so.data.loginPass = passwordField.text;
					so.flush();
				}
				catch(errObject:Error) {
					// something happened during saving, no biggie, he probably has disabled flash cookies
				}
				
				joinUserRoom();
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle connect error", "", errObject.message, null);
			}
		}
		
		private function handleGuestConnect(client:Client):void{
			try{
				G.client = client;
				G.user.isGuest = true;
		
				//Set developmentsever (Comment out to connect to your server online)
				if(G.localServer)
					G.client.multiplayer.developmentServer = "localhost:8184";
				
				ConnectionSuccesful();
				
				G.gatracker.trackPageview("/login/guest/success");
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle guest connect error", "", errObject.message, null);
				
				G.gatracker.trackPageview("/login/error");
			}
			
			if(!G.localServer)
				new MultiboxPreventer(DicewarsClient.multiboxDetected);
		}
		
		private function playerInitialized(m:Message):void {
			G.client.payVault.refresh(payVaultInited, handleError);
		}
		
		private function payVaultInited():void {
			trace("pre pay");
			if(usernameInitialized) {
				ConnectionSuccesful();
			}
			else {
				payvaultInitialized = true;
			}
			trace("post pay");
		}
		
		private function onUsernameSet(m:Message):void {
			trace("pre name");
			if(payvaultInitialized) {
				ConnectionSuccesful();
			}
			else {
				usernameInitialized = true;
			}
			trace("post name");
		}
		
		private function handleUserRoomJoin(connection:Connection):void {
			trace("handle join");
			if(G.userConnection) return;
			
			G.setUserConnection(connection);
			//G.userConnection = connection;
			connection.addMessageHandler(MessageID.REMOTE_LOGIN, G.remoteLogin);
			connection.addMessageHandler(MessageID.PLAYER_BANNED, G.banned);
			connection.addMessageHandler(MessageID.USER_GET_LOGIN_REWARD, G.loginRewardReceived);
			connection.addMessageHandler(MessageID.PLAYER_INITIALIZED, playerInitialized);
			connection.addMessageHandler(MessageID.USER_USERNAME_SET, onUsernameSet);
			connection.addMessageHandler(MessageID.ACHIEVEMENT_UNLOCKED, G.user.achievementUnlocked);
			connection.send(MessageID.USER_SET_USERNAME, G.user.name);
			
			if(!G.localServer)
				new MultiboxPreventer(DicewarsClient.multiboxDetected);
			
			G.gatracker.trackPageview("/login/succes");
		}
		
		private function handleDisconnect():void{
			trace("Disconnected from server")
		}
		
		private function handleError(error:PlayerIOError):void{
			try {
				if(loading) {
					removeChild(loading);
					loading = null;
				}
				
				trace("got",error.message);
				ErrorManager.showPIOError(error);
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle error", "", errObject.message, null);
			}
			
			G.gatracker.trackPageview("/login/error");
		}

	}
}