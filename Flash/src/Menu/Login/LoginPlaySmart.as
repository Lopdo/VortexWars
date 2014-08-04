package Menu.Login
{
	import Errors.ErrorManager;
	
	import Game.Races.Race;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.ButtonHex;
	import Menu.GameRoom.GameRoom;
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
	
	public class LoginPlaySmart extends Sprite
	{
		private var loading:Loading;
		private var gameID:String;
		private var auditId:String;
		
		public function LoginPlaySmart()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//loadingSprite = new Loading();
			//addChild(loadingSprite);
			
			var mute:MutePanel = new MutePanel(false);
			mute.x = width / 2 - mute.width / 2;
			mute.y = 470;
			addChild(mute);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			//var aff:String = (G.loaderParams != null ? (G.loaderParams.pio$affiliate || null) : null);
			//PlayerIO.quickConnect.facebookOAuthConnect(stage, G.gameID, G.loaderParams.fb_access_token, aff, handleConnect, handleError);
			var username:String;
			if(G.loaderParams) {
				username = G.loaderParams.nickname;
				G.user.ID = G.loaderParams.playerId;
				gameID = G.loaderParams.hashkey;
				auditId = G.loaderParams.auditId;
			}
			else {
				//tmp
				username = "testuser"+(int)(Math.random() * 10000);
				G.user.ID = (Math.random() * 100)
				gameID = "efcdb05fd1eed86c627fa5000a8ed4f0";
				auditId = "8";
				
			}
			
			
			connect(username);
		}
		
		private function connect(username:String):void {
			if(loading) return;
			
			G.user.isGuest = true;
			G.user.name = username;
			
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
		}
		
		private function handleGuestConnect(client:Client):void{
			try{
				G.client = client;
				G.user.isGuest = true;
				
				//Set developmentsever (Comment out to connect to your server online)
				if(G.localServer)
					G.client.multiplayer.developmentServer = "localhost:8184";
				
				connectionSuccesful();
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("handle guest connect error", "", errObject.message, null);
			}
			
			//if(!G.localServer)
			//	new MultiboxPreventer(DicewarsClient.multiboxDetected);
		}
		
		public function connectionSuccesful():void {
			// just to rename this so we can use it inside that anon function
			var self:DisplayObject = this;
			
			if(G.user.isGuest) {
				/*if(loading) {
					removeChild(loading);
					loading = null;
				}*/
				
				if(parent) {
					// todo join game
					G.client.multiplayer.createJoinRoom(
						gameID,								//Room id. If set to null a random roomid is used
						"WargroundsPS" + G.gameVersion,		//The game type started on the server
						false,								//Should the room be visible in the lobby?
						{auditId:auditId, name:gameID, gameType:1, mapGroup:100, mapDetail:2, userMap:"", startType:1, maxPlayers:2, troopsDist:1, minLevel:-1} ,								//Room data. This data is returned to lobby list. Variabels can be modifed on the server
						{ Guest:G.user.isGuest, Name:G.user.name, Spectator:false, RegId:G.user.ID },									//User join data
						handleJoin,							//Function executed on successful joining of the room
						handleError							//Function executed if we got a join error
					);
					
					/*if(G.user.isGuest)
						parent.addChild(new Lobby());
					else 
						parent.addChild(new MainMenu());*/
					//parent.removeChild(self);
				}
			}
		}
		
		private function handleJoin(connection:Connection):void{
			trace("Sucessfully connected to the multiplayer server");
			
			//alreadyInGame = true;
			
			if(loading) {
				removeChild(loading);
				loading = null;
			}
			
			var g:GameRoom = new GameRoom(connection, gameID);
			//Listen to all messages using a private function
			G.connection = connection;
			
			if(parent) {
				parent.addChild(g);
				parent.removeChild(this);
			}
		}
		
		private function handleError(error:PlayerIOError):void {
			ErrorManager.showCustomError("Failed to connect to server, please try again later", 0, null);
		}
		
	}
}
