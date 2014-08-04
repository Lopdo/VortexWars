package Menu.GameRoom
{
	
	import Errors.ErrorManager;
	import Errors.PlaySmartErrorScreen;
	
	import Game.Game;
	import Game.Races.Race;
	
	import IreUtils.DebugSprite;
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Lobby.Lobby;
	import Menu.Lobby.LobbyChat;
	import Menu.MainMenu.MainMenu;
	import Menu.MainMenu.MenuShortcutsPanel;
	import Menu.NinePatchSprite;
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import playerio.Connection;
	import playerio.ErrorLog;
	import playerio.Message;
	import playerio.PlayerIO;
	
	public class GameRoom extends Sprite
	{
		private var connection:Connection;
		
		private var readyButton:ButtonHex;
		
		private var chatScreen:LobbyChat;
		
		private var slots:Array = new Array();
		private var gameId:String;

		private var raceImg:Sprite;
		private var availableRaces:Array = new Array();
		private var currentRace:int;
		
		private var gameNameText:TextField;
		private var gameType:TextField;
		private var mapSize:TextField;
		private var startType:Sprite;
		private var distributionType:Sprite;
		private var mapSprite:Sprite;
		private var upgradesSprite:Sprite;
		//private var upgradesStrike:Sprite;
		
		private var mapGroup:int;
		private var mapIndex:int;
		private var mapKey:String;
		
		private var playersPanel:Sprite;
		
		private var startingGame:Boolean = false;
		private var beingKicked:Boolean = false;
		
		private var countdown:Timer;
		
		public function GameRoom(conn:Connection, id:String)
		{
			super();
			
			gameId = id;
			connection = conn;
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);

			var gameInfoPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 408, 153); 
			addChild(gameInfoPanel);
			gameInfoPanel.x = 40;
			gameInfoPanel.y = 20;
			
			var imgBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 98, 98);
			imgBg.x = 30;
			imgBg.y = 8;
			gameInfoPanel.addChild(imgBg);
			
			raceImg = new Sprite();
			raceImg.addChild(G.user.race.profileImage);
			raceImg.x = 4;
			raceImg.y = 4;
			raceImg.scaleX = 0.5;
			raceImg.scaleY = 0.5;
			imgBg.addChild(raceImg);
			
			if(!G.user.isGuest) {
				var button:Button = new Button(null, onPrevRace, ResList.GetArtResource("selector_arrow_disabled"));
				button.x = imgBg.x - button.width - 6;
				button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
				gameInfoPanel.addChild(button);
				
				button = new Button(null, onNextRace, ResList.GetArtResource("selector_arrow_disabled"));
				button.x = imgBg.x + imgBg.width + 6 + button.width;
				button.scaleX = -1;
				button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
				gameInfoPanel.addChild(button);
			}
			
			var tf:TextFormat = new TextFormat("Arial", 12, -1, false);
			
			var label:TextField = new TextField();
			label.text = "Game name:";
			label.setTextFormat(tf);
			label.x = 166;
			label.y = 12;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			gameInfoPanel.addChild(label);
			
			label = new TextField();
			label.text = "Game options:";
			label.setTextFormat(tf);
			label.x = 166;
			label.y = 72;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			gameInfoPanel.addChild(label);
			
			tf.bold = true;
			
			tf.size = 14;
			if(G.host == G.HOST_PLAYSMART) {
				tf.size = 12;				
			}
			
			var emboss:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 230, 28);
			emboss.x = 166;
			emboss.y = 30;
			gameInfoPanel.addChild(emboss);
			
			gameNameText = new TextField();
			gameNameText.defaultTextFormat = tf;
			gameNameText.text = "Game name: ";
			gameNameText.width = emboss.width;
			gameNameText.setTextFormat(tf);
			gameNameText.autoSize = TextFieldAutoSize.CENTER;
			gameNameText.y = 14 - gameNameText.height / 2;
			gameNameText.mouseEnabled = false;
			emboss.addChild(gameNameText);
			if(G.host == G.HOST_PLAYSMART) {
				gameNameText.mouseEnabled = true;					
			}
			
			tf.size = 14;
			
			emboss = new NinePatchSprite("9patch_emboss_panel", 130, 24);
			emboss.x = 166;
			emboss.y = 90;
			gameInfoPanel.addChild(emboss);
			
			gameType = new TextField();
			gameType.defaultTextFormat = tf;
			gameType.width = 70;
			gameType.x = 0;
			gameType.text = " ";
			gameType.autoSize = TextFieldAutoSize.CENTER;
			gameType.y = 12 - gameType.height / 2;
			gameType.mouseEnabled = false;
			emboss.addChild(gameType);
			
			upgradesSprite = new Sprite();
			upgradesSprite.x = 76;
			upgradesSprite.y = 2;
			emboss.addChild(upgradesSprite);

			emboss = new NinePatchSprite("9patch_emboss_panel", 130, 26);
			emboss.x = 166;
			emboss.y = 118;
			gameInfoPanel.addChild(emboss);
			
			startType = new Sprite();
			startType.addChild(ResList.GetArtResource("lobby_gameStartType_full"));
			startType.x = 20;
			startType.y = 13 - startType.height / 2;
			emboss.addChild(startType);
			startType.removeChildAt(0);
			
			distributionType = new Sprite();
			distributionType.addChild(ResList.GetArtResource("lobby_gameDistType_random"));
			distributionType.x = 80;
			distributionType.y = 13 - distributionType.height / 2;
			emboss.addChild(distributionType);
			distributionType.removeChildAt(0);
			
			emboss = new NinePatchSprite("9patch_emboss_panel", 96, 80);
			emboss.x = 300;
			emboss.y = 64;
			gameInfoPanel.addChild(emboss);
			
			mapSprite = new Sprite();
			mapSprite.addChild(ResList.GetArtResource("mapPreview_random"));
			mapSprite.width = 70;
			mapSprite.height = 70;
			mapSprite.x = emboss.width / 2 - 35;
			mapSprite.y = emboss.height / 2 - 35;
			emboss.addChild(mapSprite);
			
			var mptf:TextFormat = new TextFormat("Arial", 14, 0xFEE027, true);
			
			mapSize = new TextField();
			mapSize.defaultTextFormat = mptf;
			mapSize.autoSize = TextFieldAutoSize.LEFT;
			mapSize.mouseEnabled = false;
			mapSize.x = 8;
			mapSize.y = 60;
			emboss.addChild(mapSize);
			
			var outline:GlowFilter = new GlowFilter(0x000000,1.0,1.0,1.0,10);
			outline.quality=BitmapFilterQuality.HIGH;
			label.filters = [outline];

			playersPanel = new NinePatchSprite("9patch_transparent_panel", 290, 474); 
			addChild(playersPanel);
			playersPanel.x = 507;
			playersPanel.y = 64;
			
			readyButton = new ButtonHex("READY", onReady2, "button_small_gold");
			readyButton.x = 700;
			readyButton.y = 12;
			if(G.host != G.HOST_PLAYSMART) {
				addChild(readyButton);
			}
			
			chatScreen = new LobbyChat(MessageID.MESSAGE_SEND);
			chatScreen.setConnection(connection);
			addChild(chatScreen);
			
			G.user.isHost = false;
			G.user.isReady = false;
			
			if(G.host != G.HOST_PLAYSMART) {
				addChild(new MenuShortcutsPanel(onLeave));
			}
			
			G.invitedTo = null;
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			connection.addMessageHandler(MessageID.PLAYER_SET_ID, MessageReceived);
			connection.addMessageHandler(MessageID.PLAYER_LEFT, MessageReceived);
			connection.addMessageHandler(MessageID.PLAYER_JOINED, MessageReceived);
			connection.addMessageHandler(MessageID.PLAYER_KICKED, MessageReceived);
			connection.addMessageHandler(MessageID.POST_LOGIN_INFO, MessageReceived);
			connection.addMessageHandler(MessageID.PLAYER_READY, MessageReceived);
			connection.addMessageHandler(MessageID.PLAYER_SET_HOST, MessageReceived);
			connection.addMessageHandler(MessageID.GAME_START, MessageReceived);
			connection.addMessageHandler(MessageID.MESSAGE_RECEIVED, MessageReceived);
			connection.addMessageHandler(MessageID.GAME_JOIN_FAIL_GAME_FULL, MessageReceived);
			connection.addMessageHandler(MessageID.GAME_JOIN_FAIL_RECENTLY_KICKED, MessageReceived);
			connection.addMessageHandler(MessageID.GAME_JOIN_FAIL_GAME_STARTED, MessageReceived);
			connection.addMessageHandler(MessageID.GAME_RACE_CHANGED, MessageReceived);
			connection.addMessageHandler(MessageID.LOBBY_START_COUNTDOWN, MessageReceived);
			connection.addMessageHandler(MessageID.SPECTATOR_INGAME_JOIN, MessageReceived);
			connection.addMessageHandler(MessageID.MOD_COMMAND_FAILED, MessageReceived);
			connection.addMessageHandler(MessageID.MOD_COMMAND_SUCCESS, MessageReceived);
			connection.addMessageHandler(MessageID.GAME_PLAYER_MOD_KICKED, MessageReceived);
			connection.addMessageHandler(MessageID.GAME_KICKED, MessageReceived);
			connection.addDisconnectHandler(handleDisconnect);
			
			if(G.user.isGuest) {
				onReady(null);
				//readyButton.visible = false;
			}
			
			availableRaces.push(Race.RACE_ELVES);
			availableRaces.push(Race.RACE_SNOW_GIANTS);
			availableRaces.push(Race.RACE_LEGIONAIRES);
			if(G.user.isPremium())
				availableRaces.push(Race.RACE_ALIENS);
			if(Race.Create(Race.RACE_SOLDIERS).isUnlocked()) 
				availableRaces.push(Race.RACE_SOLDIERS);
			if(Race.Create(Race.RACE_ROBOTS).isUnlocked()) 
				availableRaces.push(Race.RACE_ROBOTS);
			if(Race.Create(Race.RACE_ELEMENTALS).isUnlocked()) 
				availableRaces.push(Race.RACE_ELEMENTALS);
			if(Race.Create(Race.RACE_PIRATES).isUnlocked()) 
				availableRaces.push(Race.RACE_PIRATES);
			if(Race.Create(Race.RACE_NINJAS).isUnlocked()) 
				availableRaces.push(Race.RACE_NINJAS);
			if(Race.Create(Race.RACE_INSECTOIDS).isUnlocked()) 
				availableRaces.push(Race.RACE_INSECTOIDS);
			if(Race.Create(Race.RACE_DEMONS).isUnlocked()) 
				availableRaces.push(Race.RACE_DEMONS);
			if(Race.Create(Race.RACE_ANGELS).isUnlocked()) 
				availableRaces.push(Race.RACE_ANGELS);
			if(Race.Create(Race.RACE_PUMPKINS).isUnlocked()) 
				availableRaces.push(Race.RACE_PUMPKINS);
			if(Race.Create(Race.RACE_VAMPIRES).isUnlocked()) 
				availableRaces.push(Race.RACE_VAMPIRES);
			if(Race.Create(Race.RACE_REPTILES).isUnlocked()) 
				availableRaces.push(Race.RACE_REPTILES);
			if(Race.Create(Race.RACE_ARACHNIDS).isUnlocked()) 
				availableRaces.push(Race.RACE_ARACHNIDS);
			if(Race.Create(Race.RACE_DRAGONS).isUnlocked()) 
				availableRaces.push(Race.RACE_DRAGONS);
			if(Race.Create(Race.RACE_SNOWMEN).isUnlocked()) 
				availableRaces.push(Race.RACE_SNOWMEN);
			if(Race.Create(Race.RACE_REINDEERS).isUnlocked()) 
				availableRaces.push(Race.RACE_REINDEERS);
			if(Race.Create(Race.RACE_SANTAS).isUnlocked()) 
				availableRaces.push(Race.RACE_SANTAS);
			if(Race.Create(Race.RACE_NATIVES).isUnlocked()) 
				availableRaces.push(Race.RACE_NATIVES);
			if(Race.Create(Race.RACE_UNDEAD).isUnlocked()) 
				availableRaces.push(Race.RACE_UNDEAD);
			if(Race.Create(Race.RACE_TERMINATORS).isUnlocked()) 
				availableRaces.push(Race.RACE_TERMINATORS);
			if(Race.Create(Race.RACE_BLADE_MASTERS).isUnlocked()) 
				availableRaces.push(Race.RACE_BLADE_MASTERS);
			if(Race.Create(Race.RACE_CYBORGS).isUnlocked()) 
				availableRaces.push(Race.RACE_CYBORGS);
			if(Race.Create(Race.RACE_DARK_KNIGHTS).isUnlocked()) 
				availableRaces.push(Race.RACE_DARK_KNIGHTS);
			if(Race.Create(Race.RACE_TEDDY_BEARS).isUnlocked()) 
				availableRaces.push(Race.RACE_TEDDY_BEARS);
			if(Race.Create(Race.RACE_WATCHMEN).isUnlocked()) 
				availableRaces.push(Race.RACE_WATCHMEN);
			if(Race.Create(Race.RACE_WEREWOLVES).isUnlocked()) 
				availableRaces.push(Race.RACE_WEREWOLVES);
			if(Race.Create(Race.RACE_FRANKENSTEINS).isUnlocked()) 
				availableRaces.push(Race.RACE_FRANKENSTEINS);
			if(Race.Create(Race.RACE_SNOWFLAKES).isUnlocked()) 
				availableRaces.push(Race.RACE_SNOWFLAKES);
			if(Race.Create(Race.RACE_TANNENBAUMS).isUnlocked()) 
				availableRaces.push(Race.RACE_TANNENBAUMS);
			
			for(var i:int = 0; i < availableRaces.length; i++) {
				if(G.user.race.ID == availableRaces[i]) {
					currentRace = i;
					break;
				}
			}
			
			G.gatracker.trackPageview("/gameRoom");
		}
		
		private function onRemovedFromStage(event:Event):void {
			trace("removed from stage");
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			if(!startingGame) {
				G.user.ID = -1;
				if(connection) {
					connection.disconnect();
					clearConnection();
					connection = null;
				}
			}
		}
		
		private function onPlayerKicked(index:int):void {
			connection.send(MessageID.KICK_PLAYER, index);
			//slots[index].clear();
		}
	
		/*public function onInvite():void {
			addChild(new InviteScreen(gameID));
		}*/
		
		public function onStart():void {
			if(checkPlayersReady()) {
				connection.send(MessageID.GAME_START);
			}
		}
		
		public function checkPlayersReady():Boolean {
			var allReady:Boolean = true;
			var playerCount:int = 0;
			for(var i:int = 0; i < slots.length; ++i) {
				if(slots[i].isOccupied()) {
					allReady = allReady && slots[i].getReady();
					playerCount++;
				}
			}
			allReady = allReady && (playerCount > 1); 
			if(G.user.isHost/*readyButton*/) {
				if(allReady) {
					readyButton.setImage("button_small_gold");
				}
				else {
					readyButton.setImage("button_small_gray");
				}
			}
			return allReady;
		}

		public function onReady2():void {
			onReady(null);
		}
		
		public function onReady(button:Button):void {
			G.user.isReady = !(G.user.isReady);
			connection.send(MessageID.PLAYER_READY, G.user.isReady);
			
			if(G.user.isReady) {
				readyButton.setText("NOT READY");
				readyButton.setImage("button_small_gray");
			}
			else {
				readyButton.setText("READY");
				readyButton.setImage("button_small_gold");
			}
			
			readyButton.visible = false;
		}
		
		public function onLeave():void {
			G.user.ID = -1;
			connection.disconnect();
			clearConnection();
			connection = null;
			
			parent.addChild(new Lobby());
			parent.removeChild(this);
		}
		
		public function handleDisconnect():void{
			G.user.ID = -1;
			
			if(connection) {
				connection.disconnect();
				clearConnection();
				connection = null;
			}
			
			if(G.host == G.HOST_PLAYSMART) {
				parent.addChild(new PlaySmartErrorScreen());
				parent.removeChild(this);
			}
			else {
				if(parent) {
					if(beingKicked)
						parent.addChild(new Lobby());
					else
						parent.addChild(new MainMenu());
					parent.removeChild(this);
				}
			}
		}
		
		private function clearConnection():void {
			if(connection) {
				connection.removeDisconnectHandler(handleDisconnect);
				connection.removeMessageHandler(MessageID.PLAYER_SET_ID, MessageReceived);
				connection.removeMessageHandler(MessageID.PLAYER_LEFT, MessageReceived);
				connection.removeMessageHandler(MessageID.PLAYER_JOINED, MessageReceived);
				connection.removeMessageHandler(MessageID.PLAYER_KICKED, MessageReceived);
				connection.removeMessageHandler(MessageID.POST_LOGIN_INFO, MessageReceived);
				connection.removeMessageHandler(MessageID.PLAYER_READY, MessageReceived);
				connection.removeMessageHandler(MessageID.PLAYER_SET_HOST, MessageReceived);
				connection.removeMessageHandler(MessageID.GAME_START, MessageReceived);
				connection.removeMessageHandler(MessageID.MESSAGE_RECEIVED, MessageReceived);
				connection.removeMessageHandler(MessageID.GAME_JOIN_FAIL_GAME_FULL, MessageReceived);
				connection.removeMessageHandler(MessageID.GAME_JOIN_FAIL_RECENTLY_KICKED, MessageReceived);
				connection.removeMessageHandler(MessageID.GAME_JOIN_FAIL_GAME_STARTED, MessageReceived);
				connection.removeMessageHandler(MessageID.GAME_RACE_CHANGED, MessageReceived);
				connection.removeMessageHandler(MessageID.LOBBY_START_COUNTDOWN, MessageReceived);
				connection.removeMessageHandler(MessageID.SPECTATOR_INGAME_JOIN, MessageReceived);
				connection.removeMessageHandler(MessageID.MOD_COMMAND_FAILED, MessageReceived);
				connection.removeMessageHandler(MessageID.MOD_COMMAND_SUCCESS, MessageReceived);
				connection.removeMessageHandler(MessageID.GAME_PLAYER_MOD_KICKED, MessageReceived);
				connection.removeMessageHandler(MessageID.GAME_KICKED, MessageReceived);
			}
		}
		
		private function StartGame(m:Message):void {
			if(countdown) {
				countdown.stop();
				countdown = null;
			}
			
			var g:Game;
			g = new Game(connection, gameId);
			g.LoadGameFromMessage(m);
			g.mapGroup = mapGroup;
			g.mapIndex = mapIndex;
			g.mapId = mapKey;

			try {
				clearConnection();
				
				startingGame = true;
				
				if(parent) {
					parent.addChild(g);
					parent.removeChild(this);
				}
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("StartGame 1", errObject.message, "", null);
			}
		} 
		
		private function StartGameSpectator(m:Message):void {
			if(countdown) {
				countdown.stop();
				countdown = null;
			}
			
			var g:Game;
			g = new Game(connection, gameId);
			g.LoadSpectGameFromMessage(m);
			//g.mapGroup = mapGroup;
			//g.mapIndex = mapIndex;
			
			try {
				if(connection) {
					clearConnection();
				}
				
				startingGame = true;
				
				if(parent) {
					parent.addChild(g);
					parent.removeChild(this);
				}
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("StartGame 10", errObject.message, "", null);
			}
		} 
		
		public function MessageReceived(m:Message):void {
			var index:int = 0;
			
			switch(m.type) {
				case MessageID.PLAYER_SET_ID:
					G.user.ID = m.getInt(0);
					break;
				case MessageID.PLAYER_LEFT:
					chatScreen.removeUser(m.getInt(0));
					chatScreen.addMessage(m.getString(1), "has left"/*, G.htmlColors[m.getInt(2)]*/);
					if(slots[m.getInt(2)])
						slots[m.getInt(2)].clear();
					if(m.getInt(0) == G.user.ID) {
						G.user.ID = -1;
					}
					checkPlayersReady();
					
					if(countdown) {
						countdown.stop();
						countdown = null;
					}
					
					break;
				case MessageID.PLAYER_JOINED:
					chatScreen.addGameUser(m.getInt(0), m.getString(1), m.getInt(3), m.getBoolean(4), m.getBoolean(5), m.getString(8), m.getInt(9));
					chatScreen.addMessage(m.getString(1), "has joined"/*, G.htmlColors[m.getInt(2)]*/);
					if(G.user.ID == m.getInt(0)) {
						if(slots[m.getInt(2)])
							slots[m.getInt(2)].setMe();
					}
					if(slots[m.getInt(2)]) {
						slots[m.getInt(2)].setName(m.getString(1), m.getBoolean(4), m.getString(8), m.getInt(9));
						slots[m.getInt(2)].setRace(m.getString(6));
						slots[m.getInt(2)].setLevel(m.getInt(3));
						if(G.user.isHost) {
							slots[m.getInt(2)].addKickButton(onPlayerKicked);
						}
					}
					checkPlayersReady();
					break;
				case MessageID.PLAYER_KICKED:
					if(G.user.ID == m.getInt(0)) {
						ErrorManager.showCustomError("You have been kicked from the game", ErrorManager.ERROR_KICKED, null);
						beingKicked = true;
					}
					break;
				case MessageID.POST_LOGIN_INFO:
					var tooltip:TextTooltip;
					gameId = m.getString(index++);
					G.roomID = gameId;
					gameNameText.text = m.getString(index++);
					var gt:int = m.getInt(index++);
					switch(gt) {
						case 0: gameType.text = "HC"; break;
						case 1: gameType.text = "ATT"; break;
						case 2: gameType.text = "1v1"; break;
					}
					mapGroup = m.getInt(index++);
					mapIndex = m.getInt(index++);
					mapKey = m.getString(index++);
					mapSprite.removeChildAt(0);
					if(mapGroup == 100) {
						mapSprite.addChild(ResList.GetArtResource("mapPreview_random"));
						switch(mapIndex) {
							case 0: 
								mapSize.text = "S"; 
								tooltip = new TextTooltip("Map: Random small", mapSprite);
								break;
							case 1: 
								mapSize.text = "M"; 
								tooltip = new TextTooltip("Map: Random medium", mapSprite);
								break;
							case 2: 
								mapSize.text = "L"; 
								tooltip = new TextTooltip("Map: Random large", mapSprite);
								break;
							case 3: 
								mapSize.text = "XL"; 
								tooltip = new TextTooltip("Map: Random huge", mapSprite);
								break;
							case 4: 
								mapSize.text = "XXL"; 
								tooltip = new TextTooltip("Map: Random gigantic", mapSprite);
								break;
						}
					} 
					else if(mapGroup == 101) {
						//var req:URLRequest = new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/MapImages/" + mapKey + ".png"));
						var req:URLRequest = new URLRequest("http://vortexwars.com/maps/" + mapKey + ".png");
						var loader:Loader = new Loader();
						loader.load(req);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
							mapSprite.addChild(loader.content);
						}, false, 0, true);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (error:IOErrorEvent):void {}, false, 0, true);
					}
					else {
						mapSprite.addChild(ResList.GetArtResource("mapPreview_" + mapGroup + "_" + mapIndex));
						tooltip = new TextTooltip("Map: " + G.getMapName(mapGroup, mapIndex), mapSprite);
					}

					var st:int = m.getInt(index++);
					
					startType.addChild(ResList.GetArtResource("lobby_gameStartType_" + (st == 0 ? "full" : "conquer")));
					tooltip = new TextTooltip("Start type: " + (st == 0 ? "Full map" : "Conquer"), startType);
					
					var distType:int = m.getInt(index++);
					switch(distType) {
						case 0: 
							distributionType.addChild(ResList.GetArtResource("lobby_gameDistType_random"));
							tooltip = new TextTooltip("New Units: Random", distributionType);
							break;
						case 1: 
							distributionType.addChild(ResList.GetArtResource("lobby_gameDistType_manual")); 
							tooltip = new TextTooltip("New Units: Manual", distributionType);
							break;
						case 2: 
							distributionType.addChild(ResList.GetArtResource("lobby_gameDistType_border")); 
							tooltip = new TextTooltip("New Units: Borders", distributionType);
							break;
					}
					
					var upgradesEnabled:Boolean = m.getBoolean(index++);
					var boostsEnabled:Boolean = m.getBoolean(index++);
					
					var b:Bitmap;
					if(upgradesEnabled == boostsEnabled) {
						b = ResList.GetArtResource("army_logoAngels");
						b.scaleX = b.scaleY = 26 / b.height;
						b.x = -1;
						b.y = -2;
						upgradesSprite.addChild(b);
						
						b = ResList.GetArtResource("boost_defense_icon");
						b.x = 23;
						b.y = 2;
						upgradesSprite.addChild(b);
						
						tooltip = new TextTooltip("Upgrades and bonuses " + (upgradesEnabled ? "enabled" : "disabled"), upgradesSprite);
					}
					if(upgradesEnabled && !boostsEnabled) {
						b = ResList.GetArtResource("boost_attack_icon");
						b.x = 7;
						b.y = 3;
						upgradesSprite.addChild(b);
						b = ResList.GetArtResource("boost_defense_icon");
						b.x = 21;
						b.y = 2;
						upgradesSprite.addChild(b);
						
						tooltip = new TextTooltip("Upgrades enabled, boosts disabled", upgradesSprite);
					}
					if(!upgradesEnabled && boostsEnabled) {
						b = ResList.GetArtResource("army_logoAngels");
						b.scaleX = b.scaleY = 26 / b.height;
						b.x = -1;
						b.y = -2;
						upgradesSprite.addChild(b);
						
						b = ResList.GetArtResource("army_logoDemons");
						b.scaleX = b.scaleY = 26 / b.height;
						b.x = 16;
						b.y = -2;
						upgradesSprite.addChild(b);
						
						tooltip = new TextTooltip("Upgrades disabled, boosts enabled", upgradesSprite);
					}
					
					if(!upgradesEnabled || !boostsEnabled) {
						var l:Sprite = new Sprite();
						l.graphics.lineStyle(2, 0xFF0000);
						l.graphics.moveTo(4,3);
						l.graphics.lineTo(35,18);
						upgradesSprite.addChild(l);
					}
					
					var maxPlayers:int = m.getInt(index++);
					for(i = 0; i < maxPlayers; ++i) {
						var slot:PlayerSlot = new PlayerSlot(i, onReady);
						slot.x = 12;
						slot.y = 10 + i * 58;
						slots[i] = slot;
						playersPanel.addChild(slot);
					}
					
					var playerCount:int = m.getInt(index++);
					for(var i:int = 0; i < playerCount; ++i) {
						if(m.getInt(index) != G.user.ID) {
							chatScreen.addGameUser(m.getInt(index), m.getString(index + 1), m.getInt(index + 4), m.getBoolean(index + 5), m.getBoolean(index + 6), m.getString(index + 8), m.getInt(index + 9));
						}
						else {
							if(slots[m.getInt(index + 2)])
								slots[m.getInt(index + 2)].setMe()
						}
						if(slots[m.getInt(index + 2)]) {
							slots[m.getInt(index + 2)].setName(m.getString(index + 1), m.getBoolean(index + 5), m.getString(index + 8), m.getInt(index + 9));
							slots[m.getInt(index + 2)].setRace(m.getInt(index + 7));
							slots[m.getInt(index + 2)].setLevel(m.getInt(index + 4));
							slots[m.getInt(index + 2)].setReady(m.getBoolean(index + 3));
						}
						index += 10;
					}
					
					break;
				case MessageID.PLAYER_READY:
					if(slots[m.getInt(0)])
						slots[m.getInt(0)].setReady(m.getBoolean(1));
					checkPlayersReady();
					break;
				case MessageID.PLAYER_SET_HOST:
					slot = slots[m.getInt(0)];
					if(slot != null) {
						slot.removeKickButton();
						slot.setReady(true);
					}
					else {
						G.client.errorLog.writeError("PLAYER_SET_HOST - slot is null", "index: " + m.getInt(0), "", null);
					}
					G.user.isHost = G.user.isReady = true;
					readyButton.setText("START!");
					readyButton.setCallback(onStart);
					readyButton.visible = true;
					
					checkPlayersReady();
					
					for each(var s:PlayerSlot in slots) {
						if(s.isOccupied() && s.index != G.user.colorID)
							s.addKickButton(onPlayerKicked);
					} 
					break;
				case MessageID.GAME_RACE_CHANGED:
					if(slots[m.getInt(0)])
						slots[m.getInt(0)].setRace(m.getInt(1));
					break;
				case MessageID.GAME_START:
					StartGame(m);
					break;
				case MessageID.MESSAGE_RECEIVED:
					chatScreen.addMessage(m.getString(0), m.getString(1), m.getBoolean(3) ? "#c2e4f9" : (m.getBoolean(2) ? "#F5E192" : "#BAAF96"));
					break;
				case MessageID.GAME_JOIN_FAIL_GAME_FULL:
					beingKicked = true;
					ErrorManager.showCustomError2("Game is full, please join another game", "NOTICE", ErrorManager.ERROR_GAME_FULL);
					break;
				case MessageID.GAME_JOIN_FAIL_GAME_STARTED:
					beingKicked = true;
					ErrorManager.showCustomError2("This game already started, please join another game", "NOTICE", ErrorManager.ERROR_GAME_STARTED);
					break;
				case MessageID.GAME_JOIN_FAIL_RECENTLY_KICKED:
					beingKicked = true;
					ErrorManager.showCustomError2("You have been recently kicked from this game. You need to wait a while before you can join again.", "NOTICE", ErrorManager.ERROR_GAME_FULL);
					break;
				case MessageID.LOBBY_START_COUNTDOWN:
					trace("start countdown");
					startCountdown();
					break;
				case MessageID.SPECTATOR_INGAME_JOIN:
					StartGameSpectator(m);
					break;
				case MessageID.MOD_COMMAND_FAILED:
					chatScreen.addMessage(m.getString(0), "", "#858585");
					break;
				case MessageID.MOD_COMMAND_SUCCESS:
					chatScreen.addMessage(m.getString(0), "", "#858585");
					break;
				case MessageID.GAME_KICKED:
					ErrorManager.showCustomError("You have been kicked from game", ErrorManager.ERROR_KICKED, null);
					beingKicked = true;
					break;
				case MessageID.GAME_PLAYER_MOD_KICKED:
					chatScreen.addMessage(m.getString(0) + " has been kicked for following reason: " + m.getString(1), "", "#858585");
					break;

			}
			//trace("Recived the message", m)
		}
		
		private function startCountdown():void {
			if(G.host == G.HOST_PLAYSMART) {
				countdown = new Timer(1000, 4);
				countdown.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {chatScreen.addMessage("", "Game starts in " + (5 - countdown.currentCount) + "...");});
				countdown.start();
				chatScreen.addMessage("", "Game starts in 5...");				
			}
			else {
				countdown = new Timer(1000, 2);
				countdown.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {chatScreen.addMessage("", "Game starts in " + (3 - countdown.currentCount) + "...");});
				countdown.start();
				chatScreen.addMessage("", "Game starts in 3...");
			}
		}
		
		private function setRace(raceID:int):void {
			G.user.race = Race.Create(raceID);
			
			connection.send(MessageID.USER_SET_RACE, G.user.race.ID);
			raceImg.removeChildAt(0);
			raceImg.addChild(G.user.race.profileImage);
		}
		
		private function onNextRace(button:Button):void {
			currentRace = (currentRace + 1) % availableRaces.length;
			setRace(availableRaces[currentRace]);
		}
		
		private function onPrevRace(button:Button):void {
			currentRace = (currentRace + availableRaces.length - 1) % availableRaces.length;
			setRace(availableRaces[currentRace]);
		}
	}
}