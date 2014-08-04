package Menu.Login
{
	import Errors.ErrorManager;
	
	import Game.Races.Race;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.MainMenu.MainMenu;
	import Menu.MutePanel;
	import Menu.NinePatchSprite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	public class LoginFacebook extends Sprite
	{
		private var loadingSprite:Loading;
		private var usernameField:TextField;
		public function LoginFacebook()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			loadingSprite = new Loading();
			addChild(loadingSprite);
			
			var mute:MutePanel = new MutePanel(false);
			mute.x = width / 2 - mute.width / 2;
			mute.y = 470;
			addChild(mute);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			var aff:String = (G.loaderParams != null ? (G.loaderParams.pio$affiliate || null) : null);
			PlayerIO.quickConnect.facebookOAuthConnect(stage, G.gameID, G.loaderParams.fb_access_token, aff, handleConnect, handleError);
		}
		
		private function handleConnect(client:Client, id:String=""):void {
			G.client = client;
			G.client.bigDB.loadRange("Usernames", "Key", ["fb" + G.loaderParams.fb_user_id], null, null, 1, function(arr:Array):void {
				if(arr.length == 0) {
					if(loadingSprite) {
						removeChild(loadingSprite);
						loadingSprite = null;
					}
					showSetUsernameScreen();
				}
				else {
					var nameObj:DatabaseObject = arr[0];
					login(nameObj.key);
				}
			}, function(error:PlayerIOError):void {
				ErrorManager.showCustomError("Failed to connect to server, please try again later", 0);
			});
		}
		
		private function handleError(error:PlayerIOError):void {
			ErrorManager.showCustomError("Failed to connect to server, please try again later", 0);
		}
		
		private function showSetUsernameScreen():void {
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			
			var label:TextField = new TextField();
			label.text = "Welcome";
			label.setTextFormat(tf);
			label.width = 800;
			label.y = 200;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			addChild(label);
			
			tf.size = 14;
			tf.bold = false;
			
			label = new TextField();
			label.text = "Pick your username:";
			label.setTextFormat(tf);
			label.y = 240;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			addChild(label);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = 800 / 2 - editbox.width / 2;
			editbox.y = label.y + label.height + 6;
			addChild(editbox);
			
			usernameField = new TextField();
			usernameField.type = TextFieldType.INPUT;
			usernameField.defaultTextFormat = editTF;
			usernameField.autoSize = TextFieldAutoSize.LEFT;
			usernameField.y = editbox.height / 2 - usernameField.height / 2;
			usernameField.autoSize = TextFieldAutoSize.NONE;
			usernameField.x = 10;
			usernameField.width = editbox.width - 20;
			usernameField.addEventListener(KeyboardEvent.KEY_UP, onEnterPressed, false, 0, true);
			editbox.addChild(usernameField);
			
			label.x = editbox.x + 6;
			
			var button:ButtonHex = new ButtonHex("Continue", checkUsername, "button_small_gold");
			button.x = 400 - button.width / 2;
			button.y = editbox.y + editbox.height + 40;
			addChild(button);
		}
		
		private function onEnterPressed(event:KeyboardEvent):void {
			if(event.charCode == Input.KEY_ENTER)
				checkUsername();
		}
		
		private function checkUsername():void {
			G.client.bigDB.loadRange("Usernames", "UsernameLowercase", [usernameField.text.toLowerCase()], null, null, 1, function(arr:Array):void {
				if(arr.length == 0) {
					login(usernameField.text);
				}
				else {
					ErrorManager.showCustomError("This username is already taken, please choose different username", 0);
				}
			}, function(error:PlayerIOError):void {
				ErrorManager.showCustomError("Username check failed, please try again later. Err: " + error.errorID, 0);
			});
		}
		
		private function login(username:String):void {
			if(loadingSprite == null) {
				loadingSprite = new Loading();
				addChild(loadingSprite);
			}
			
			G.user.name = username;
			
			if(G.localServer)
				G.client.multiplayer.developmentServer = "localhost:8184";

			G.client.multiplayer.createJoinRoom(
				username,						//Room id. If set to null a random roomid is used
				"UserRoom" + G.gameVersion,			//The game type started on the server
				false,								//Should the room be visible in the lobby?
				null,					//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{Name:username},									//User join data
				handleUserRoomJoin,					//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		private function handleUserRoomJoin(connection:Connection):void {
			if(G.userConnection) return;
			
			G.userConnection = connection;
			connection.addMessageHandler(MessageID.REMOTE_LOGIN, G.remoteLogin);
			connection.addMessageHandler(MessageID.PLAYER_BANNED, G.banned);
			connection.addMessageHandler(MessageID.USER_GET_LOGIN_REWARD, G.loginRewardReceived);
			connection.addMessageHandler(MessageID.FB_INVITES_REWARD, G.fbInviteRewardReceived);
			connection.addMessageHandler(MessageID.PLAYER_INITIALIZED, playerInitialized);
			//connection.addMessageHandler(MessageID.USER_USERNAME_SET, onUsernameSet);
			connection.addMessageHandler(MessageID.ACHIEVEMENT_UNLOCKED, G.user.achievementUnlocked);
			connection.send(MessageID.USER_SET_USERNAME, G.user.name);
			
			if(!G.localServer)
				new MultiboxPreventer(DicewarsClient.multiboxDetected);
		}
		
		private function playerInitialized(m:Message):void {
			G.client.payVault.refresh(payVaultInited, handleError);
		}
		
		private function payVaultInited():void {
			var self:DisplayObject = this;
			
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
					//	G.showTutorial = false;
					
					if(loadingSprite) {
						removeChild(loadingSprite);
						loadingSprite = null;
					}
					
					if(parent) {
						parent.addChild(new MainMenu());
						parent.removeChild(self);
					}
				}
				catch(errObject:Error) {
					G.client.errorLog.writeError("connection success load my player objects", "", errObject.message, null);
					ErrorManager.showCustomError("Loading failed, please try again later", 0);
				}
			});
		}
	}
}
