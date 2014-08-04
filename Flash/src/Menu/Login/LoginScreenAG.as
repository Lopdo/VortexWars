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
	
	public class LoginScreenAG extends Sprite
	{
		private var nameField:TextField;
		private var passwordField:TextField;
		
		private var guestNameField:TextField;
		
		private var rememberButton:Sprite;
		private var rememberMe:Boolean;
		
		private var loading:Loading = null;
	
		private var usernameInitialized:Boolean = false;
		private var payvaultInitialized:Boolean = false;
		
		private var loadingSprite:Sprite;
		
		// Developer key and game key (used for AGI authentication).
		// NOTE: Use your own developer key and game key.
		private var devKey:String = "c65b34566f12e1a242e86fcd3b36e60d";
		private var gameKey:String = "vortex";
		

		public function LoginScreenAG()
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
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 10;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			tf.size = 16;
			
			label = new TextField();
			label.text = "Log in using your Armorgames account or play as guest (you will not be able to get any XP or unlock new items as guest)";
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
			
			loadingSprite = new Sprite();
			addChild(loadingSprite);
			
			G.gatracker.trackPageview("/loginAG");
		}
		
		//private var loading:Loading;
		
		//private static var firstInit:Boolean = true;
		public function addedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			loading = new Loading();
			loadingSprite.addChild(loading);
			
			// URL to the AGI swf.
			var agi_url:String = "http://agi.armorgames.com/assets/agi/AGI.swf";
			Security.allowDomain( agi_url );
			
			// Load the AGI
			var urlRequest:URLRequest = new URLRequest( agi_url );
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
			loader.load( urlRequest );
		}

		private function loadComplete(event:Event):void
		{
			trace("load complete");
			// Save the AGI reference
			G.agi = event.currentTarget.content;
			
			// Add the AGI as a child to your document class or lowest level display object (required)
			addChild( DisplayObject(G.agi) );
			
			// Initialize the AGI with your developer key and game key
			G.agi.init( devKey, gameKey );

			if(G.agi.isLoggedIn()) {
				trace("is logged in");
				PlayerIO.connect(stage, G.gameID, "public", "armor" + G.agi.getUserName(), "", "armorgames", handleConnect, function(e:PlayerIOError):void{
					//handleFailedAuth(e)
					G.gatracker.trackPageview("/loginAG/error");
				});
			}
			else {
				if(loading) {
					loadingSprite.removeChild(loading);
					loading = null;
				}
			}
		}

		private function generateHash(name:String):void {
			PlayerIO.quickConnect.simpleConnect(stage, G.gameID, "guestaccount", "guestaccountvw11", function(client:Client):void {
				client.multiplayer.createJoinRoom(null, "Auth"+G.gameVersion, false, {}, {}, function(c:Connection):void{
					
					c.send("auth", name)
					c.addMessageHandler("auth", function(m:Message, aauth:String):void{
						PlayerIO.connect(stage, G.gameID, "secure", name, aauth, "armorgames", handleConnect, function(e:PlayerIOError):void{
							//handleFailedAuth(e)
							c.disconnect()
						});
					});
					
				}, handleError);
			});	
		}
		
		private function handleLogin(result:Object):void {
			//removeChild(loading);
			//loading = null;
			
			if(result.success && result.loggedIn){
				loading = new Loading();
				loadingSprite.addChild(loading);
				
				var auid:String = "armor" + result.username;
				generateHash(auid);
			}else{
				//agContainer.visible = false;
				//logout();
				G.agi.logout();
				if(loading) {
					loadingSprite.removeChild(loading);
					loading = null;
				}
			}
		}
		
		private function Login():void {
			if(loading) return;
			
			//loading = new Loading();
			//loadingSprite.addChild(loading);

			G.agi.showLogin(handleLogin);
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
			loadingSprite.addChild(loading);
		}
		
		public function ConnectionSuccesful():void {
			// just to rename this so we can use it inside that anon function
			var self:DisplayObject = this;
			
			G.gatracker.trackPageview("/loginAG/success");


			if(G.user.isGuest) {
				if(loading) {
					loadingSprite.removeChild(loading);
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
							loadingSprite.removeChild(loading);
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
				loadingSprite.addChild(loading);
			}
			
			G.client.multiplayer.createJoinRoom(
				"armor" + G.agi.getUserName(),						//Room id. If set to null a random roomid is used
				"UserRoom" + G.gameVersion,			//The game type started on the server
				false,								//Should the room be visible in the lobby?
				null,								//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{Name:G.agi.getUserName()},			//User join data
				handleUserRoomJoin,					//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		private function handleConnect(client:Client):void{
			try {
				trace("Sucessfully connected to player.io using AG");
				G.client = client;
				G.user.name = G.agi.getUserName();
				G.user.isGuest = false;
				
				//Set developmentsever (Comment out to connect to your server online)
				if(G.localServer)
					G.client.multiplayer.developmentServer = "localhost:8184";
				
				joinUserRoom();
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle connect error", "", errObject.message, null);
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
				
				ConnectionSuccesful();
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle guest connect error", "", errObject.message, null);
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
			
			trace("current partner" + G.client.partnerPay.currentPartner);
		}
		
		private function handleDisconnect():void{
			trace("Disconnected from server")
		}
		
		private function handleError(error:PlayerIOError):void{
			try {
				if(loading) {
					loadingSprite.removeChild(loading);
					loading = null;
				}
				
				trace("got",error.message);
				ErrorManager.showPIOError(error);
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle error", "", errObject.message, null);
			}
			
			G.gatracker.trackPageview("/loginAG/error");
		}

	}
}