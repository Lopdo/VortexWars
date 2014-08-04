package Game
{
	
	import Errors.ErrorManager;
	import Errors.PlaySmartErrorScreen;
	
	import Game.Chat.ChatPanel;
	import Game.FightScreens.FightScreen;
	import Game.FightScreens.OneOnOneFightScreen;
	import Game.FightScreens.SingleThrowFightScreen;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.ConfirmationDialog;
	import Menu.Lobby.Lobby;
	import Menu.MutePanel;
	
	import flash.display.Sprite;
	import flash.errors.EOFError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import playerio.Connection;
	import playerio.Message;
	
	public class Game extends Sprite
	{
		private const TURN_DURATION:int = 30;
		
		// public timekeeping stuff
		public var gameTime:Number = 0;
		public var timeDelta:Number = 0;
		// private timekeeping stuff used for timeDelta calculations
		private var oldTime:Number = 0;
		private var prevTimeDelta:Number = 0;
		private var startTime:Number;

		public var connection:Connection;
		
		protected var players:Array = new Array();
		
		protected var mapSprite:Sprite;
		protected var map:Map;
		public var mapId:String;
		protected var selectedRegion:Region;
		
		protected var sidePanel:SidePanel;
		
		protected var isMyTurn:Boolean;
		protected var activePlayer:Player;
		
		//protected var surrenderButton:Button;
		protected var offerDrawButton:ButtonHex;
		//private var surrenderButton2:Button2;
		protected var quit:ButtonHex;
		
		protected var chatPanel:ChatPanel;
		protected var turnTimer:TurnTimer;
		
		protected var gameOverScreen:GameOverScreen;
		protected var fightScreen:FightScreen;
		protected var bufferedFightResults:Array;
		
		protected var newTurnPanel:NewTurnPanel;
		protected var ingameMessage:IngameInfoMessage;
		
		protected var startType:int;
		protected var gameType:int;
		protected var troopsDist:int;
		protected var upgradesEnabled:Boolean;
		public var boostsEnabled:Boolean;
		protected var shouldShowIntroMessage:Boolean = true;
		
		protected var isPlaying:Boolean = true;
		protected var isSpectator:Boolean = false;
		
		public var isTutorial:Boolean = false;
		
		//protected var tutorialMessage:TutorialMessage;
		//protected var fightResultTutorialDisplayed:Boolean = false;
		
		protected var turnCounter:int = 0;
		protected var endTurnInQueue:Boolean = false;
		protected var queuedPostTurnMessage:Message = null;
		protected var roundCounter:int = 0;
		
		protected var playerLeftDebugString:String;
		
		protected var defenceBoostActivated:Boolean;
		protected var manualDistribution:Boolean;
		protected var newTroopsRegions:Array = new Array();
		
		public var mapGroup:int, mapIndex:int;
		
		//private var gameID:int;
		protected var queuedFights:Array = new Array();
		protected var autodistributingUnits:Boolean = false;
		
		public var supposedRegionCount:int;
		
		protected var tieDialog:ConfirmationDialog;
		
		protected var isSidePanelWide:Boolean;
		
		protected var zoomLevel:int = 0;
		protected var zoomSprite:Sprite;
		
		protected var gameId:String;
		
		public function Game(_connection:Connection, gameId:String)
		{
			super();
			
			G.gatracker.trackEvent("play", "start");
			
			this.gameId = gameId;
			
			this.connection = _connection;
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			oldTime = (new Date).getTime();
			
			mapSprite = new Sprite();
			addChild(mapSprite);
			
			sidePanel = new SidePanel();
			addChild(sidePanel);
			sidePanel.x = 550;
			sidePanel.y = 0;
			
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			
			offerDrawButton = new ButtonHex("OFFER DRAW", offerTie, "button_small_gray", 14, -1, 134);
			offerDrawButton.x = 664;
			offerDrawButton.y = 519;
			offerDrawButton.visible = false;
			addChild(offerDrawButton);
			
			quit = new ButtonHex("SURRENDER", onSurrender, "button_small_gold", 14, -1, 134);
			quit.x = 664;
			quit.y = 557;
			addChild(quit);
			
			chatPanel = new ChatPanel(this);
			addChild(chatPanel);
			
			turnTimer = new TurnTimer(onEndTurn);
			addChild(turnTimer);
			
			var mute:MutePanel = new MutePanel(true);
			mute.x = 6;
			mute.y = 6;
			addChild(mute);
			
			zoomSprite = new Sprite();
			zoomSprite.x = 515;
			zoomSprite.y = 0;
			addChild(zoomSprite);
			
			if(!isTutorial) {
				var button:Button = new Button(null, onZoomIn, ResList.GetArtResource("map_zoom_in"));
				button.y = 7;
				zoomSprite.addChild(button);
				
				button = new Button(null, onZoomOut, ResList.GetArtResource("map_zoom_out"));
				button.y = button.height + 1;
				zoomSprite.addChild(button);
			}
			
			if(!isTutorial) {
				if(G.localServer && G.lagsEnabled) {
					connection.addMessageHandler("*", MessageReceived2);
				}
				else {
					connection.addMessageHandler(MessageID.SET_PLAYER_ACTIVE, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_POST_TURN_UPDATE, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_REGION_CONQUERED, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_FIRST_REGION_CONQUERED, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_ATTACK_RESULT, MessageReceived);
					connection.addMessageHandler(MessageID.PLAYER_LEFT, MessageReceived);
					connection.addMessageHandler(MessageID.MESSAGE_RECEIVED, MessageReceived);
					connection.addMessageHandler(MessageID.LOBBY_TOO_MANY_MESSAGES, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_OVER, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_OVER_ALL, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_PLAYER_SURRENDERED, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_IDLE_WARNING, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_IDLE_KICK, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_PLAYER_KICKED, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_START_MANUAL_DISTRIBUTION, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_END_MANUAL_DISTRIBUTION, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_POST_DISTRIBUTION_UPDATE, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_ENABLE_TIE, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_TIE_OFFERED, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_TIE_ANSWER, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_TIE_TIMEOUT, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_BOOST_ATTACK_ACTIVATE, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_BOOST_DEFENSE, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_KICKED, MessageReceived);
					connection.addMessageHandler(MessageID.GAME_PLAYER_MOD_KICKED, MessageReceived);
					connection.addMessageHandler(MessageID.MOD_COMMAND_FAILED, MessageReceived);
					connection.addMessageHandler(MessageID.MOD_COMMAND_SUCCESS, MessageReceived);
					connection.addMessageHandler(MessageID.ACHIEVEMENT_UNLOCKED, G.user.achievementUnlocked);
					
					if(G.host == G.HOST_PLAYSMART) {
						connection.addMessageHandler(MessageID.PLAYSMART_ERROR, playSmartError);
					}
					
					connection.addDisconnectHandler(handleDisconnect);
				}
			}
		}
		
		private function updateZoomLevel():void {
			var scaleValue:Number = 1;
			switch(zoomLevel) {
				case 0: scaleValue = 1; break;
				case 1: scaleValue = 0.75; break;
				case 2: scaleValue = 0.5; break;
				case 3: scaleValue = 0.25; break;
			}
			
			mapSprite.scaleX = mapSprite.scaleY = scaleValue;
			map.setMapScale(scaleValue);
		}
		
		private function onZoomIn(button:Button):void {
			zoomLevel--;
			if(zoomLevel < 0) zoomLevel = 0;
			
			updateZoomLevel();
		}
		
		private function onZoomOut(button:Button):void {
			zoomLevel++;			
			if(zoomLevel > 3) zoomLevel = 3;
			
			updateZoomLevel();
		}
		
		public function setWidePanel(wide:Boolean):void {
			isSidePanelWide = wide;
			
			fightScreen.x = wide ? 40 : 108;
			if(chatPanel)
				chatPanel.x = wide ? 249 : 354;
			
			if(wide) {
				var mapMask:Sprite = Sprite(map.mask);
				mapMask.graphics.clear();
				mapMask.graphics.beginFill(0);
				mapMask.graphics.drawRect(5, 5, 550, 590);
				map.mask = mapMask;
				addChild(mapMask);
				
				zoomSprite.x = 515;
			}
			else {
				mapMask = Sprite(map.mask);
				mapMask.graphics.clear();
				mapMask.graphics.beginFill(0);
				mapMask.graphics.drawRect(5, 5, 655, 590);
				map.mask = mapMask;
				addChild(mapMask);
				
				zoomSprite.x = 620;
			}
			
			if(ingameMessage) {
				if(wide)
					ingameMessage.x = 5 + 550 / 2 - ingameMessage.width / 2;
				else 
					ingameMessage.x = 5 + 655 / 2 - ingameMessage.width / 2;
			}
			if(newTurnPanel) {
				if(wide) 
					newTurnPanel.x = 5 + 550 / 2 - newTurnPanel.width / 2;
				else
					newTurnPanel.x = 5 + 655 / 2 - newTurnPanel.width / 2;
			}
		}
		
		private function onSurrender():void {
			if(roundCounter < 4 && !G.user.isGuest) {
				ErrorManager.errorSprite.addChild(new ConfirmationDialog("Are you sure you want to surrender? If you leave before 3rd turn, you will lose 30 xp", "SURRENDER", onSurrenderConfirmed, "CANCEL", null));	
			}
			else {
				ErrorManager.errorSprite.addChild(new ConfirmationDialog("Are you sure you want to surrender?", "SURRENDER", onSurrenderConfirmed, "CANCEL", null));
			}
		}
		
		private function onSurrenderConfirmed():void {
			connection.send(MessageID.GAME_SURRENDER);
			offerDrawButton.visible = false;
			if(G.host == G.HOST_PLAYSMART) {
				quit.visible = false;
			}
			else {
				quit.setCallback(onQuit);
				quit.setText("QUIT");
			}
		}
		
		private function onQuit():void {
			ErrorManager.errorSprite.addChild(new ConfirmationDialog("Are you sure you want to exit the game?", "QUIT", onQuitConfirmed, "CANCEL", null));
		}
		
		private function onQuitConfirmed():void {
			exitGame();
		}
		
		private function clearConnection():void {
			connection.removeMessageHandler(MessageID.SET_PLAYER_ACTIVE, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_POST_TURN_UPDATE, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_REGION_CONQUERED, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_FIRST_REGION_CONQUERED, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_ATTACK_RESULT, MessageReceived);
			connection.removeMessageHandler(MessageID.PLAYER_LEFT, MessageReceived);
			connection.removeMessageHandler(MessageID.MESSAGE_RECEIVED, MessageReceived);
			connection.removeMessageHandler(MessageID.LOBBY_TOO_MANY_MESSAGES, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_OVER, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_OVER_ALL, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_PLAYER_SURRENDERED, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_IDLE_WARNING, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_IDLE_KICK, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_PLAYER_KICKED, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_START_MANUAL_DISTRIBUTION, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_END_MANUAL_DISTRIBUTION, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_POST_DISTRIBUTION_UPDATE, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_ENABLE_TIE, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_TIE_OFFERED, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_TIE_ANSWER, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_TIE_TIMEOUT, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_BOOST_ATTACK_ACTIVATE, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_BOOST_DEFENSE, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_KICKED, MessageReceived);
			connection.removeMessageHandler(MessageID.GAME_PLAYER_MOD_KICKED, MessageReceived);
			connection.removeMessageHandler(MessageID.MOD_COMMAND_FAILED, MessageReceived);
			connection.removeMessageHandler(MessageID.MOD_COMMAND_SUCCESS, MessageReceived);
			connection.removeMessageHandler(MessageID.ACHIEVEMENT_UNLOCKED, G.user.achievementUnlocked);
			
			connection.removeDisconnectHandler(handleDisconnect);
		}
		
		public function exitGame():void {
			removeEventListener(Event.ENTER_FRAME, Update);
			
			if(connection) {
				connection.disconnect();
				clearConnection();
			}

			if(parent) {
				parent.addChild(new Lobby());
				parent.removeChild(this);
			}
		}
		
		protected function onEndTurn():void {
			if(fightScreen.fightInProgress) {
				endTurnInQueue = true;
			}
			else {
				connection.send(MessageID.GAME_END_TURN);
				turnTimer.stop();
			}
		}
		
		public function LoadGameFromMessage(m:Message):void {
			var index:int = 0;
			startType = m.getInt(index++);
			gameType = m.getInt(index++);
			troopsDist = m.getInt(index++);
			upgradesEnabled = m.getBoolean(index++);
			boostsEnabled = m.getBoolean(index++);
			
			switch(gameType) {
				case 0:
				case 1: 
				case 3:
					fightScreen = new SingleThrowFightScreen();
					break;
				case 2: 
					fightScreen = new OneOnOneFightScreen();
					break;
			}
			
			var playerCount:int = m.getInt(index++);
			var tmpPlayers:Array = new Array();
			for(i = 0; i < playerCount; ++i) {
				var pindex:int = m.getInt(index); 
				players[pindex] = new Player(m.getInt(index++), m.getString(index++), m.getInt(index++), m.getInt(index++), m.getInt(index++), m.getInt(index++), m.getInt(index++), m.getInt(index++), m.getInt(index++), m.getInt(index++), m.getString(index++), m.getInt(index++));
				if(players[pindex].ID == G.user.ID) {
					G.user.colorID = players[pindex].colorID;
				}
			}

			var width:int = m.getInt(index++);
			var height:int = m.getInt(index++);
			var tiles:Array = new Array();
			var b:ByteArray = m.getByteArray(index++);
			
			for(var i:int = 0; i < width*height; ++i) {
				tiles[i] = b.readUnsignedByte(); 
			}
			
			map = new Map(width, height, tiles);
			mapSprite.addChild(map);
			
			var mapMask:Sprite = new Sprite();
			mapMask.graphics.beginFill(0);
			mapMask.graphics.drawRect(5, 5, 540, 590);
			map.mask = mapMask;
			addChild(mapMask);
			
			var regionCount:int = m.getInt(index++);
			supposedRegionCount = regionCount;
			for(i = 0; i < regionCount; ++i) {
				map.AddRegion(players[m.getInt(index++)], m.getInt(index++));
			}
			map.Finalize(G.user.background);
			map.setMapScale(1);
			
			addChild(fightScreen);
			
			sidePanel.setGameType(troopsDist, gameType);
			sidePanel.AddPlayers(players);
			
			G.gatracker.trackPageview("/game/startNormal");
		}
		
		public function LoadSpectGameFromMessage(m:Message):void {
			G.user.colorID = -1;
			G.user.ID = -1;
			
			var index:int = 0;
			var gameID:int = m.getInt(index++);
			var gameName:String = m.getString(index++);
			gameType = m.getInt(index++);
			var mapGroup:int = m.getInt(index++);
			var mapIndex:int = m.getInt(index++);
			var userMap:String = m.getString(index++);
			startType = m.getInt(index++);
			troopsDist = m.getInt(index++);
			upgradesEnabled = m.getBoolean(index++);
			boostsEnabled = m.getBoolean(index++);
			var originalPlayers:int = m.getInt(index++);
			
			var playerCount:int = m.getInt(index++);
			var tmpPlayers:Array = new Array();
			for(i = 0; i < playerCount; ++i) {
				var colorID:int = m.getInt(index++);
				var playerID:int = m.getInt(index++);
				var username:String = m.getString(index++);
				var level:int = m.getInt(index++);
				var premoum:Boolean = m.getBoolean(index++);
				var race:int = m.getInt(index++);
				var attackBoosts:int = m.getInt(index++);
				var defenseBoosts:int = m.getInt(index++);
				var freeAttackBoosts:int = m.getInt(index++);
				var freeDefenseBoosts:int = m.getInt(index++);
				var strength:int = m.getInt(index++);
				var stackedDice:int = m.getInt(index++);
				var playerKey:String = m.getString(index++);
				var playerRating:int = m.getInt(index++);
				
				var p:Player = new Player(playerID, username, colorID, strength, race, level, attackBoosts, defenseBoosts, freeAttackBoosts, freeDefenseBoosts, playerKey, playerRating);
				p.stackedDice = stackedDice;
				players[playerID] = p;
			}

			var activePlayerId:int = m.getInt(index++);
			var turnStage:int = m.getInt(index++);
			var ticksRemaining:int = m.getInt(index++);			
			
			switch(gameType) {
				case 0:
				case 1: 
				case 3:
					fightScreen = new SingleThrowFightScreen();
					break;
				case 2: 
					fightScreen = new OneOnOneFightScreen();
					break;
			}
			
			var width:int = m.getInt(index++);
			var height:int = m.getInt(index++);
			var tiles:Array = new Array();
			var b:ByteArray = m.getByteArray(index++);
			
			for(var i:int = 0; i < width*height; ++i) {
				tiles[i] = b.readUnsignedByte(); 
			}
			
			map = new Map(width, height, tiles);
			mapSprite.addChild(map);
			
			var mapMask:Sprite = new Sprite();
			mapMask.graphics.beginFill(0);
			mapMask.graphics.drawRect(5, 5, 540, 590);
			map.mask = mapMask;
			addChild(mapMask);
			
			var regionCount:int = m.getInt(index++);
			supposedRegionCount = regionCount;
			for(i = 0; i < regionCount; ++i) {
				map.AddRegion(players[m.getInt(index++)], m.getInt(index++));
			}
			map.Finalize(G.user.background);
			map.setMapScale(1);
			
			addChild(fightScreen);
			
			sidePanel.setGameType(troopsDist, gameType);
			sidePanel.AddPlayers(players);
			sidePanel.setActivePlayer(activePlayerId);
			
			turnTimer.setRemainingTime(ticksRemaining);
			turnTimer.resume();
			
			offerDrawButton.visible = false;
			quit.setCallback(onQuit);
			quit.setText("QUIT");
			
			isSpectator = true;
			
			chatPanel.addMessage(-1, "You joined the game as a spectator, you can chat with other spectators but players can't see what you type", "", false);
			
			G.gatracker.trackPageview("/game/startSpectate");
		}
		
		public function getRegionCount():int {
			return map.getRegionCount();
		}
		
		/*private function MessageReceived(m:Message):void {
			var t:Timer = new Timer(2000, 1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {realMessageReceived(m);});
			t.start();
		}*/
		
		private var messageQueue:Array = new Array();
		public function MessageReceived2(m:Message):void {
			messageQueue.push(m);
			if(messageQueue.length == 1) {
				var t:Timer = new Timer(Math.random() * 2000, 1);
				t.start();
				t.addEventListener(TimerEvent.TIMER, onMessageFire);
			}
		}
		
		private function onMessageFire(event:TimerEvent):void {
			MessageReceived(messageQueue.shift());
			
			if(messageQueue.length == 1) {
				var t:Timer = new Timer(Math.random() * 4000, 1);
				t.start();
				t.addEventListener(TimerEvent.TIMER, onMessageFire);
			}
		}
		
		public function MessageReceived(m:Message):void {
			var index:int = 0;
			var i:int = 0;
			
			switch(m.type) {
				case MessageID.SET_PLAYER_ACTIVE:
					setActivePlayer(m.getInt(0), m.getInt(1));
					startTurnUpdate(m);
					
					if(isMyTurn)
						startMyTurn();
					
					break;
				case MessageID.GAME_POST_TURN_UPDATE:
					if(queuedFights.length > 0 || fightScreen.fightInProgress) { 
						queuedPostTurnMessage = m;
					}
					else {
						handlePostTurn(m);
					}
					
					
					turnTimer.stop();
					break;
				case MessageID.GAME_REGION_CONQUERED:
					if(autodistributingUnits || fightScreen.fightInProgress) {
						queuedFights.push(m);
					}
					else {
						handleRegionConquered(m.getInt(0), m.getInt(1), m.getInt(2), m.getInt(3));
					}
					break;
				case MessageID.GAME_FIRST_REGION_CONQUERED:
					handleInitialRegionConquer(m.getInt(0), m.getInt(1), m.getInt(2));
					break;
				case MessageID.GAME_ATTACK_RESULT:
					if(autodistributingUnits || fightScreen.fightInProgress) {
						queuedFights.push(m);
					}
					else {
						handleFightResult(m);
						turnTimer.stop();
					}
					break;
				case MessageID.PLAYER_LEFT:
					chatPanel.addMessage(m.getInt(2), m.getString(1), "has left", false);
					
					var playerID:int = m.getInt(0);
					try {
						sidePanel.removePlayer(playerID);
					}
					catch(errObject:Error) {
						//G.client.errorLog.writeError("Game::PLAYER_LEFT - sidePanel.removePlayer", "playerID: " + playerID, "", null);	
					}
					try {
						map.RemovePlayer(playerID);
					}
					catch(errObject:Error) {
						G.client.errorLog.writeError("Game::PLAYER_LEFT - map.RemovePlayer", "playerID: " + playerID, "", null);	
					}
					break;
				case MessageID.MESSAGE_RECEIVED:
					chatPanel.addMessage(m.getInt(4), m.getString(0), m.getString(1), m.getBoolean(3));
					break;
				case MessageID.GAME_OVER:
					if(gameOverScreen == null) {
						if(G.host == G.HOST_PLAYSMART) {
							gameOverScreen = new PSGameOverScreen(isSidePanelWide);
						}
						else {
							gameOverScreen = new GameOverScreen(mapGroup == 101 ? mapId : "", isSidePanelWide, m.getInt(0), m.getInt(1), m.getInt(2), m.getInt(3), m.getInt(4), m.getInt(5), m.getInt(6));
						}
						
						if(!fightScreen.fightInProgress) {
							addChild(gameOverScreen);
							gameOverScreen.playGameOverSound();
						}
					}
					isPlaying = false;
					turnTimer.stop();
					
					if(G.host == G.HOST_PLAYSMART) {
						quit.visible = false;
					}
					else {
						quit.setCallback(onQuit);
						quit.setText("QUIT");
					}
					
					break;
				case MessageID.GAME_OVER_ALL:
					if(gameOverScreen) {
						gameOverScreen.removeContinueButton();
					}
					else {
						if(G.host == G.HOST_PLAYSMART) {
							gameOverScreen = new PSGameOverScreen(isSidePanelWide);
						}
						else {
							gameOverScreen = new GameOverScreen(gameId, isSidePanelWide);
						}
						if(!fightScreen.fightInProgress) {
							addChild(gameOverScreen);
						}
					}
					turnTimer.stop();
					break;
				case MessageID.GAME_PLAYER_SURRENDERED:
					chatPanel.addMessage(m.getInt(2), m.getString(1), "surrendered", false);
					
					playerID = m.getInt(0);
					sidePanel.setArmySize(playerID, 0);
					sidePanel.setRegionSize(playerID, 0);
					sidePanel.setOfferedDraw(playerID, false);
					map.RemovePlayer(playerID);
					break;
				case MessageID.GAME_IDLE_WARNING:
					ErrorManager.showCustomError2("You have been idle for 2 turns, you will be kicked on next turn unless you start playing.", "Warning", ErrorManager.WARNING_IDLE);
					break;
				case MessageID.GAME_IDLE_KICK:
					ErrorManager.showCustomError2("You have been kicked because you have been inactive for 3 turns.", "Warning", ErrorManager.WARNING_IDLE_KICKED);
					break;
				case MessageID.GAME_PLAYER_KICKED:
					chatPanel.addMessage(m.getInt(2), m.getString(1), "was kicked for being idle", false);
					break;
				case MessageID.LOBBY_TOO_MANY_MESSAGES:
					chatPanel.addMessage(-1, "Slow down a bit please, you don't want to look like a spammer, do you?", "", false);
					break;
				case MessageID.GAME_START_MANUAL_DISTRIBUTION:
					startManualDistribution(m.getInt(0), m.getInt(1));
					break;
				case MessageID.GAME_END_MANUAL_DISTRIBUTION:
					endManualDistribution();
					break;
				case MessageID.GAME_POST_DISTRIBUTION_UPDATE:
					handlePostDistributionUpdate(m);
					break;
				case MessageID.GAME_ENABLE_TIE:
					if(isPlaying && !isSpectator)
						offerDrawButton.visible = true;
					break;
				case MessageID.GAME_TIE_OFFERED:
					tieOffered(m);
					break;
				case MessageID.GAME_BOOST_ATTACK_ACTIVATE:
					sidePanel.setAttackBoostActive(m.getInt(0), m.getBoolean(1));
					break;
				case MessageID.GAME_BOOST_DEFENSE:
					handleDefenseBoostPlaced(m);
					break;
				case MessageID.GAME_KICKED:
					exitGame();
					ErrorManager.showCustomError2("You have been kicked by mod '" + m.getString(1) + "' for following reason: " + m.getString(0), "KICKED", 0);
					break;
				case MessageID.MOD_COMMAND_FAILED:
					chatPanel.addMessage(-1, m.getString(0), "", false);
					break;
				case MessageID.MOD_COMMAND_SUCCESS:
					chatPanel.addMessage(-1, m.getString(0), "", false);
					break;
				case MessageID.GAME_PLAYER_KICKED:
					chatPanel.addMessage(-1, m.getString(0) + " has been kicked by " + m.getString(2) + " for following reason: " + m.getString(1), "", false);
					break;
			}
		}
		
		protected function setActivePlayer(playerID:int, round:int):void {
			try {
				activePlayer = players[playerID];
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("set player active: 0", errObject.message, "", null);
			}
			if(activePlayer == null) {
				G.client.errorLog.writeError("SET_PLAYER_ACTIVE: activePlayer == null", playerID + " players.count: " + players.count, "", null);
			}
			try {
				sidePanel.setActivePlayer(activePlayer.ID);
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("set player active: 1", errObject.message + " playerID: " + activePlayer.ID, "", null);
			}
			
			try {
				isMyTurn = playerID == G.user.ID;
				turnTimer.setEndTurnButtonVisible(isMyTurn)
				turnTimer.setIsMyTurn(isMyTurn);
				turnTimer.reset();
				
				roundCounter = round;
				
				if(ingameMessage) {
					removeChild(ingameMessage);
					ingameMessage = null;
				}
				
				if(newTurnPanel) 
					removeChild(newTurnPanel);
				
				newTurnPanel = new NewTurnPanel(isMyTurn ? null : activePlayer);
				if(isSidePanelWide)
					newTurnPanel.x = 5 + 550 / 2 - newTurnPanel.width / 2;
				else 
					newTurnPanel.x = 5 + 655 / 2 - newTurnPanel.width / 2;
				addChild(newTurnPanel);
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("set player active: 2", errObject.message, "", null);
			}
			
			try {
				map.finishDistribution();
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("finishDistribution", errObject.message, "", null);
			}
		}
		
		protected function startMyTurn():void {
			var regions:Array = map.getPlayersRegions(activePlayer);
			for each(var r:Region in regions) {
				r.startSinglePulse();
			}
			
			if(startType == 1 && shouldShowIntroMessage) {
				if(ingameMessage) {
					removeChild(ingameMessage);
				}
				ingameMessage = new IngameInfoMessage("Choose your starting region"); 
				if(isSidePanelWide)
					ingameMessage.x = 5 + 550 / 2 - ingameMessage.width / 2;
				else 
					ingameMessage.x = 5 + 655 / 2 - ingameMessage.width / 2;
				addChild(ingameMessage);
			}
			G.sounds.playSound("start_turn_me");
			
			checkForAdditionalMoves();
		}
		
		protected function startTurnUpdate(m:Message):void {
			var index:int = 2;
			var regionCount:int = m.getInt(index++);
			for(var i:int = 1; i < regionCount; ++i) {
				var r:Region = map.GetRegion(i);
				if(r) {
					r.setOwner(players[m.getInt(index++)]);
					r.setDice(m.getInt(index++));
				}
				else {
					G.client.errorLog.writeError("set player active: r is null", "regionID: " + i + " regionCount: " + regionCount, "", null);
				}
			}
			
			map.redraw();
		}
		
		private function handleDefenseBoostPlaced(m:Message):void {
			sidePanel.setDefenseBoostsCount(m.getInt(0), m.getInt(1), m.getInt(2));
			
			var region:Region = map.GetRegion(m.getInt(3));
			if(region) {
				region.setDefenseBoost(true);
			}
			
			defenceBoostActivated = false;
		}
		
		private function tieAnswered(m:Message):void {
			chatPanel.addMessage(m.getInt(0), m.getString(1), m.getBoolean(2) ? "has accepted draw offer" : "has declined draw offer", false);
			if(m.getBoolean(2) == false) {
				if(tieDialog) {
					removeChild(tieDialog);
					tieDialog = null;
				}
			}
		}
		
		private function tieOffered(m:Message):void {
			sidePanel.setOfferedDraw(m.getInt(0), m.getBoolean(1));
			
			if(G.user.ID == m.getInt(0))
				offerDrawButton.setText(m.getBoolean(1) ? "CANCEL DRAW" : "OFFER DRAW");
			
			/*chatPanel.addMessage(m.getInt(0), m.getString(1), "has offered draw");
			
			tieDialog = new ConfirmationDialog("Do you accept draw?", "YES", function():void {
					connection.send(MessageID.GAME_TIE_ANSWER, true); 
					tieDialog = null;
				}, "NO", function():void {
					connection.send(MessageID.GAME_TIE_ANSWER, false);
					tieDialog = null;
				}); 
			addChild(tieDialog); 
			tieDialog.dialogSprite.x = 800 - tieDialog.dialogSprite.width;
			tieDialog.dialogSprite.y = 600 - tieDialog.dialogSprite.height;*/
		}
		
		private function offerTie():void {
			connection.send(MessageID.GAME_TIE_OFFERED);
		}
		
		protected function startManualDistribution(stackedDice:int, delay:int):void {
			if(isMyTurn) {
				activePlayer.stackedDice = stackedDice;
				manualDistribution = true;
				if(ingameMessage) {
					removeChild(ingameMessage);
				}
				ingameMessage = new IngameInfoMessage("Distribute new units");
				if(isSidePanelWide)
					ingameMessage.x = 5 + 550 / 2 - ingameMessage.width / 2;
				else 
					ingameMessage.x = 5 + 655 / 2 - ingameMessage.width / 2;
				addChild(ingameMessage);
				
				newTroopsRegions.length = 0;
				
				if(activePlayer.stackedDice <= 0 || map.getNonFullRegionCount(activePlayer) == 0) {
					endManualDistribution();
				}
			}
			turnTimer.reset(delay);
			map.deselectAllRegions();
			turnTimer.setEndTurnButtonVisible(false);
		}
		
		protected function endManualDistribution():void {
			turnTimer.stop();
			
			var b:ByteArray = new ByteArray();
			for(var i:int = 0; i < newTroopsRegions.length; i++) {
				b.writeByte(newTroopsRegions[i]);
			}
			connection.send(MessageID.GAME_DISTRIBUTION_RESULTS, b);
			newTroopsRegions.length = 0;
			manualDistribution = false;
			isMyTurn = false;
		}
		
		private function handlePostDistributionUpdate(m:Message):void {
			var index:int = 0;
			var count:int = m.getInt(index++);
			try {
				for(var i:int = 0; i < count; ++i) {
					var regionID:int = m.getInt(index++);
					var r:Region = map.GetRegion(regionID);
					if(r) {
						var oldDice:int = r.dice;
						r.dice = m.getInt(index++);
						if(r.dice != oldDice)
							r.updateArmySize();
					}
					else {
						G.client.errorLog.writeError("Game::handlePostDistributionUpdate - region is null", "regionID: " + regionID, "", null);
					}
				}
			}
			catch(err:EOFError) {
				G.client.errorLog.writeError("Game::handlePostDistributionUpdate - eof 1", m.length + "", "", null);	
			}
		}
		
		protected function handleFightResult(m:Message):void {
			try {
				
			var index:int = 0;
			
			var sourceRegion:Region = map.GetRegion(m.getInt(index++));
			var targetRegion:Region = map.GetRegion(m.getInt(index++));
			
			var attackBoost:Boolean = m.getBoolean(index++);
			var defenseBoost:Boolean = m.getBoolean(index++);
			
			var throwCount:int = m.getInt(index++);
			var battlesCount:int = m.getInt(index++);
			var throws:Array = new Array();
			for(var i:int = 0; i < throwCount + (battlesCount - 1) * 2; ++i) {
				throws.push(m.getInt(index++));
			}
			//if(sourceRegion.owner == null) {
				//connection.send(MessageID.GAME_DUMP_MAP);
				//G.client.errorLog.writeError("source is null", G.roomID + " - " + sourceRegion.ID + " vs " + targetRegion.ID + " mapGroup: " + mapGroup + " mapIndex: " + mapIndex, "", null);
			//}
			fightScreen.startFight(sourceRegion, targetRegion, throws, attackBoost, defenseBoost, battlesCount);
			bufferedFightResults = new Array(sourceRegion.ID, m.getInt(index++), // new dice count for source 
											 targetRegion.ID, m.getInt(index++), // and target regions
											 m.getInt(index++), m.getInt(index++), // attacker ID and new strength 
											 m.getInt(index++), m.getInt(index++), // defender ID and new strength 
											 m.getInt(index++), 					// fight result (1 - win, 0 - loss)
											 m.getInt(index++),  m.getInt(index++), m.getBoolean(index++));	// remaining attack boosts of attacker

			if(sourceRegion.owner && sourceRegion.owner.ID != G.user.ID) {
				// move map and highlight regions if we are not attacker
				sourceRegion.SetActive(true);
				targetRegion.SetActive(true);
			}
			
			}
			catch(err:Error) {
				G.client.errorLog.writeError("Game::HandleFightResult", "", "", null);
			}
		}
		
		public function fightFinished():void {
			// update source dice
			var sourceRegion:Region = map.GetRegion(bufferedFightResults[0]);
			sourceRegion.setDice(bufferedFightResults[1]);
			
			// target dice
			var targetRegion:Region = map.GetRegion(bufferedFightResults[2]);
			targetRegion.setDice(bufferedFightResults[3]);
			targetRegion.setDefenseBoost(bufferedFightResults[11]);
			
			// update attacker strength
			sidePanel.setRegionSize(bufferedFightResults[4], bufferedFightResults[5]);
			sidePanel.setAttackBoostsCount(bufferedFightResults[4], bufferedFightResults[9], bufferedFightResults[10]);
			sidePanel.setAttackBoostActive(bufferedFightResults[4], false);
			
			// update defender strength
			if(bufferedFightResults[6] != -1) {
				sidePanel.setRegionSize(bufferedFightResults[6], bufferedFightResults[7]);
				if(bufferedFightResults[7] == 0) {
					sidePanel.setOfferedDraw(bufferedFightResults[6], false);
				}
			}
			if(bufferedFightResults[8] == 1) {
				targetRegion.setOwner(sourceRegion.owner);
				targetRegion.redraw();
				map.UpdateBorders(targetRegion);
				if(G.host == G.HOST_KONGREGATE) {
					if(sourceRegion.owner && sourceRegion.owner.ID == G.user.ID) {
						G.kongregate.stats.submit("RegionsConquered", 1);
					}
				}
			}
			
			if(gameOverScreen) {
				addChild(gameOverScreen);
				gameOverScreen.playGameOverSound();
				offerDrawButton.visible = false;
			}
			else {
				if(endTurnInQueue) {
					onEndTurn();
				}
				else {
					turnTimer.addTime(5);
					turnTimer.resume();
				}
				endTurnInQueue = false;
			}
			
			sourceRegion.SetActive(false);
			// if we won, dont deselect target region
			if(sourceRegion.owner != targetRegion.owner || targetRegion.dice == 1 || sourceRegion.owner.ID != G.user.ID) {
				targetRegion.SetActive(false);
			}
			else {
				selectedRegion = targetRegion;
				targetRegion.SetActive(true);
				targetRegion.startHighlightingAttackableRegions();
			}
			
			checkForAdditionalMoves();
			
			if(queuedFights.length > 0) {
				var message:Message = queuedFights.shift();
				if(message.type == MessageID.GAME_ATTACK_RESULT) {
					handleFightResult(message);
				}
				else if(message.type == MessageID.GAME_REGION_CONQUERED) {
					handleRegionConquered(message.getInt(0), message.getInt(1), message.getInt(2), message.getInt(3));
				}
			}
			else if(queuedPostTurnMessage) {
				handlePostTurn(queuedPostTurnMessage);
				queuedPostTurnMessage = null;
			}
		}
		
		protected function handlePostTurn(m:Message):void {
			try {
				
			var index:int = 0;
			activePlayer.stackedDice = m.getInt(index++);
			var count:int = m.getInt(index++);
			var newDice:int = 0;
			try {
				for(var i:int = 0; i < count; ++i) {
					newDice += map.UpdateRegionDice(m.getInt(index++), m.getInt(index++));
				}
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("Game::handlePostTurn - dice distribution", "mapGroup: " + mapGroup + " mapIndex: " + mapIndex, "", null);
			}
			
			if(isMyTurn) {
				turnCounter++;
			}
			
			isMyTurn = false;
			map.deselectAllRegions();
			turnTimer.setEndTurnButtonVisible(false);
			
			autodistributingUnits = true;
			if(newDice == 0) {
				onDistributionCompleted(null);
			}
			else {
				var t:Timer = new Timer(newDice * 250, 1);
				t.addEventListener(TimerEvent.TIMER, onDistributionCompleted);
				t.start();
			}
			
			}
			catch(err:Error) {
				G.client.errorLog.writeError("Game::handlePostTurn - global", "mapGroup: " + mapGroup + " mapIndex: " + mapIndex, "", null);
			}
		}
		
		protected function onDistributionCompleted(event:TimerEvent):void {
			try {
			
			autodistributingUnits = false;
			if(queuedFights.length > 0) {
				var message:Message = queuedFights.shift();
				if(message.type == MessageID.GAME_ATTACK_RESULT) {
					try {
						handleFightResult(message);
					}
					catch(errObject:Error) {
						G.client.errorLog.writeError("Game::onDistributionCompleted - HandleFightResult", "", "", null);
					}
				}
				else if(message.type == MessageID.GAME_REGION_CONQUERED) {
					try {
						handleRegionConquered(message.getInt(0), message.getInt(1), message.getInt(2), message.getInt(3));
					}
					catch(errObject:Error) {
						G.client.errorLog.writeError("Game::onDistributionCompleted - handleRegionConquered", "", "", null);
					}
				}
			}
			
			}
			catch(err:Error) {
				G.client.errorLog.writeError("Game::onDistributionComplete - global", "", "", null);
			}
		}
		
		protected function handleInitialRegionConquer(playerID:int, regionID:int, dice:int):void {
			try {
				
			var player:Player = players[playerID];
			var region:Region = map.GetRegion(regionID);
			if(player == null) {
				G.client.errorLog.writeError("Game::handleInitialRegionConquer - player is null", "playerID: " + playerID, "", null);
			}
			if(region) {
				region.setOwner(player);
				region.setDice(dice);
				region.redraw();
				map.UpdateBorders(region);
			}
			else {
				G.client.errorLog.writeError("Game::handleInitialRegionConquer - region is null", "regionID: " + regionID + " --- " + map.dumpRegionsToString(), "", null);
			}
			
			player.strength = 1;
			sidePanel.setRegionSize(playerID, player.strength);
				
			if(playerID == G.user.ID) {
				shouldShowIntroMessage = false;
				
			}
			checkForAdditionalMoves();
			
			}
			catch(err:Error) {
				G.client.errorLog.writeError("Game::handleInitialRegionConquer - global", "", "", null);
			}
		}
		
		protected function handleRegionConquered(sourceID:int, targetID:int, targetDice:int, strength:int):void {
			try {
				
			var sourceRegion:Region = map.GetRegion(sourceID);
			if(sourceRegion) {
				sourceRegion.setDice(1);
			}
			else {
				G.client.errorLog.writeError("Game::handleRegionConquered - sourceRegion is null", "regionID: " + sourceID, "", null);
			}
			// target dice
			var targetRegion:Region = map.GetRegion(targetID);
			if(targetRegion) {
				targetRegion.setDice(targetDice);
				targetRegion.setOwner(sourceRegion.owner);
				targetRegion.redraw();
				map.UpdateBorders(targetRegion);
			}
			else {
				G.client.errorLog.writeError("Game::handleRegionConquered - targetRegion is null", "regionID: " + targetID, "", null);
			}

			if(sourceRegion.owner)
				sidePanel.setRegionSize(sourceRegion.owner.ID, strength);				
		
			turnTimer.addTime(5);
				
			sourceRegion.SetActive(false);
			// if we won, dont deselect target region
			if(sourceRegion.owner != targetRegion.owner || targetRegion.dice == 1 || sourceRegion.owner.ID != G.user.ID) {
				targetRegion.SetActive(false);
			}
			else {
				selectedRegion = targetRegion;
				targetRegion.SetActive(true);
				targetRegion.startHighlightingAttackableRegions();
			}
				
			checkForAdditionalMoves();
			
			if(queuedFights.length > 0) {
				var message:Message = queuedFights.shift();
				if(message.type == MessageID.GAME_ATTACK_RESULT) {
					handleFightResult(message);
				}
				else if(message.type == MessageID.GAME_REGION_CONQUERED) {
					handleRegionConquered(message.getInt(0), message.getInt(1), message.getInt(2), message.getInt(3));
				}
			}
			else if(queuedPostTurnMessage) {
				handlePostTurn(queuedPostTurnMessage);
				queuedPostTurnMessage = null;
			}
			
			}
			catch(err:Error) {
				G.client.errorLog.writeError("Game::handleRegionConquered - global", "mapGroup: " + mapGroup + " mapIndex: " + mapIndex, "", null);
			}
		}
		
		private function checkForAdditionalMoves():void {
			if(isMyTurn && !map.moreMovesPossible(activePlayer) && activePlayer.strength > 0) {
				turnTimer.startButtonHighlight();
			}
		}
		
		public function removeGameOverScreen():void {
			removeChild(gameOverScreen);
			gameOverScreen = null;
		}
		
		private var lastMouseDownX:int, lastMouseDownY:int;
		private var moved:Boolean;
		private var validMapMove:Boolean;
		
		private function Update(event:Event):void	{
			prevTimeDelta = timeDelta;
			var time:Number = (new Date).getTime();
			timeDelta = (5*prevTimeDelta + (time - oldTime)/1000)/6;
			oldTime = time;
			gameTime = (time - startTime) / 1000;
			if (timeDelta > 0.1)
				timeDelta = 0.1;
			
			fightScreen.Update(timeDelta);
	
			var mapMouseX:int;
			var mapMouseY:int;
			switch(zoomLevel) {
				case 0: mapMouseX = Input.mouseX; 
					mapMouseY = Input.mouseY;
					break;
				case 1: mapMouseX = Input.mouseX * 4 / 3;
					mapMouseY = Input.mouseY * 4 / 3;
					break;
				case 2: mapMouseX = Input.mouseX * 2;
					mapMouseY = Input.mouseY * 2;
					break;
				case 3: mapMouseX = Input.mouseX * 4;
					mapMouseY = Input.mouseY * 4;
					break;
			}
			
			if(Input.IsMouseReleased()) {
				validMapMove = false;
			}
			
			if(stage && stage.focus == null && Input.mouseLeft == Input.JUSTPRESSED && !Input.mouseHandled) {
				var maxX:int = isSidePanelWide ? 550 : 655;
				if(Input.mouseX > 5 && Input.mouseX < maxX && Input.mouseY > 5 && Input.mouseY < 590) {
					lastMouseDownX = mapMouseX;
					lastMouseDownY = mapMouseY;
					
					moved = false;
					validMapMove = true;
				}
				else {
					validMapMove = false;
				}
			}
			
			if(stage && stage.focus == null && (Input.mouseLeft == Input.PRESSED || Input.mouseLeft == Input.JUSTRELEASED) && !Input.mouseHandled && validMapMove) {
				if(Math.abs(lastMouseDownX - mapMouseX) > 2 || Math.abs(lastMouseDownY - mapMouseY) > 2) {
					map.Move(mapMouseX - lastMouseDownX, mapMouseY - lastMouseDownY);
					
					lastMouseDownX = mapMouseX;
					lastMouseDownY = mapMouseY;
					
					moved = true;
					
				}
			}
			
			var hoverRegion:Region = map.GetRegionUnderCursor(mapMouseX, mapMouseY);
			
			if(isMyTurn && hoverRegion != null && hoverRegion.owner == activePlayer) {
				hoverRegion.startHover();
			}
			
			if(isMyTurn && Input.mouseLeft == Input.JUSTRELEASED && !moved && !fightScreen.fightInProgress && !Input.mouseHandled) {
				regionClicked(hoverRegion);
			}
			
			if(stage.focus == null) {
				if(Input.IsKeyJustPressed(Input.KEY_D)) {
					defenseBoostPressed();
				}
				if(Input.IsKeyJustPressed(Input.KEY_A)) {
					attackBoostPressed();
				}
			}
			
			//if(Input.IsKeyJustPressed(Input.KEY_SPACE)) {
			//	onEndTurn();
			//}
			
			map.update(timeDelta);
			if(chatPanel)
				chatPanel.update(timeDelta);
			turnTimer.update(timeDelta);
			
			for each(var player:Player in players) {
				sidePanel.setArmySize(player.ID, player.stackedDice);
			}
			
			Input.Tick();
		}
		
		protected function setDefenseBoost(region:Region):void {
			connection.send(MessageID.GAME_BOOST_DEFENSE, region.ID);
		}
		
		protected function conquerFirstRegion(playerID:int, regionID:int):void {
			connection.send(MessageID.GAME_FIRST_CONQUER_REGION, playerID, regionID);
		}
		
		protected function attackRegion(sourceID:int, targetID:int):void {
			connection.send(MessageID.GAME_ATTACK, sourceID, targetID);
		}
		
		protected function regionClicked(region:Region):void {
			if(defenceBoostActivated) {
				if(region && region.owner != null && region.owner.ID == G.user.ID) {
					setDefenseBoost(region);
					defenceBoostActivated = false;
					sidePanel.setDefenseBoostActive(G.user.ID, false);
				}
			}
			else {
				if(region == null || region == selectedRegion) {
					if(selectedRegion != null) {
						selectedRegion.SetActive(false);
					}
					selectedRegion = null;
				}
				else {
					if(region.IsMyRegion()) {
						if(manualDistribution) {
							if(region.dice < 8) {
								if(Input.IsKeyPressed(Input.KEY_SHIFT)) {
									while(activePlayer.stackedDice > 0 && region.dice < 8) {
										activePlayer.stackedDice--;
										region.setDice(region.dice + 1);
										region.updateArmySize();
										newTroopsRegions.push(region.ID);
									}
								}
								else {
									activePlayer.stackedDice--;
									region.setDice(region.dice + 1);
									region.updateArmySize();
									newTroopsRegions.push(region.ID);
								}
								if(activePlayer.stackedDice <= 0 || map.getNonFullRegionCount(activePlayer) == 0) {
									endManualDistribution();
								}
								G.sounds.playSound("new_unit_placed");
							}
						}
						else {
							if(selectedRegion != null) {
								selectedRegion.SetActive(false);
							}
							selectedRegion = region;
							selectedRegion.SetActive(true);
							selectedRegion.startHighlightingAttackableRegions();
						}
					}
					else {
						// land grab initialization
						if(startType == 1 && region != null && activePlayer.strength == 0) {
							conquerFirstRegion(activePlayer.ID, region.ID);
							
						}
							// normal action
						else {
							if(selectedRegion != null) {
								if(selectedRegion.CanAttack(region)) {
									// todo: disable action until we get response
									attackRegion(selectedRegion.ID, region.ID);
									
									selectedRegion.stopHighlightingAttackableRegions();
									region.SetActive(true);
									selectedRegion = null;
								}
							}
						}
					}
				}
			}
		}

		public function handleDisconnect():void{
			//exitGame();
			removeEventListener(Event.ENTER_FRAME, Update);
			
			if(connection) {
				connection.disconnect();
				clearConnection();
			}
			
			if(G.host == G.HOST_PLAYSMART) {
				parent.addChild(new PlaySmartErrorScreen());
				parent.removeChild(this);
			}
			else if(parent) {
				parent.addChild(new Lobby());
				parent.removeChild(this);
			}
			
			ErrorManager.showCustomError("You have been disconnected from server", 10000, null);
			
			G.gatracker.trackPageview("/game/disconnect");
		}

		public function sendMessage(message:String):void {
			connection.send(MessageID.MESSAGE_SEND, message);
		}
		
		public function removeNewTurnPanel(panel:NewTurnPanel):void {
			if(newTurnPanel == panel) {
				removeChild(panel);
				newTurnPanel = null;
			}
		}
		
		public function removeInfoPanel(panel:IngameInfoMessage):void {
			if(ingameMessage == panel) {
				removeChild(panel);
				ingameMessage = null;
			}
		}
		
		public function attackBoostPressed():void {
			connection.send(MessageID.GAME_BOOST_ATTACK_ACTIVATE);
		}
		
		public function defenseBoostPressed():void {
			if(isMyTurn) {
				defenceBoostActivated = !defenceBoostActivated;
				sidePanel.setDefenseBoostActive(G.user.ID, defenceBoostActivated);
			}
		}
		
		public function playSmartError(m:Message):void {
			ErrorManager.showCustomError("Error occured while comunicating with server. Press OK to leave the game", 10010, playSmartReport);
		}
		
		public function playSmartReport():void {
			try {
				trace("reporting to playsmart");
				ExternalInterface.call("somethingWentWrong()");
				
			}
			catch(e:*) {}

			removeEventListener(Event.ENTER_FRAME, Update);
			
			if(connection) {
				connection.disconnect();
				clearConnection();
				connection = null;
			}
			
			if(parent) {
				parent.addChild(new PlaySmartErrorScreen());
				parent.removeChild(this);
			}
		}
	}
}