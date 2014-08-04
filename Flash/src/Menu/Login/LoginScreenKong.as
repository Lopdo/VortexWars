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
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.system.Security;
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
	
	public class LoginScreenKong extends Sprite
	{
		private var nameField:TextField;
		private var passwordField:TextField;
		
		private var guestNameField:TextField;
		
		private var rememberButton:Sprite;
		private var rememberMe:Boolean;
		
		private var loading:Loading = null;
	
		private var usernameInitialized:Boolean = false;
		private var payvaultInitialized:Boolean = false;
		
		public function LoginScreenKong()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var bgPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 400, 300);
			bgPanel.x = width / 2 - bgPanel.width / 2;
			bgPanel.y = height / 2 - bgPanel.height / 2;
			addChild(bgPanel);
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 28;
			tf.color = -1;
			tf.bold = true;
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "LOG IN";
			label.setTextFormat(tf);
			label.x = 20;
			label.width = bgPanel.width - 40;
			//label.multiline = true;
			//label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 10;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			tf.size = 16;
			
			label = new TextField();
			label.text = "Log in using your Kongregate account or play as guest (you will not be able to get any XP or unlock new items as guest)";
			label.setTextFormat(tf);
			label.x = 40;
			label.width = bgPanel.width - 80;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 50;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			var button:ButtonHex = new ButtonHex("LOG IN", Login, "button_medium_gold", 22, -1, 220);
			button.x = bgPanel.width / 2 - button.width / 2;
			button.y = 126;
			bgPanel.addChild(button);
			
			button = new ButtonHex("PLAY AS GUEST", ConnectAsGuest, "button_medium_gray", 22, -1, 220);
			button.x = bgPanel.width / 2 - button.width / 2;
			button.y = 200;
			bgPanel.addChild(button);
			
			/*button = new Button("REGISTER", Register, ResList.GetArtResource("button_reg_blue"), 20);
			button.x = bgPanel.width / 2 - button.width / 2 + 80;
			button.y = 200;
			bgPanel.addChild(button);*/
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			var mute:MutePanel = new MutePanel(false);
			mute.x = width / 2 - mute.width / 2;
			mute.y = 470;
			addChild(mute);
			
			G.gatracker.trackPageview("/loginKong");
		}
		
		//private var loading:Loading;
		
		//private static var firstInit:Boolean = true;
		public function addedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			loading = new Loading();
			addChild(loading);
			
			// Pull the API path from the FlashVars
			//var paramObj:Object = LoaderInfo(stage.root.loaderInfo).parameters;
			var paramObj:Object = G.loaderParams;
			
			// The API path. The "shadow" API will load if testing locally. 
			var apiPath:String = paramObj.kongregate_api_path || 
				"http://www.kongregate.com/flash/API_AS3_Local.swf";
			
			// Allow the API access to this SWF
			Security.allowDomain(apiPath);
			
			// Load the API
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			this.addChild(loader);
			
			trace("added to stage");
			// This function is called when loading is complete
		}

		private function loadComplete(event:Event):void
		{
			trace("load complete");
			// Save Kongregate API reference
			G.kongregate = event.target.content;
			
			// Connect to the back-end
			G.kongregate.services.connect();
			//ErrorManager.showCustomError("connect", 0);
			
			removeChild(loading);
			loading = null;
			
			if(!G.kongregate.services.isGuest()) {
				Login();
			}
			else {
				// Listen for a guest->user conversion, which can happen without a refresh
				G.kongregate.services.addEventListener("login", onKongregateInPageLogin);
			}
		}

		private function onKongregateInPageLogin(event:Event):void {
			// Get the user's new login credentials
			//var user_id:Number = kongregate.services.getUserId();
			//var username:String = kongregate.services.getUsername();
			//var token:String = kongregate.services.getGameAuthToken();
			
			// Log in with new credentials here
			Login();
		}
		
		private function Login():void {
			if(loading) return;
			
			if(!G.kongregate.services.isGuest()) {
				trace("login");
				trace("user id: " + G.kongregate.services.getUserId());
				trace("auth token: " + G.kongregate.services.getGameAuthToken());
				
				PlayerIO.quickConnect.kongregateConnect(stage, G.gameID, G.kongregate.services.getUserId(), G.kongregate.services.getGameAuthToken(), handleConnect, handleError);
				
				loading = new Loading();
				addChild(loading);
			}
			else {
				G.kongregate.services.showSignInBox();
				G.gatracker.trackPageview("/loginKong/showSignIn");
			}
		}
		
		private function Register():void {
			//Property showRegistrationBox not found on com.kongregate.as3.client.services.KongregateServices and there is no default value.
			G.kongregate.services.showRegistrationBox();
		}
		
		private function ConnectAsGuest():void {
			if(loading) return;
			
			/*if(guestNameField.text.substr(0, 5) == "Guest")
				G.user.name = guestNameField.text;
			else
				G.user.name = "Guest " + guestNameField.text;*/
			G.user.name = "Guest" + (int)(Math.random() * 10000);
			G.user.isGuest = true;
			
			trace("connect guest");
			PlayerIO.connect(
				stage,					//Referance to stage
				G.gameID,				//Game id (Get your own at playerio.com)
				"public",				//Connection id, default is public
				G.user.name,			//Username
				"",						//User auth. Can be left blank if authentication is disabled on connection
				null, 					// partner id
				handleGuestConnect,		//Function executed on successful connect
				handleError				//Function executed if we recive an error
			);
			
			loading = new Loading();
			addChild(loading);
			
			G.gatracker.trackPageview("/loginKong/guest/start");
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
						G.user.background = playerobject.Background;
						G.user.playerObject = playerobject;
						G.user.blackList = playerobject.Blacklist;
						
						//if(playerobject.hasOwnProperty("TutorialFinished"))
						//	G.showTutorial = false;
						
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
		
		private function joinUserRoom():void {
			if(loading == null) {
				loading = new Loading();
				addChild(loading);
			}
			
			G.client.multiplayer.createJoinRoom(
				"Kong" + G.kongregate.services.getUserId(),						//Room id. If set to null a random roomid is used
				"UserRoom" + G.gameVersion,			//The game type started on the server
				false,								//Should the room be visible in the lobby?
				null,	//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{Name:G.kongregate.services.getUserId()},									//User join data
				handleUserRoomJoin,					//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		private function handleConnect(client:Client):void{
			try {
				trace("Sucessfully connected to player.io osing kong");
				G.user.name = G.kongregate.services.getUsername();
				G.user.isGuest = false;
				G.client = client;
				
				//Set developmentsever (Comment out to connect to your server online)
				if(G.localServer)
					G.client.multiplayer.developmentServer = "localhost:8184";
				
				joinUserRoom();
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle connect error", "", errObject.message, null);
				
				G.gatracker.trackPageview("/loginKong/error");
			}
			
			if(!G.localServer)
				new MultiboxPreventer(DicewarsClient.multiboxDetected);
		}
		
		private function handleGuestConnect(client:Client):void{
			try{
				G.client = client;
				G.user.isGuest = true;
		
				//Set developmentsever (Comment out to connect to your server online)
				if(G.localServer)
					G.client.multiplayer.developmentServer = "localhost:8184";
				
				G.gatracker.trackPageview("/loginKong/guest/success");
				ConnectionSuccesful();
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle guest connect error", "", errObject.message, null);
				G.gatracker.trackPageview("/loginKong/error");
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
				G.gatracker.trackPageview("/loginKong/success");
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
				G.gatracker.trackPageview("/loginKong/success");
			}
			else {
				usernameInitialized = true;
			}
			trace("post name");
		}
		
		private function handleUserRoomJoin(connection:Connection):void {
			if(G.userConnection) return;
			
			//G.userConnection = connection;
			G.setUserConnection(connection);
			connection.addMessageHandler(MessageID.REMOTE_LOGIN, G.remoteLogin);
			connection.addMessageHandler(MessageID.PLAYER_BANNED, G.banned);
			connection.addMessageHandler(MessageID.USER_GET_LOGIN_REWARD, G.loginRewardReceived)
			connection.addMessageHandler(MessageID.PLAYER_INITIALIZED, playerInitialized);
			connection.addMessageHandler(MessageID.USER_USERNAME_SET, onUsernameSet);
			connection.addMessageHandler(MessageID.ACHIEVEMENT_UNLOCKED, G.user.achievementUnlocked);
			
			connection.send(MessageID.USER_SET_USERNAME, G.user.name);
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
		}

	}
}