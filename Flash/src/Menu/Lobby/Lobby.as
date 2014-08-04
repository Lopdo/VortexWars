package Menu.Lobby
{
	import Errors.ErrorManager;
	
	import Game.Game;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.ConfirmationDialog;
	import Menu.GameRoom.GameRoom;
	import Menu.Loading;
	import Menu.Login.LoginScreen;
	import Menu.MainMenu.MainMenu;
	import Menu.MainMenu.MenuShortcutsPanel;
	import Menu.NinePatchSprite;
	import Menu.PlayerProfile.ProfileBadge;
	
	import Tutorial.TutorialGame;
	import Tutorial.WelcomeScreen;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	
	public class Lobby extends Sprite
	{
		private var createGameScreen:CreateGameScreen;
		private var playerPanel:ProfileBadge;
		
		private var loadingRooms:Boolean = false;
		private var refreshButton:ButtonHex;
		private var roomList:Array = new Array();
		private var gamesPanel:Sprite;
		
		private var timer:Timer;
		private var nextRefreshIn:int = 10;
		
		private var lobbyConnection:Connection;
		
		private var chatScreen:LobbyChat;
		
		private var loading:Loading;
		
		private var alreadyInGame:Boolean = false;
		
		private var pagingText:TextField;
		private var pagingRight:Button;
		private var pagingLeft:Button;
		private var currentPage:int = 1;
		private var pageCount:int = 1;
		
		private var filter:Filter = new Filter();
		
		//private var connectingGameName:String;
		private var connectingGameID:String;
		
		public function Lobby(roomId:String = "")
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var createGameButton:ButtonHex = new ButtonHex("CREATE", onCreateGame, "button_small_gold");
			createGameButton.x = 587;
			createGameButton.y = 2;
			addChild(createGameButton);
			
			var filterButton:ButtonHex = new ButtonHex("FILTER", onFilter, "button_small_gray", 14, -1, 90);//, 14, -1, 91);
			filterButton.x = 500;
			filterButton.y = 2;
			addChild(filterButton);
			
			refreshButton = new ButtonHex("REFRESH", onRefresh, "button_small_gray", 14, -1, 108);
			refreshButton.x = 691;
			refreshButton.y = 2;
			addChild(refreshButton);
			refreshButton.setText("LOADING...");
			
			playerPanel = new ProfileBadge();
			addChild(playerPanel);
			
			gamesPanel = new NinePatchSprite("9patch_transparent_panel", 292, 471);
			gamesPanel.x = 504;
			gamesPanel.y = 43;
			addChild(gamesPanel);
			
			var pagingPanel:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 54, 23);
			pagingPanel.x = 624;
			pagingPanel.y = 523;
			addChild(pagingPanel);
			
			var tf:TextFormat = new TextFormat("Arial", 13, -1);
			tf.align = TextFormatAlign.CENTER;
			
			pagingText = new TextField();
			pagingText.defaultTextFormat = tf;
			pagingText.x = 0;
			pagingText.width = 54;
			pagingText.text = "1/1";
			pagingText.autoSize = TextFieldAutoSize.CENTER;
			pagingText.y = pagingPanel.height / 2 - pagingText.height / 2;
			pagingText.mouseEnabled = false;
			pagingPanel.addChild(pagingText);
			
			pagingLeft = new Button(null, onPagingLeft, ResList.GetArtResource("selector_arrow_disabled"));
			pagingLeft.x = 589;
			pagingLeft.y = 523;
			addChild(pagingLeft);
			
			pagingRight = new Button(null, onPagingRight, ResList.GetArtResource("selector_arrow_disabled"));
			pagingRight.x = 694 + 18;
			pagingRight.y = 523;
			pagingRight.scaleX = -1;
			addChild(pagingRight);
			
			chatScreen = new LobbyChat(MessageID.LOBBY_MESSAGE_SEND);
			addChild(chatScreen);
			
			refreshRooms(null);
			
			trace("connect");
			
			G.client.multiplayer.createJoinRoom(
				roomId == "" ? "$service-room$" : roomId,
				"LobbyRoom" + G.gameVersion,
				false,
				{},
				{ Guest:G.user.isGuest, Name:G.user.name},
				handleLobbyJoin,
				handleError
			);
			

			addChild(new MenuShortcutsPanel(leave));
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			G.gatracker.trackPageview("/lobby");
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if(G.invitedTo != null) {
				onGameClicked(G.invitedTo);
			}
			
			if(!G.user.isGuest) {
				G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void{
					try {
						var prevXP:int = G.user.xp;
						var prevLvl:int = G.user.level;
						
						G.user.xp = playerobject.XP;
						G.user.level = playerobject.Level;
						G.user.playerObject = playerobject;
						
						if(G.user.firstLoad) {
							prevXP = G.user.xp;
							prevLvl = G.user.level;
							G.user.firstLoad = false;
						}
						playerPanel.updateValues(prevXP, prevLvl);
					}
					catch(errObject:Error) {
						G.client.errorLog.writeError("handle load my player objects", "lobby added to stage", errObject.message, null);
					}
				});
			}
			
			var so:SharedObject = SharedObject.getLocal("prefs");
			if(!so.data.hasOwnProperty("tutorialDisplayed") && (!G.user.isGuest && !G.user.playerObject.hasOwnProperty("TutorialFinished"))) {
				G.errorSprite.addChild(new WelcomeScreen(this));
				so.data.tutorialDisplayed = true;
				so.flush();
			}
		}
		
		public function startTutorial():void {
			parent.addChild(new TutorialGame());
			parent.removeChild(this);
		}
		
		private function onRemovedFromStage(event:Event):void {
			trace("removed from stage");
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			if(lobbyConnection) {
				lobbyConnection.disconnect();
				lobbyConnection.removeMessageHandler(MessageID.LOBBY_MESSAGE_SEND, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.LOBBY_PLAYER_JOINED, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.LOBBY_PLAYER_LEFT, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.LOBBY_POST_JOIN, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.LOBBY_TOO_MANY_MESSAGES, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.LOBBY_KICKED, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.MOD_COMMAND_FAILED, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.MOD_COMMAND_SUCCESS, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.LOBBY_PLAYER_KICKED, MessageReceived);
				lobbyConnection.removeMessageHandler(MessageID.PLAYER_BANNED, G.banned);
				lobbyConnection = null;
			}
			
			if(timer) {
				timer.removeEventListener(TimerEvent.TIMER, refreshRooms);
				timer.stop();
				timer = null;
			}
		}
		
		private function onRefresh():void {
			nextRefreshIn = 5;
			//timer.stop();
			
			refreshRooms(null);
		}
		
		private function refreshRooms(event:TimerEvent):void {
			if(loadingRooms) return;
			
			loadingRooms = true;
			// don't change button label if it is periodical refresh
			if(event == null)
				refreshButton.setText("LOADING...");
			
			// list rooms
			G.client.multiplayer.listRooms(
				"Wargrounds" + G.gameVersion,				//Type of room
				{Started:"false"},							// filter
				40,							// Limit to 20 results
				0,							// Start at the first room
				handleRoomList,
				handleChatRoomError
			);
			
			nextRefreshIn += 5;
			/*timer = new Timer(nextRefreshIn * 1000); // 15 second
			timer.addEventListener(TimerEvent.TIMER, refreshRooms);
			timer.repeatCount = 1;
			timer.start();*/
		}
		
		private function onCreateGame():void {
			if(loading) {
				return;
			}
			
			/*if(G.user.isGuest) {
				addChild(new ConfirmationDialog("You need to be signed in to create new games", "Sign in", onSignIn, "Cancel"));
				return;
			}*/
			
			createGameScreen = new CreateGameScreen();
			addChild(createGameScreen);
		}
		
		private function onSignIn():void {
			parent.addChild(new LoginScreen());
			parent.removeChild(this);
		}
		
		private function onFilter():void {
			addChild(new FilterScreen(filter));
		}
		
		public function CreateRoomScreenClosed():void {
			removeChild(createGameScreen);
			createGameScreen = null;
		}
		
		public function CreateGame(params:Object):void {
			removeChild(createGameScreen);
			createGameScreen = null;
			
			loading = new Loading();
			addChild(loading);
			
			//connectingGameName = params.name;
			
			G.client.multiplayer.createJoinRoom(
				null,								//Room id. If set to null a random roomid is used
				"Wargrounds" + G.gameVersion,		//The game type started on the server
				true,								//Should the room be visible in the lobby?
				params,								//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{ Guest:G.user.isGuest, Name:G.user.name, Spectator:false },									//User join data
				handleJoin,							//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		private function orderRooms(a:LobbyGame, b:LobbyGame):int { 
			if(a.started && b.started) {
				return 0
			}
			if(a.started && !b.started) {
				return 1;
			}
			if(!a.started && b.started) {
				return -1;
			}
			if(a.isFull && b.isFull) {
				return 0;
			}
			if(a.isFull && !b.isFull) {
				return 1;
			}
			if(!a.isFull && b.isFull) {
				return -1;
			}
			return 0;
		} 
		
		private function handleRoomList(rooms:Array):void {
			roomList.length = 0;
			
			for(var i:int = 0; i < rooms.length; ++i) {
				var ri:RoomInfo = rooms[i];
				if(filter.check(ri.data.gameType, ri.data.mapGroup, ri.data.startType, ri.data.troopsDist, ri.data.upgradesEnabled, ri.data.boostsEnabled) 
					&& ri.data.Visible == "true" && G.user.level >= ri.data.minLevel && (ri.data.minLevel != 1 || !G.user.isGuest)) {
					var lg:LobbyGame = new LobbyGame(ri.id, ri.data.name, ri.data.PlayerCount, ri.data.maxPlayers, this, ri.data.Started == "true", ri.data.mapGroup, ri.data.mapDetail, ri.data.userMap, ri.data.startType, ri.data.gameType, ri.data.troopsDist, ri.data.boostsEnabled, ri.data.upgradesEnabled);
					lg.x = 6;
					roomList.push(lg);
				}
			}
			
			G.client.multiplayer.listRooms(
				"Wargrounds" + G.gameVersion,				//Type of room
				{Started:"true"},							// filter
				!G.user.isGuest && G.user.playerObject.Moderator ? 0 : 10,							// Limit to 20 results
				0,							// Start at the first room
				handleRoomList2,
				handleChatRoomError
			);
		}
		
		private function handleRoomList2(rooms:Array):void {
			for(var i:int = 0; i < rooms.length; ++i) {
				var ri:RoomInfo = rooms[i];
				if(filter.check(ri.data.gameType, ri.data.mapGroup, ri.data.startType, ri.data.troopsDist, ri.data.upgradesEnabled, ri.data.boostsEnabled) 
					&& ri.data.Visible == "true" && G.user.level >= ri.data.minLevel && (ri.data.minLevel != 1 || !G.user.isGuest)) {
					var lg:LobbyGame = new LobbyGame(ri.id, ri.data.name, ri.data.PlayerCount, ri.data.maxPlayers, this, ri.data.Started == "true", ri.data.mapGroup, ri.data.mapDetail, ri.data.userMap, ri.data.startType, ri.data.gameType, ri.data.troopsDist, ri.data.boostsEnabled, ri.data.upgradesEnabled);
					lg.x = 6;
					roomList.push(lg);
				}
			}
			
			roomList.sort(orderRooms);
			
			refreshButton.setText("REFRESH");
			loadingRooms = false;
			
			pageCount = roomList.length / 9 + 1;
			if(currentPage > pageCount) currentPage = pageCount;
			
			updatePagingInfo();
			updateGameList();
		}
		
		private function onPagingLeft(button:Button):void {
			if(currentPage > 1) {
				currentPage--;
				updatePagingInfo();
				updateGameList();
			}
		}
		
		private function onPagingRight(button:Button):void {
			if(currentPage < pageCount) {
				currentPage++;
				updatePagingInfo();
				updateGameList();
			}
		}
		
		private function updateGameList():void {
			for(var i:int = gamesPanel.numChildren - 1; i >= 0 ; --i) {
				if(gamesPanel.getChildAt(i) is LobbyGame) {
					gamesPanel.removeChildAt(i);
				}
			}
			
			for(i = 0; i < 8 && i + (currentPage - 1) * 8 < roomList.length; i++) {
				roomList[i + (currentPage - 1) * 8].y = 5 + 57*i;
				gamesPanel.addChild(roomList[i + (currentPage - 1) * 8]);
			}
		}
		
		public function applyFilter():void {
			roomList.length = 0;
			pageCount = currentPage = 1;
			
			refreshRooms(null);
		}
		
		private function updatePagingInfo():void {
			pagingText.text = currentPage + "/" + pageCount;
			
			pagingLeft.setImage("selector_arrow_disabled");
			pagingRight.setImage("selector_arrow_disabled");
		}
		
		public function onFullGameClicked(gameID:String):void {
			if(loading) return;
			
			ErrorManager.showCustomError("This game is full", ErrorManager.ERROR_GAME_FULL);
		}
		
		public function onStartedGameClicked(gameID:String):void {
			if(loading) return;
			
			G.errorSprite.addChild(new ConfirmationDialog("This game has already started, do you want to join as spectator?", "SPECTATE", function():void {connectAsSpectator(gameID);}, "CANCEL"));
			/*if(G.user.playerObject && G.user.playerObject.Moderator == true) {
				G.errorSprite.addChild(new ConfirmationDialog("This game has already started, do you want to join as spectator?", "SPECTATE", function():void {connectAsSpectator(gameID);}, "CANCEL"));
			}
			else {
				ErrorManager.showCustomError("This game has already started", ErrorManager.ERROR_GAME_STARTED);
			}*/
		}
		
		private function connectAsSpectator(gameID:String):void {
			G.client.multiplayer.joinRoom(gameID, { Guest:G.user.isGuest, Name:G.user.name, Spectator:true }, handleJoin, handleError);
		} 
		
		public function onGameClicked(gameID:String):void {
			if(loading) return;
			
			loading = new Loading();
			addChild(loading);
			
			//connectingGameName = name;
			connectingGameID = gameID;
			
			G.client.multiplayer.joinRoom(gameID, { Guest:G.user.isGuest, Name:G.user.name, Spectator:false }, handleJoin, handleError);
		}
		
		private function handleLobbyJoin(connection:Connection):void{
			trace("Sucessfully connected to the lobby");
			// disconnect if we are already in game or we left lobby
			if(alreadyInGame || parent == null) {
				connection.disconnect();
				lobbyConnection = null;
				
				return;
			}
			else {
				if(lobbyConnection) return;
				
				lobbyConnection = connection;
				connection.addMessageHandler(MessageID.LOBBY_MESSAGE_SEND, MessageReceived);
				connection.addMessageHandler(MessageID.LOBBY_PLAYER_JOINED, MessageReceived);
				connection.addMessageHandler(MessageID.LOBBY_PLAYER_LEFT, MessageReceived);
				connection.addMessageHandler(MessageID.LOBBY_POST_JOIN, MessageReceived);
				connection.addMessageHandler(MessageID.LOBBY_TOO_MANY_MESSAGES, MessageReceived);
				connection.addMessageHandler(MessageID.LOBBY_KICKED, MessageReceived);
				connection.addMessageHandler(MessageID.MOD_COMMAND_FAILED, MessageReceived);
				connection.addMessageHandler(MessageID.MOD_COMMAND_SUCCESS, MessageReceived);
				connection.addMessageHandler(MessageID.LOBBY_PLAYER_KICKED, MessageReceived);
				connection.addMessageHandler(MessageID.PLAYER_BANNED, G.banned);
			}
			
			chatScreen.setConnection(connection);
		}
		
		private function handleJoin(connection:Connection):void{
			trace("Sucessfully connected to the multiplayer server");
			
			alreadyInGame = true;
			
			if(lobbyConnection) {
				lobbyConnection.disconnect();
			}
				
			//Add disconnect listener
			//connection.addDisconnectHandler(handleDisconnect);
			
			if(loading) {
				removeChild(loading);
				loading = null;
			}
			
			var g:GameRoom = new GameRoom(connection, connectingGameID);
			//Listen to all messages using a private function
			G.connection = connection;
			
			if(parent) {
				parent.addChild(g);
				parent.removeChild(this);
			}
		}
		
		private function MessageReceived(m:Message):void {
			switch(m.type) {
				case MessageID.LOBBY_MESSAGE_SEND:
					trace(m.getString(0) + " " + m.getString(1) + " " + m.getBoolean(2).toString());
					chatScreen.addMessage(m.getString(0), m.getString(1), m.getBoolean(3) ? "#c2e4f9" : (m.getBoolean(2) ? "#F5E192" : "#BAAF96"));
					break;
				case MessageID.LOBBY_PLAYER_JOINED:
					//trace("player joined");
					chatScreen.addUser(m.getInt(0), m.getString(1), m.getInt(2), m.getBoolean(3), m.getBoolean(4), m.getString(5), m.getInt(6));
					break;
				case MessageID.LOBBY_PLAYER_LEFT:
					//trace("player left");
					chatScreen.removeUser(m.getInt(0));
					break;
				case MessageID.LOBBY_POST_JOIN:
					var count:int = m.getInt(0);
					for(var i:int = 0; i < count; ++i) {
						chatScreen.addUser(m.getInt(7*i + 1), m.getString(7*i + 1 + 1), m.getInt(7*i + 1 + 2), m.getBoolean(7*i + 1 + 3), m.getBoolean(7*i + 1 + 4), m.getString(7*i + 1 + 5), m.getInt(i * 7 + 1 + 6));
					}
					break;
				case MessageID.LOBBY_TOO_MANY_MESSAGES:
					chatScreen.addMessage("Slow down a bit please, you don't want to look like a spammer, do you?", "", "#858585");
					break;
				case MessageID.LOBBY_KICKED:
					G.kicked(m.getString(0));
					break;
				case MessageID.MOD_COMMAND_FAILED:
					chatScreen.addMessage(m.getString(0), "", "#858585");
					break;
				case MessageID.MOD_COMMAND_SUCCESS:
					chatScreen.addMessage(m.getString(0), "", "#858585");
					break;
				case MessageID.LOBBY_PLAYER_KICKED:
					chatScreen.addMessage(m.getString(0) + " has been kicked for following reason: " + m.getString(1), "", "#858585");
					break;
			}
		}

		private function leave():void {
			this.parent.addChild(new MainMenu());
			this.parent.removeChild(this);
		}
		
		private function handleDisconnect():void{
			trace("Disconnected from server");
		}
		
		private function handleChatRoomError(error:PlayerIOError):void {
			trace("chat room error " + error);
		}
		
		private function handleError(error:PlayerIOError):void {
			trace("handle error");
			if(loading) {
				removeChild(loading);
				loading = null;
			}
			
			if(error.type == PlayerIOError.NoServersAvailable) {
				ErrorManager.showCustomError("No servers found. Please try again later", error.errorID);
				leave();
			}
			else if(error.type == PlayerIOError.UnknownRoom) {
				ErrorManager.showCustomError("There is no room with given name", error.errorID);
			}
			else if(error.type == PlayerIOError.RoomIsFull) {
				ErrorManager.showCustomError("This game is already at its maximum capacity.", error.errorID);
			}
			else {
				ErrorManager.showPIOError(error);
				trace(error.errorID + " " + error)
			}
		}
	}
}