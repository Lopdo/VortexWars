using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace Wargrounds {
	class KickedPlayer
	{
		public String ip;
		public float timer;

		public KickedPlayer(String ip, float timer) {
			this.ip = ip;
			this.timer = timer;
		}
	}

	[RoomType("Wargrounds2.4")]
	public class GameCode : Game<Player> {
		Random rand = new Random();

        DateTime oldTickTime = new DateTime();
        DateTime oldStateTime = new DateTime();
        DateTime startTime;

		private DateTime gameStartTime;

		Map map;

		bool[] colorIDs = new bool[8];

		private Player activePlayer;
		private List<Player> ingamePlayers = new List<Player>();
		private List<Player> anihilatedPlayers = new List<Player>();
		
		private bool gameStarted = false;
		private bool gameStarting = false;
		private int activePlayerCount;

		private int roundCounter = 1;

		private GameModes.GameMode gameMode;
		
		private Timer turnTimerHandle;
		private TurnTimer turnTimer;
		private Timer startNextTurnTimer;
		private Timer lobbyCountdownTimer;
		private Timer waitingForDistResultTimer;

		private int turnStage = 0;
		private const int TURN_STAGE_ATTACK = 1;
		private const int TURN_STAGE_TROOPS_DIST_AUTO = 2;
		private const int TURN_STAGE_TROOPS_DIST_MANUAL = 3;
		private const int TURN_STAGE_WAITING_FOR_DIST = 4;

		private bool tieEnabled = false;

		private Object turnLock = new Object();
		private List<KeyValuePair<Player, Message>> messageQueue = new List<KeyValuePair<Player, Message>>();

		private GameSettings gameSettings = new GameSettings();

		private List<KickedPlayer> recentlyKicked = new List<KickedPlayer>();

		private Timer lagTimer;

		// This method is called when an instance of your the game is created
		public override void GameStarted() {
			// anything you write to the Console will show up in the 
			// output window of the development server
			Console.WriteLine("Game is started: " + RoomId);

			//rand.SetSeedFromSystemTime();

			PreloadPlayerObjects = true;

            //gameTime = 0;
            
            oldTickTime = DateTime.Now;
            oldStateTime = DateTime.Now;
            startTime = DateTime.Now;

			map = new Map();
	
			for (int i = 0; i < 8; ++i)
			{
				colorIDs[i] = false;
			}

			int gameType = Convert.ToInt32(RoomData["gameType"]);
			if (gameType < 0) gameType = 0;
			if (gameType > 3) gameType = 3;
			switch (gameType) {
				case 0: gameSettings.fightType = GameSettings.FightType.HARDCORE; break;
				case 1: gameSettings.fightType = GameSettings.FightType.ATTRITION; break;
				case 2: gameSettings.fightType = GameSettings.FightType.ONEONONE; break;
				case 3: gameSettings.fightType = GameSettings.FightType.ONEONONE_QUICK; break;
			}
			
			int troopsDist = Convert.ToInt32(RoomData["troopsDist"]);
			if (troopsDist < 0) troopsDist = 0;
			if (troopsDist > 2) troopsDist = 2;
			switch (troopsDist) {
				case 0: gameSettings.troopsDistType = GameSettings.TroopsDistributionType.RANDOM; break;
				case 1: gameSettings.troopsDistType = GameSettings.TroopsDistributionType.MANUAL; break;
				case 2: gameSettings.troopsDistType = GameSettings.TroopsDistributionType.BORDERS; break;
			}
			
			gameSettings.mapGroup = Convert.ToInt32(RoomData["mapGroup"]);
			if (gameSettings.mapGroup == 101) {
				gameSettings.mapIndex = 0;
				gameSettings.userMap = RoomData["userMap"];
			}
			else {
				gameSettings.mapIndex = Convert.ToInt32(RoomData["mapDetail"]);
			}
			if (gameSettings.mapGroup == 100)
				map.SetSize(Convert.ToInt32(RoomData["mapDetail"]));

			map.startType = Convert.ToInt32(RoomData["startType"]);
			if (map.startType < 0) map.startType = 0;
			if (map.startType > 1) map.startType = 1;
			switch (map.startType) {
				case 0: gameSettings.startType = GameSettings.StartType.FULL_MAP; break;
				case 1: gameSettings.startType = GameSettings.StartType.CONQUER; break;
			}

			gameSettings.maxPlayers = Convert.ToInt32(RoomData["maxPlayers"]);
			if (gameSettings.maxPlayers < 2) gameSettings.maxPlayers = 2;
			if (gameSettings.maxPlayers > 8) gameSettings.maxPlayers = 8;

			gameSettings.upgradesEnabled = Convert.ToInt32(RoomData["upgradesEnabled"]) == 1;
			gameSettings.boostsEnabled = Convert.ToInt32(RoomData["boostsEnabled"]) == 1;

			turnTimer = new TurnTimer();
			turnTimerHandle = AddTimer(turnTimer.tick, 1000);

			// update tick
			AddTimer(delegate {
				if (!gameStarted) {
					for (int i = recentlyKicked.Count - 1; i >= 0; i--) {
						KickedPlayer p = recentlyKicked[i];
						p.timer -= 1;

						if (p.timer < 0) {
							recentlyKicked.RemoveAt(i);
						}
					}
				}
			}, 1000);

			AddTimer(delegate {
				// This will cause the GenerateDebugImage() method to be called
				// so you can draw a grapical version of the game state.
				RefreshDebugView(); 
			}, 1000);

			RoomData["Started"] = "false";
			RoomData["Id"] = RoomId;
		}

		// This method is called when the last player leaves the room, and it's closed down.
		public override void GameClosed() {
			Console.WriteLine("RoomId: " + RoomId);
		}

		// This method is called whenever a player joins the game
		public override void UserJoined(Player player) {
			Console.WriteLine("player joining");
			//player.Init(false, PlayerIO.BigDB);
			player.errorLog = PlayerIO.ErrorLog;

			lock (turnLock) {
				player.messageTimer = AddTimer(player.messageTimerTick, 4000);

				if (gameStarted || gameStarting) {
					if (Convert.ToBoolean(player.JoinData["Spectator"])) {
						player.spectating = true;
						if (gameStarted) {
							setupInGameJoinMessage(player);
						}
						else {
							setupGameRoomJoinMessage(player);
						}
					}
					else {
						player.Send(MessageID.GAME_JOIN_FAIL_GAME_STARTED);
						player.Disconnect();
					}
				}
				else {
					setupGameRoomJoinMessage(player);
					RoomData["PlayerCount"] = ingamePlayers.Count.ToString();
					RoomData.Save();
					Console.WriteLine("PlayerCount: " + RoomData["PlayerCount"]);
				}
			}

			player.playerEnteredRoom(this.RoomId, RoomData["name"], true);
		}

		private void setupGameRoomJoinMessage(Player player) {
			bool shouldBeHost = false;
			Message upToSpeed = Message.Create(MessageID.POST_LOGIN_INFO);
			upToSpeed.Add(this.RoomId);
			upToSpeed.Add(RoomData["name"]);
			upToSpeed.Add((int)gameSettings.fightType);
			upToSpeed.Add(gameSettings.mapGroup);
			upToSpeed.Add(gameSettings.mapIndex);
			upToSpeed.Add(gameSettings.userMap);
			upToSpeed.Add((int)gameSettings.startType);
			upToSpeed.Add((int)gameSettings.troopsDistType);
			upToSpeed.Add(gameSettings.upgradesEnabled);
			upToSpeed.Add(gameSettings.boostsEnabled);
			upToSpeed.Add(gameSettings.maxPlayers);

			lock (ingamePlayers) {
				// find first free playerID
				int cid = -1;
				for (int i = 0; i < gameSettings.maxPlayers; ++i) {
					if (colorIDs[i] == false) {
						cid = i;
						colorIDs[i] = true;
						break;
					}
				}
				player.colorID = cid;
				if (cid == -1 || ingamePlayers.Count > gameSettings.maxPlayers) {
					player.Send(MessageID.GAME_JOIN_FAIL_GAME_FULL);
					player.Disconnect();

					//PlayerIO.ErrorLog.WriteError("Game is already full", "cid: " + cid + " player count: " + ingamePlayers.Count + " maxPlayers: " + gameSettings.maxPlayers, "", null);

					return;
				}

				ingamePlayers.Add(player);

				if (ingamePlayers.Count == 1) {
					shouldBeHost = true;
					player.ready = true;
					player.isHost = true;

					RoomData["Visible"] = "true";
					RoomData.Save();
				}

				upToSpeed.Add(ingamePlayers.Count);
				foreach (Player p in ingamePlayers) {
					upToSpeed.Add(p.Id);
					upToSpeed.Add(p.username);
					upToSpeed.Add(p.colorID);
					upToSpeed.Add(p.ready);
					upToSpeed.Add(p.level);
					upToSpeed.Add(!p.hidePremium && p.isPremium());
					upToSpeed.Add(p.moderator);
					upToSpeed.Add(p.race);
					upToSpeed.Add(p.isGuest ? "" : p.PlayerObject.Key);
					upToSpeed.Add((int)p.rankingNew);
				}
			}
			if (!player.spectating)
				player.Send(MessageID.PLAYER_SET_ID, player.Id);

			Broadcast(MessageID.PLAYER_JOINED, player.Id, player.username, player.colorID, player.level, !player.hidePremium && player.isPremium(), player.moderator, player.race, player.spectating, player.isGuest ? "" : player.PlayerObject.Key, (int)player.rankingNew);
			player.Send(upToSpeed);

			if (shouldBeHost) {
				player.Send(MessageID.PLAYER_SET_HOST, player.colorID);
			}
		}

		private void setupInGameJoinMessage(Player player) {
			Message upToSpeed = Message.Create(MessageID.SPECTATOR_INGAME_JOIN);
			upToSpeed.Add(this.RoomId);
			upToSpeed.Add(RoomData["name"]);
			upToSpeed.Add((int)gameSettings.fightType);
			upToSpeed.Add(gameSettings.mapGroup);
			upToSpeed.Add(gameSettings.mapIndex);
			upToSpeed.Add(gameSettings.userMap);
			upToSpeed.Add((int)gameSettings.startType);
			upToSpeed.Add((int)gameSettings.troopsDistType);
			upToSpeed.Add(gameSettings.upgradesEnabled);
			upToSpeed.Add(gameSettings.boostsEnabled);
			upToSpeed.Add(gameSettings.startPlayers);

			lock (ingamePlayers) {
				int stillPlayingCount = 0;
				foreach (Player p in ingamePlayers) {
					if (p.stillPlaying) {
						stillPlayingCount++;
					}
				}
				upToSpeed.Add(stillPlayingCount);
				foreach (Player p in ingamePlayers) {
					if (p.stillPlaying) {
						upToSpeed.Add(p.colorID);
						upToSpeed.Add(p.Id);
						upToSpeed.Add(p.username);
						//upToSpeed.Add(p.colorID);
						upToSpeed.Add(p.level);
						upToSpeed.Add(!p.hidePremium && p.isPremium());
						upToSpeed.Add(p.race);
						upToSpeed.Add(p.attackBoosts);
						upToSpeed.Add(p.defenseBoosts);
						upToSpeed.Add(p.freeAttackBoosts);
						upToSpeed.Add(p.freeDefenseBoosts);
						upToSpeed.Add(p.strength);
						upToSpeed.Add(p.stackedDice);
						upToSpeed.Add(p.isGuest ? "" : p.PlayerObject.Key);
						upToSpeed.Add(p.rankingNew);
					}
				}
			}

			upToSpeed.Add(activePlayer.Id);
			upToSpeed.Add(turnStage);
			upToSpeed.Add(turnTimer.getTicksRemaining());

			byte[] tiles = map.GetTiles();
			int count = map.GetTileCount();
			upToSpeed.Add(map.GetWidth());
			upToSpeed.Add(map.GetHeight());
			upToSpeed.Add(tiles);
			count = map.GetRegionCount();
			upToSpeed.Add(count);
			// add regions
			for (int i = 0; i < count; ++i) {
				Region r = map.GetRegion(i);
				if (r.owner != null) {
					upToSpeed.Add(r.owner.Id);
				}
				else {
					upToSpeed.Add(-1);
				}
				upToSpeed.Add(r.dice);
			}

			player.Send(upToSpeed);
		}

		// This method is called when a player leaves the game
		public override void UserLeft(Player player) {
			Console.WriteLine("user left");
			List<KeyValuePair<Player, Message>> tmpQueue;

			int stillPlayingCount = 0;
			lock (ingamePlayers) {
				if (gameStarted || gameStarting) {
					foreach (Player p in ingamePlayers) {
						if (p.stillPlaying) {
							stillPlayingCount++;
						}
					}
				}
				else {
					stillPlayingCount = ingamePlayers.Count - 1;
				}
			}
			RoomData["PlayerCount"] = stillPlayingCount.ToString();
			RoomData.Save();
			Console.WriteLine("PlayerCount: " + RoomData["PlayerCount"]);

			lock (turnLock) {
				if (player.messageTimer != null)
					player.messageTimer.Stop();

				if (gameStarted && activePlayerCount <= 1) {
					if (gameStarted && turnTimerHandle != null) {
						turnTimerHandle.Stop();
						//turnTimer = null;
					}
					if (activePlayerCount == 0) {
						Broadcast(MessageID.PLAYER_LEFT, player.Id, player.username, player.colorID);
						RoomData["Visible"] = "false";
						RoomData.Save();
						Console.WriteLine("Visible false");
						return;
					}
				}

				if (player.stillPlaying && !player.spectating) {
					player.gameAborted(map.getSize(), (int)gameSettings.fightType, map.startType, (DateTime.Now - gameStartTime).Seconds, gameSettings.startPlayers);
					surrender(player, false, false);
				}

				if (lobbyCountdownTimer != null) {
					lobbyCountdownTimer.Stop();
					lobbyCountdownTimer = null;
				}

				if (!player.spectating) {
					if (player.colorID != -1) {
						colorIDs[player.colorID] = false;
					}
					//Broadcast(MessageID.PLAYER_LEFT, player.Id, player.username, player.colorID);
					messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.PLAYER_LEFT, player.Id, player.username, player.colorID)));

					// remove user from ingame players list
					ingamePlayers.Remove(player);

					player.strength = 0;

					if (gameStarted) {
						if (player == activePlayer) {
							int nextColorID = (player.colorID + 1) % gameSettings.maxPlayers;
							bool found = false;
							while (!found) {
								foreach (Player p in Players) {
									if (p.colorID == nextColorID) {
										activePlayer = p;
										sendPlayerActive();
										found = true;
										break;
									}
								}
								nextColorID = (nextColorID + 1) % gameSettings.maxPlayers;
							}
						}
					}
					else {
						if (player.isHost) {
							// find first (with topmost color) player and make him host
							int minColor = 100;
							Player minPlayer = null;
							foreach (Player p in Players) {
								if (p.colorID < minColor && p.colorID >= 0) {
									minColor = p.colorID;
									minPlayer = p;
								}
							}
							if (minPlayer != null) {
								minPlayer.isHost = true;
								minPlayer.ready = true;
								minPlayer.Send(MessageID.PLAYER_SET_HOST, minPlayer.colorID);
								//Broadcast(MessageID.PLAYER_READY, minPlayer.colorID, true);
								messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.PLAYER_READY, minPlayer.colorID, true)));
							}
						}
					}

					player.stillPlaying = false;

					if (activePlayerCount == 1) {
						CheckTotalGameOver();
					}
				}

				tmpQueue = messageQueue;
				messageQueue = new List<KeyValuePair<Player, Message>>();
			}
			foreach (KeyValuePair<Player, Message> p in tmpQueue) {
				if (p.Key != null) {
					p.Key.Send(p.Value);
				}
				else {
					Broadcast(p.Value);
				}
			}

			player.playerLeftRoom();
		}

        override public bool AllowUserJoin(Player player) {
			if (Convert.ToBoolean(player.JoinData["Spectator"])) {
				player.Init(PlayerIO.BigDB);
			
				return base.AllowUserJoin(player);
			}

			if (gameStarted || gameStarting) {
				player.Send(MessageID.GAME_JOIN_FAIL_GAME_STARTED);
				return false;
            }
			Console.WriteLine("player count" + PlayerCount);
			if (PlayerCount >= gameSettings.maxPlayers) {
				player.Send(MessageID.GAME_JOIN_FAIL_GAME_FULL);
				return false;
			}

			// look for recently kicked players
			bool kicked = false;
			foreach (KickedPlayer p in recentlyKicked) {
				if (p.ip == player.IPAddress.ToString()) {
					kicked = true;
					break;
				}
			}
			if (kicked) {
				player.Send(MessageID.GAME_JOIN_FAIL_RECENTLY_KICKED);
				return false;
			}
			
			player.Init(PlayerIO.BigDB);
			if (player.banned) {
				int duration = (player.PlayerObject.GetDateTime("BannedUntil") - DateTime.Now).Days + 1;
				if (duration < 0)
					duration = -1;
				player.Send(MessageID.PLAYER_BANNED, player.bannedReason, duration);
				//player.Disconnect();
				return false;
			}

			return base.AllowUserJoin(player);
		}

		private void kickPlayer(Player sender, int colorID) {
			if (lobbyCountdownTimer != null) {
				lobbyCountdownTimer.Stop();
				lobbyCountdownTimer = null;
			}

			if (!sender.isHost || gameStarted) return;

			foreach (Player p in Players) {
				if (p.colorID == colorID) {
					//don't kick mods
					if (p.moderator) return;

					recentlyKicked.Add(new KickedPlayer(p.IPAddress.ToString(), 20));

					//Broadcast(MessageID.PLAYER_KICKED, p.Id);
					messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.PLAYER_KICKED, p.Id)));
					p.Disconnect();
					break;
				}
			}
		}

		private void mapInitialized() {
			
				// initialize players
				foreach (Player p in Players) {
					p.strength = map.GetPlayerStrength(p);
				}
				Message startGame = Message.Create(MessageID.GAME_START);
				startGame.Add(map.startType);
				startGame.Add((int)gameSettings.fightType);
				startGame.Add((int)gameSettings.troopsDistType);
				startGame.Add(gameSettings.upgradesEnabled);
				startGame.Add(gameSettings.boostsEnabled);

				// add players and their strengths
				startGame.Add(ingamePlayers.Count);
				foreach (Player p in ingamePlayers) {
					p.initConsumablesForGame(gameSettings, map.GetRegionCount());
					startGame.Add(p.Id, p.username, p.colorID, p.strength, p.race, p.level, p.attackBoosts, p.defenseBoosts, p.freeAttackBoosts, p.freeDefenseBoosts, p.isGuest ? "" : p.PlayerObject.Key, (int)p.rankingNew);
				}

				byte[] tiles = map.GetTiles();
				int count = map.GetTileCount();
				startGame.Add(map.GetWidth());
				startGame.Add(map.GetHeight());
				startGame.Add(tiles);
				count = map.GetRegionCount();
				startGame.Add(count);
				// add regions
				for (int i = 0; i < count; ++i) {
					Region r = map.GetRegion(i);
					if (r.owner != null) {
						startGame.Add(r.owner.Id);
					}
					else {
						startGame.Add(-1);
					}
					startGame.Add(r.dice);
				}

				//Broadcast(startGame);
				messageQueue.Add(new KeyValuePair<Player, Message>(null, startGame));

				// find player with smaller colorID and set him as active (first player always goes first
				int smallestColorID = 100;
				foreach (Player p in ingamePlayers) {
					if (p.colorID < smallestColorID) {
						activePlayer = p;
						smallestColorID = p.colorID;
					}
				}

				sendPlayerActive();

				activePlayer.idleTurns = 1;

				turnTimer.reset();
				turnTimer.addTicks(TurnTimer.MAX_TICKS);
				turnTimer.setDelegate(TimesUp);

				turnStage = 1;

				gameStarted = true;

				if (gameSettings.mapGroup == 101) {
					foreach (Player p in ingamePlayers) {
						p.addLastPlayedMap(gameSettings.userMap);
					}
				}

				
		}

		private void startGameTimer() {
			List<KeyValuePair<Player, Message>> tmpQueue;
			lock (turnLock) {
				startGame();

				tmpQueue = messageQueue;
				messageQueue = new List<KeyValuePair<Player, Message>>();
			}
			foreach (KeyValuePair<Player, Message> p in tmpQueue) {
				if (p.Key != null) {
					p.Key.Send(p.Value);
				}
				else {
					Broadcast(p.Value);
				}
			}
		}

		private void startNextTurnOnTimer() {
			List<KeyValuePair<Player, Message>> tmpQueue;
			lock (turnLock) {
				startNextTurn();

				tmpQueue = messageQueue;
				messageQueue = new List<KeyValuePair<Player, Message>>();
			}
			foreach (KeyValuePair<Player, Message> p in tmpQueue) {
				if (p.Key != null) {
					p.Key.Send(p.Value);
				}
				else {
					Broadcast(p.Value);
				}
			}
		}

		public void startGame() {
			// do we have enough players?
			if (ingamePlayers.Count < 2) return;
			// are they all ready?
			foreach(Player p in ingamePlayers) {
				if(!p.ready) {
					return;
				}
			}
			if (gameStarted) return;

			gameStarting = true;

			if (lobbyCountdownTimer != null) {
				lobbyCountdownTimer.Stop();
				lobbyCountdownTimer = null;
			}

			gameStartTime = DateTime.Now;

			gameMode = GameModes.GameMode.Create(gameSettings.fightType);

			activePlayerCount = ingamePlayers.Count;
			gameSettings.startPlayers = ingamePlayers.Count;

			anihilatedPlayers.Clear();
			ingamePlayers.Clear();
			foreach (Player p in Players) {
				if (!p.spectating) {
					ingamePlayers.Add(p);
					p.stillPlaying = true;
				}
			}

			// shufle colors
			for (int i = ingamePlayers.Count - 1; i >= 0; i--) {
				int randomIndex = rand.Next(i + 1);
				Player tmp = ingamePlayers[i];
				ingamePlayers[i] = ingamePlayers[randomIndex];
				ingamePlayers[randomIndex] = tmp;
			}

			for (int i = 0; i < ingamePlayers.Count; i++) {
				ingamePlayers[i].colorID = i;
			}

			if (gameSettings.mapGroup == 100) {
				while (!map.GenerateMap(ingamePlayers)) { };
				mapInitialized();
			}
			else if (gameSettings.mapGroup == 101) {
				PlayerIO.BigDB.Load("CustomMapsData", gameSettings.userMap, delegate(DatabaseObject result) {
					if (result != null) {
						map.loadPremadeMap(result.GetInt("Width"), result.GetInt("Height"), result.GetBytes("MapData"), ingamePlayers);

						List<KeyValuePair<Player, Message>> tmpQueue;

						lock (turnLock) {
							mapInitialized();
							
							tmpQueue = messageQueue;
							messageQueue = new List<KeyValuePair<Player, Message>>();
						}
						foreach (KeyValuePair<Player, Message> p in tmpQueue) {
							if (p.Key != null) {
								p.Key.Send(p.Value);
							}
							else {
								Broadcast(p.Value);
							}
						}
					}
					else {
						// todo
					}
				}, delegate(PlayerIOError error) {
					// todo
				});
			}
			else {
				String mapKey = "map_" + gameSettings.mapGroup + "_" + gameSettings.mapIndex;

				PlayerIO.BigDB.Load("Maps", mapKey, delegate(DatabaseObject result) {
					if (result != null) {
						map.loadPremadeMap(result.GetInt("Width"), result.GetInt("Height"), result.GetBytes("MapData"), ingamePlayers);

						List<KeyValuePair<Player, Message>> tmpQueue;

						lock (turnLock) {
							mapInitialized();

							tmpQueue = messageQueue;
							messageQueue = new List<KeyValuePair<Player, Message>>();
						}
						foreach (KeyValuePair<Player, Message> p in tmpQueue) {
							if (p.Key != null) {
								p.Key.Send(p.Value);
							}
							else {
								Broadcast(p.Value);
							}
						}
					}
					else {
						// todo
					}
				}, delegate(PlayerIOError error) {
					// todo
				});
			}

			RoomData["Started"] = "true";
			RoomData.Save();
		}

		private void sendPlayerActive() {
			Message m = Message.Create(MessageID.SET_PLAYER_ACTIVE, activePlayer.Id, roundCounter);
			int regionCount = map.GetRegionCount();
			m.Add(regionCount);
			for (int i = 1; i <= regionCount; i++) {
				Region r = map.GetRegionByID(i);
				if (r.owner != null && r.owner.stillPlaying) {
					m.Add(r.owner.Id);
				}
				else {
					m.Add(-1);
				}
				m.Add(r.dice);
			}
			//Broadcast(m);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, m));
		}

		private void EndTurn(Player player) {
			if (lagTimer != null) {
				lagTimer.Stop();
				lagTimer = null;
			}

			Console.WriteLine("EndTurn");
			if (player != activePlayer) {
				// player can send end turn message after server time runs out
				return;
			}
			if (turnStage == TURN_STAGE_TROOPS_DIST_AUTO || turnStage == TURN_STAGE_TROOPS_DIST_MANUAL) {
				// player can send end turn message after server time runs out
				return;
			}
			if (activePlayerCount <= 1) {
				return;
			}

			Console.WriteLine("end turn, round " + roundCounter);

			if (gameSettings.troopsDistType == GameSettings.TroopsDistributionType.MANUAL)
				turnStage = TURN_STAGE_TROOPS_DIST_MANUAL;
			else
				turnStage = TURN_STAGE_TROOPS_DIST_AUTO;

			turnTimer.stop();

			// send idle warning
			if (activePlayer.idleTurns == 2) {
				//player.Send(MessageID.GAME_IDLE_WARNING);
				messageQueue.Add(new KeyValuePair<Player,Message>(player, Message.Create(MessageID.GAME_IDLE_WARNING)));
			}
			// kick player if he is idling for 3 turns
			if (activePlayer.idleTurns == 3) {
				//player.Send(MessageID.GAME_IDLE_KICK);
				messageQueue.Add(new KeyValuePair<Player, Message>(player, Message.Create(MessageID.GAME_IDLE_KICK)));

				player.strength = 0;
				//Broadcast(MessageID.GAME_PLAYER_KICKED, player.Id, player.username, player.colorID);
				messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_PLAYER_KICKED, player.Id, player.username, player.colorID)));

				if (!CheckPlayerGameOver(player, false)) {
					//EndTurn(activePlayer);
					startNextTurn();
				}
				player.Disconnect();

				return;
			}

			if (gameSettings.troopsDistType == GameSettings.TroopsDistributionType.RANDOM || gameSettings.troopsDistType == GameSettings.TroopsDistributionType.BORDERS) {
				int distributedDice;

				lock (turnLock) {
					Console.WriteLine("EndTurn");

					player.stackedDice += player.getRegenWithBonus(player.strength, gameSettings);

					if (player.stackedDice > player.getMaxStackedDice(gameSettings, map)) {
						player.stackedDice = player.getMaxStackedDice(gameSettings, map);
					}

					if (!player.stillPlaying) {
						player.stackedDice = 0;
					}

					Message update = Message.Create(MessageID.GAME_POST_TURN_UPDATE, player.stackedDice);

					if (gameSettings.troopsDistType == GameSettings.TroopsDistributionType.RANDOM) {
						distributedDice = map.DistributeNewDice(player, true);
					}
					else {
						distributedDice = map.DistributeNewDice(player, false);
						// if we still have dice remaining after border distribution, distribute rest randomly across inland regions
						if (player.stackedDice > 0) {
							distributedDice += map.DistributeNewDice(player, true);
						}
					}
					if (player.stackedDice < 0) {
						PlayerIO.ErrorLog.WriteError("Stacked dice less than 0: " + player.stackedDice);
						player.stackedDice = 0;
					}

					List<Region> regions = map.GetPlayersRegions(player);
					update.Add(regions.Count);
					foreach (Region r in regions) {
						update.Add(r.ID);
						update.Add(r.dice);
						if (r.dice > 8) {
							PlayerIO.ErrorLog.WriteError("region contains more dice that 8: " + r.dice);
						}
					}

					//Broadcast(update);
					messageQueue.Add(new KeyValuePair<Player, Message>(null, update));
				}

				// wait until clients update new army strengths
				if (distributedDice == 0) {
					startNextTurn();
				}
				else {
					if (startNextTurnTimer != null) {
						startNextTurnTimer.Stop();
					}
					startNextTurnTimer = AddTimer(startNextTurnOnTimer, (int)((distributedDice + 3) * 0.25) * 1000);
				}
			}
			else {
				player.stackedDice += player.getRegenWithBonus(player.strength, gameSettings);
				if (player.stackedDice > player.getMaxStackedDice(gameSettings, map)) {
					player.stackedDice = player.getMaxStackedDice(gameSettings, map);
				}

				int turnDelay = 12;
				if (player.stackedDice > 12)
					turnDelay = 20;

				//Broadcast(MessageID.GAME_START_MANUAL_DISTRIBUTION, player.stackedDice, turnDelay);
				messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_START_MANUAL_DISTRIBUTION, player.stackedDice, turnDelay)));
				if (player.stillPlaying) {
					if (startNextTurnTimer != null) {
						startNextTurnTimer.Stop();
					}
					startNextTurnTimer = AddTimer(endTroopsDist, turnDelay * 1000);
				}
				else {
					startNextTurn();
				}
			}

			player.bonusesDisabled = false;
		}

		private void endTroopsDist() {
			Console.WriteLine("end troops dist");
			activePlayer.Send(MessageID.GAME_END_MANUAL_DISTRIBUTION);
			turnStage = TURN_STAGE_WAITING_FOR_DIST;

			if (startNextTurnTimer != null) {
				startNextTurnTimer.Stop();
				startNextTurnTimer = null;
			}

			if (waitingForDistResultTimer != null) {
				waitingForDistResultTimer.Stop();
			}
			waitingForDistResultTimer = AddTimer(skipDistributionResults, 10000);
		}

		private void skipDistributionResults() {
			List<KeyValuePair<Player, Message>> tmpQueue; 
			
			lock (turnLock) {
				if (waitingForDistResultTimer != null) {
					waitingForDistResultTimer.Stop();
					waitingForDistResultTimer = null;
				}

				Console.WriteLine("skipDistributionResults");

				Message update = Message.Create(MessageID.GAME_POST_TURN_UPDATE, activePlayer.stackedDice);

				//activePlayer.stackedDice += (int)(activePlayer.strength * activePlayer.getRegenMultiplier());
				int distributedDice = map.DistributeNewDice(activePlayer, true);
				if (activePlayer.stackedDice < 0) {
					PlayerIO.ErrorLog.WriteError("Stacked dice less than 0: " + activePlayer.stackedDice);
					activePlayer.stackedDice = 0;
				}

				List<Region> regions = map.GetPlayersRegions(activePlayer);
				update.Add(regions.Count);
				foreach (Region r in regions) {
					update.Add(r.ID);
					update.Add(r.dice);
					if (r.dice > 8) {
						PlayerIO.ErrorLog.WriteError("region contains more dice that 8: " + r.dice);
					}
				}

				//Broadcast(update);
				messageQueue.Add(new KeyValuePair<Player, Message>(null, update));

				if (distributedDice == 0) {
					startNextTurn();
				}
				else {
					if (startNextTurnTimer != null) {
						startNextTurnTimer.Stop();
					}
					startNextTurnTimer = AddTimer(startNextTurnOnTimer, (int)((distributedDice + 3) * 0.25) * 1000);
				}

				tmpQueue = messageQueue;
				messageQueue = new List<KeyValuePair<Player, Message>>();
			}
			foreach (KeyValuePair<Player, Message> p in tmpQueue) {
				if (p.Key != null) {
					p.Key.Send(p.Value);
				}
				else {
					Broadcast(p.Value);
				}
			}
		}

		private void handleDistributionResults(Player player, Message message) {
			Console.WriteLine("dist results");

			if (waitingForDistResultTimer != null) {
				waitingForDistResultTimer.Stop();
				waitingForDistResultTimer = null;
			}

			byte[] newTroops = message.GetByteArray(0);
			int index = 0;
			while (player.stackedDice > 0 && index < newTroops.Length) {
				Region r = map.GetRegionByID(newTroops[index]);
				if (r != null && r.dice < 8) {
					r.dice++;
					player.stackedDice--;
				}
				index++;
			}

			Message update = Message.Create(MessageID.GAME_POST_DISTRIBUTION_UPDATE);
			List<Region> regions = map.GetPlayersRegions(player);
			update.Add(regions.Count);
			foreach (Region r in regions) {
				update.Add(r.ID);
				update.Add(r.dice);
			}
			update.Add(message.GetByteArray(0));
			//Broadcast(update);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, update));

			if (player.stackedDice > 0) {
				update = Message.Create(MessageID.GAME_POST_TURN_UPDATE, player.stackedDice);

				int distributedDice = map.DistributeNewDice(player, true);

				regions = map.GetPlayersRegions(player);
				update.Add(regions.Count);
				foreach (Region r in regions) {
					update.Add(r.ID);
					update.Add(r.dice);
					if (r.dice > 8) {
						PlayerIO.ErrorLog.WriteError("region contains more dice that 8: " + r.dice);
					}
				}

				//Broadcast(update);
				messageQueue.Add(new KeyValuePair<Player, Message>(null, update));

				if (distributedDice == 0) {
					startNextTurn();
				}
				else {
					if (startNextTurnTimer != null) {
						startNextTurnTimer.Stop();
					}
					startNextTurnTimer = AddTimer(startNextTurnOnTimer, (int)((distributedDice + 3) * 0.25) * 1000);
				}
			}
			else {
				startNextTurn();
			}
		}

		private void startNextTurn() {
			Console.WriteLine("startNextTurn");

			if (turnStage == TURN_STAGE_ATTACK) {
				return;
			}
			if (activePlayerCount <= 1) {
				return;
			}


			//lock (turnLock) {
				turnStage = TURN_STAGE_ATTACK;

				if (startNextTurnTimer != null) {
					startNextTurnTimer.Stop();
					startNextTurnTimer = null;
				}

				int oldColorID = activePlayer.colorID;
				int nextColorID = (activePlayer.colorID + 1) % gameSettings.maxPlayers;

				int maxActiveColorID = 0;
				foreach (Player p in ingamePlayers) {
					if (p.stillPlaying && p.colorID > maxActiveColorID) {
						maxActiveColorID = p.colorID;
					}
				}

				if (nextColorID % (maxActiveColorID + 1) < oldColorID) {
					roundCounter++;
				}

				Console.WriteLine("" + roundCounter);

				bool found = false;
				while (!found) {
					foreach (Player p in ingamePlayers) {
						if (p.stillPlaying && p.colorID == nextColorID) {
							activePlayer = p;
							found = true;
							break;
						}
					}
					nextColorID = (nextColorID + 1) % gameSettings.maxPlayers;
				}
				

				// if we are playing land grab and this player waited to pick his first region until all were taken, eliminate him
				if (map.startType == 1 && activePlayer.strength == 0 && map.GetEmptyRegionsCount() == 0) {
					activePlayer.finishPlace = gameSettings.startPlayers - anihilatedPlayers.Count;
					activePlayer.updateRanking(getRankedPlayers(activePlayer, false));
					PlayerGameOver(activePlayer, false);
					if (!CheckTotalGameOver()) {
						// just so that we switch turn during attack phase
						turnStage = TURN_STAGE_TROOPS_DIST_AUTO;
						startNextTurn();
					}
					return;
				}

				// add 20 ticks
				//turnTimerHandle = AddTimer(turnTimer.tick, 1000);
				turnTimer.reset();
				turnTimer.addTicks(TurnTimer.MAX_TICKS);
				turnTimer.start();

				activePlayer.idleTurns++;
			//}
			sendPlayerActive();

			checkTieConditions();
			//Broadcast(MessageID.SET_PLAYER_ACTIVE, activePlayer.Id, (DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds);
		}

		private void checkTieConditions() {
			if (tieEnabled) return;
			if (roundCounter < 20) return;

			int playerCount = 0;
			foreach(Player p in ingamePlayers) {
				if(p.stillPlaying)
					playerCount++;
			}
			if (playerCount > 3) return;

			//Broadcast(MessageID.GAME_ENABLE_TIE);
			messageQueue.Add(new KeyValuePair<Player,Message>(null, Message.Create(MessageID.GAME_ENABLE_TIE)));
			tieEnabled = true;
		}

		private void TimesUp() {
			List<KeyValuePair<Player, Message>> tmpQueue;

			lock (turnLock) {
				EndTurn(activePlayer);
				tmpQueue = messageQueue;
				messageQueue = new List<KeyValuePair<Player, Message>>();
			}
			foreach (KeyValuePair<Player, Message> p in tmpQueue) {
				if (p.Key != null) {
					p.Key.Send(p.Value);
				}
				else {
					Broadcast(p.Value);
				}
			}
		}

		private void PerformAttack(Player sender, int sourceID, int targetID) {
			if (turnStage != TURN_STAGE_ATTACK) {
				// player can try to attack after his time run out on server if client is lagging
				return;
			}

			Region sourceRegion = map.GetRegionByID(sourceID);
			Region targetRegion = map.GetRegionByID(targetID);

			// regions are not neighbors
			if (!sourceRegion.join[targetRegion.ID]) {
				return;
			}
			// regions have same owner
			if (sourceRegion.owner == targetRegion.owner) {
				// player can attack again if he is lagging (he won in the meantime)
				return;
			}
			// source region have only 1 dice
			if (sourceRegion.dice == 1) {
				return;
			}
			// if message sent someone else that it should (hack attempt?)
			if (sender != activePlayer || !sender.stillPlaying) {
				return;
			}

			activePlayer.idleTurns = 0;

			if (targetRegion.dice == 0) {
				//if it is empty region, just take it, no combat needed
				targetRegion.owner = sourceRegion.owner;
				targetRegion.dice = sourceRegion.dice - 1;
				sourceRegion.dice = 1;

				sourceRegion.owner.strength = map.GetPlayerStrength(sourceRegion.owner);

				//Broadcast(MessageID.GAME_REGION_CONQUERED, sourceID, targetID, targetRegion.dice, sourceRegion.owner.strength);
				messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_REGION_CONQUERED, sourceID, targetID, targetRegion.dice, sourceRegion.owner.strength)));

				turnTimer.addTicks(5);

				sourceRegion.owner.regionConquered();

				return;
			}

			if (targetRegion.owner.disablesBonuses()) {
				activePlayer.bonusesDisabled = true;
			}
			if (activePlayer.disablesBonuses()) {
				targetRegion.owner.bonusesDisabled = true;
			}

			if (activePlayer.attackBoosts <= 0 && activePlayer.freeAttackBoosts <= 0) 
				activePlayer.attackBoostActive = false;

			Player oldOwner = targetRegion.owner;

			bool targetHadDefenseBoost = targetRegion.hasDefenseBoost;
			bool attackBoostWasActive = activePlayer.attackBoostActive;

			List<int> throws = gameMode.ResolveFight(sourceRegion, targetRegion, gameSettings, map);

			if (attackBoostWasActive) {
				if (!activePlayer.bonusesDisabled && (activePlayer.race == 113 || activePlayer.race == 119) && (gameSettings.fightType == GameSettings.FightType.ATTRITION || gameSettings.fightType == GameSettings.FightType.HARDCORE)) {
					if (targetHadDefenseBoost) {
						if (throws[1] == 3 || targetRegion.hasDefenseBoost)
							activePlayer.consumeAttackBoost();
					}
					else {
						if (throws[1] > 1)
							activePlayer.consumeAttackBoost();
					}
				}
				else
					activePlayer.consumeAttackBoost();
			}

			Message fightResult = Message.Create(MessageID.GAME_ATTACK_RESULT, sourceID, targetID);
			fightResult.Add(attackBoostWasActive);
			fightResult.Add(targetHadDefenseBoost);

			sourceRegion.owner.strength = map.GetPlayerStrength(sourceRegion.owner);
			if(oldOwner != null && oldOwner.stillPlaying)
				oldOwner.strength = map.GetPlayerStrength(oldOwner);


			foreach(int i in throws) {
				fightResult.Add(i);
			}
			fightResult.Add(sourceRegion.dice, targetRegion.dice, 
							sourceRegion.owner.Id, sourceRegion.owner.strength, 
							oldOwner != null ? oldOwner.Id : -1, oldOwner != null ? oldOwner.strength : 0, 
							// if both regions have same owner it means that attacker won, so we send client 
							// message that informs him about result so it doesn't have to be calculated again
							targetRegion.owner == sourceRegion.owner ? 1 : 0, 
							sourceRegion.owner.attackBoosts, sourceRegion.owner.freeAttackBoosts, targetRegion.hasDefenseBoost);

			//Broadcast(fightResult);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, fightResult));

			bool gameEnded = false;
			if(oldOwner != null)
				gameEnded = CheckPlayerGameOver(oldOwner, true);

			// record stats
			oldOwner.fightResult(targetRegion.owner != sourceRegion.owner, false, targetRegion.owner == sourceRegion.owner, false);
			sourceRegion.owner.fightResult(targetRegion.owner == sourceRegion.owner, targetRegion.owner == sourceRegion.owner, false, !oldOwner.stillPlaying);

			activePlayer.attackBoostActive = false;
			//Broadcast(MessageID.GAME_BOOST_ATTACK_ACTIVATE, activePlayer.Id, false);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_BOOST_ATTACK_ACTIVATE, activePlayer.Id, false)));

			if (gameEnded) {
				if(turnTimerHandle != null)
					turnTimerHandle.Stop();
			}
			else {
				// add 5 ticks for each fight + time spent in fight screen
				turnTimer.addTicks(5);
				turnTimer.addPause(gameMode.fightScreenDuration(0) * throws[1]);
			}
		}

		private bool CheckPlayerGameOver(Player oldOwner, bool awardXP) {
			if(oldOwner.strength == 0) {
				//Broadcast(MessageID.GAME_PLAYER_DEAD, oldOwner.Id);
				Message m = Message.Create(MessageID.GAME_PLAYER_DEAD, oldOwner.Id);
				messageQueue.Add(new KeyValuePair<Player, Message>(null, m));

				if (oldOwner.stillPlaying) {
					oldOwner.finishPlace = gameSettings.startPlayers - anihilatedPlayers.Count;
					oldOwner.updateRanking(getRankedPlayers(oldOwner, false));
					PlayerGameOver(oldOwner, awardXP);
					oldOwner.endGameStats(false, map.getSize(), gameSettings, (DateTime.Now - gameStartTime).Seconds);
				}
				return CheckTotalGameOver();
			}
			return false;
		}

		private bool CheckTotalGameOver() {
			if (activePlayerCount == 1) {
				Player winner = null;
				foreach (Player p in ingamePlayers) {
					if (p.stillPlaying) {
						winner = p;
						break;
					}
				}
				if (winner.stillPlaying) {
					winner.finishPlace = 1;
					winner.updateRanking(getRankedPlayers(winner, false));
					PlayerGameOver(winner, true);
					winner.endGameStats(true, map.getSize(), gameSettings, (DateTime.Now - gameStartTime).Seconds);
				}

				//Broadcast(MessageID.GAME_OVER_ALL);
				messageQueue.Add(new KeyValuePair<Player,Message>(null, Message.Create(MessageID.GAME_OVER_ALL)));

				RoomData["Visible"] = "false";
				RoomData.Save();
				Console.WriteLine("Visible false");
				return true;
			}
			return false;
		}

		private int limitIngameXp(int xp) {
			int result = 0;
			for (int i = 0; i < xp; i += 10) {
				int points = (xp - i) >= 10 ? 10 : (xp - i);
				if (i < 200)
					result += (int)((1 - i / 200.0) * points);
				else
					result += (int)(0.1 * points);
			}

			return result;
		}

		private int cutXPRewardByTurnCount(int xp) {
			int turns = roundCounter - 1;
			if (turns > 20) turns = 20;
			return (int)(xp * ((float)turns / 20.0f));
		}

		private void PlayerGameOver(Player player, bool awardXP) {
			if (!player.stillPlaying) return;

			activePlayerCount--;
			anihilatedPlayers.Add(player);

			// winner takes bonus for all remaining teritories with army in them (so surrendering don't take away xp from him
			if (activePlayerCount == 0) {
				for (int i = 0; i < map.GetRegionCount(); i++) {
					Region r = map.GetRegion(i);
					if (r.owner != null && r.owner.Id != player.Id) {
						//player.ingameXP++;
						player.increaseIngameXP(gameSettings.startPlayers, false);
					}
				}
			}
			int bonusXP = GetBonusXP(anihilatedPlayers.Count - 1);
			bonusXP = cutXPRewardByTurnCount(bonusXP);
			//player.ingameXP = cutXPRewardByTurnCount((int)player.ingameXP);
			player.ingameXP = limitIngameXp((int)player.ingameXP);

			int totalXP = (int)player.ingameXP + bonusXP;
			//if (totalXP > roundCounter * 5) totalXP = roundCounter * 5;
			int totalShards = player.regionsConquered;
			if (totalShards > roundCounter * 3) totalShards = roundCounter * 3;

			/*player.ingameXP = totalXP - bonusXP;
			if (player.ingameXP < 0) {
				player.ingameXP = 0;
				bonusXP = totalXP;
			}*/

			totalShards = totalShards + (int)(totalShards * player.getShardsBonus());

			//player.Send(MessageID.GAME_OVER, gameSettings.startPlayers - anihilatedPlayers.Count + 1, player.ingameXP, bonusXP, gameSettings.startPlayers, totalShards);
			messageQueue.Add(new KeyValuePair<Player,Message>(player, Message.Create(MessageID.GAME_OVER, gameSettings.startPlayers - anihilatedPlayers.Count + 1, (int)player.ingameXP, bonusXP, gameSettings.startPlayers, totalShards, (int)player.rankingOriginal, (int)player.rankingNew)));

			if (awardXP) {
				player.awardXP(totalXP, totalShards);
			}

			player.ingameXP = 0;
			player.stillPlaying = false;
		}

		private int GetBonusXP(int place) {
			/*if (place == gameSettings.startPlayers - 1) {
				return (place + 1) * 5;
			}
			else {
				return place * 5;
			}*/
			int K = 10 + 20 / 6 * (gameSettings.startPlayers - 2);
			/*int maxXpVal = (K * gameSettings.startPlayers - K / 2 * (gameSettings.startPlayers - place - 1));
			int turns = roundCounter - 1;
			if (turns > 20) turns = 20;
			return (int)(maxXpVal * ((float)turns / 20.0f));*/
			return (K * gameSettings.startPlayers - K / 2 * (gameSettings.startPlayers - place - 1));
		}

		private void surrender(Player player, bool notify, bool awardXP) {
			player.strength = 0;

			if (gameStarted && roundCounter < 4) {
				player.xpPenalty(30);
				awardXP = false;
			}

			if (!CheckPlayerGameOver(player, awardXP)) {
				if (activePlayer == player) {
					if (turnStage == TURN_STAGE_TROOPS_DIST_AUTO || turnStage == TURN_STAGE_TROOPS_DIST_MANUAL) {
						if(startNextTurnTimer != null)
							startNextTurnTimer.Stop();
						startNextTurnTimer = null;
						startNextTurn();
					}
					else if (turnStage == TURN_STAGE_WAITING_FOR_DIST) {
						startNextTurn();
					}
					else {
						EndTurn(activePlayer);
					}
				}
			}

			if (notify) {
				//Broadcast(MessageID.GAME_PLAYER_SURRENDERED, player.Id, player.username, player.colorID);
				Message m = Message.Create(MessageID.GAME_PLAYER_SURRENDERED, player.Id, player.username, player.colorID);
				messageQueue.Add(new KeyValuePair<Player,Message>(null, m));
			}
				
		}

		private void firstRegionConquer(Player sender, int playerID, int regionID) {
			if (lagTimer != null) {
				lagTimer.Stop();
				lagTimer = null;
			}

			if (!sender.stillPlaying) {
				return;
			}
			if (activePlayer != sender) {
				return;
			}
			if (activePlayer.Id != playerID) {
				return;
			}
			if (activePlayer.strength != 0) {
				// we can get more messages before first response is received by client
				return;
			}
			if (turnStage != TURN_STAGE_ATTACK) {
				return;
			}

			Region r = map.GetRegionByID(regionID);
			if (r.owner != null) return;

			r.owner = activePlayer;
			r.dice = 1;
			activePlayer.strength = 1;

			//Broadcast(MessageID.GAME_FIRST_REGION_CONQUERED, playerID, regionID, r.dice);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_FIRST_REGION_CONQUERED, playerID, regionID, r.dice)));
		}

		private void handlePlayerReady(Player player, Message m) {
			player.ready = m.GetBoolean(0);
			//Broadcast(MessageID.PLAYER_READY, player.colorID, player.ready);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.PLAYER_READY, player.colorID, player.ready)));

			if (ingamePlayers.Count < gameSettings.maxPlayers) return;

			bool allReady = true;
			foreach (Player p in ingamePlayers) {
				allReady &= p.ready;
			}

			if (allReady) {
				if (lobbyCountdownTimer == null) {
					//Broadcast(MessageID.LOBBY_START_COUNTDOWN);
					messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.LOBBY_START_COUNTDOWN)));
					lobbyCountdownTimer = AddTimer(startGameTimer, 3000);
				}
			}
		}

		private void handleTieOffered(Player p) {
			if (!tieEnabled) return;
			p.tieOffered = !p.tieOffered;

			//Broadcast(MessageID.GAME_TIE_OFFERED, p.Id, p.tieOffered);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_TIE_OFFERED, p.Id, p.tieOffered)));

			bool allAgree = true;
			foreach (Player player in ingamePlayers) {
				if (player.stillPlaying) {
					allAgree &= player.tieOffered;
				}
			}

			if (allAgree) {
				gameOverTie();
			}
		}

		private void gameOverTie() {
			List<Player> rankedPlayers = getRankedPlayers(null, true);

			foreach (Player p in ingamePlayers) {
				if (p.stillPlaying) {
					playerGameOverTie(p, rankedPlayers);
				}
			}

			activePlayerCount = 0;
			//Broadcast(MessageID.GAME_OVER_ALL);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_OVER_ALL)));

			RoomData["Visible"] = "false";
			RoomData.Save();
			Console.WriteLine("Visible false");
		}

		private void playerGameOverTie(Player player, List<Player>rankedPlayers) {
			if (player.stillPlaying) {
				int bonusXP = GetBonusXP(gameSettings.startPlayers - 1) / 2;
				bonusXP = cutXPRewardByTurnCount(bonusXP);
				//player.ingameXP = cutXPRewardByTurnCount((int)player.ingameXP);
				player.ingameXP = limitIngameXp((int)player.ingameXP);
				//player.Send(MessageID.GAME_OVER, -2, player.ingameXP, bonusXP, gameSettings.startPlayers, player.regionsConquered);

				// create copy of ranked players but remove current player
				List<Player> rankedPlayers2 = new List<Player>();
				foreach (Player p in rankedPlayers) {
					if (p != player) {
						rankedPlayers2.Add(p);
					}
				}
				player.finishPlace = 2;
				player.updateRanking(rankedPlayers2);
				messageQueue.Add(new KeyValuePair<Player, Message>(player, Message.Create(MessageID.GAME_OVER, -2, (int)player.ingameXP, bonusXP, gameSettings.startPlayers, player.regionsConquered, (int)player.rankingOriginal, (int)player.rankingNew)));

				int totalShards = player.regionsConquered;
				if (totalShards > roundCounter * 3) totalShards = roundCounter * 3;

				totalShards = totalShards + (int)(totalShards * player.getShardsBonus());

				player.awardXP((int)player.ingameXP + bonusXP, totalShards);
				//player.awardXP(bonusXP, player.regionsConquered);
				player.ingameXP = 0;
				player.stillPlaying = false;

				player.endGameStats(false, map.getSize(), gameSettings, (DateTime.Now - gameStartTime).Seconds);
			}
		}

		private List<Player> getRankedPlayers(Player player, bool tie) {
			List<Player> result = new List<Player>();
			foreach (Player p in anihilatedPlayers) {
				if (p != player) {
					p.ratingResult = 1;
					result.Add(p);

					// if we won over this guest, set his rating to 0 so we don't get points for him
					if (p.isGuest) {
						p.rankingNew = 200;
						p.rankingOriginal = 200;
					}
				}
			}

			foreach (Player p in Players) {
				if (p != player && p.stillPlaying) {
					p.ratingResult = tie ? 0.5f : 0;
					result.Add(p);

					// if we lost to the guest, treat his as 1500 player so we don't lose extreme amount of points
					if (p.isGuest) {
						p.rankingNew = 1500;
						p.rankingOriginal = 1500;
					}
				}
			}

			return result;
		}

		private void placeDefenseBoost(Player player, Message m) {
			if (player != activePlayer) return;
			if (!player.stillPlaying) return;
			if (player.defenseBoosts <= 0 && player.freeDefenseBoosts <= 0) return;

			Region region = map.GetRegionByID(m.GetInt(0));

			if (region.hasDefenseBoost) return;

			player.idleTurns = 0;

			region.hasDefenseBoost = true;
			player.consumeDefenseBoost();

			Console.WriteLine("Region " + region.ID + " gained boost " + region.hasDefenseBoost);

			//Broadcast(MessageID.GAME_BOOST_DEFENSE, player.Id, player.defenseBoosts, player.freeDefenseBoosts, region.ID);
			messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_BOOST_DEFENSE, player.Id, player.defenseBoosts, player.freeDefenseBoosts, region.ID)));
		}

		private Player findPlayerByUsername(String username) {
			username = username.ToLower();
			foreach (Player p in ingamePlayers) {
				if (p.username.ToLower().Replace(" ", "").Equals(username)) {
					return p;
				}
			}
			return null;
		}

		private void handleModCommand(Player player, String message) {
			if (!player.moderator) return;

			string[] parts = message.Split(' ');

			switch (parts[0]) {
				case "/ban":
					if (parts.Length < 4) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "Not enough parameters, ban requires 3 parameters: name, duration (-1 for permaban) and reason");
						return;
					}

					// find user to ban
					Player playerToBan = findPlayerByUsername(parts[1]);
					if (playerToBan == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User \"" + parts[1] + "\" not found.");
					}
					else {
						if (playerToBan.isGuest) {
							player.Send(MessageID.MOD_COMMAND_FAILED, "You can't ban guest");
							break;
						} 

						//p.PlayerObject.Set("Banned", true);
						int duration;
						try {
							duration = Convert.ToInt32(parts[2]);
						}
						catch (Exception e) {
							player.Send(MessageID.MOD_COMMAND_FAILED, "Format malfunction, second parameter (duration) wasn't proper integer.");
							return;
						}

						String reason = parts[3];
						for (int i = 4; i < parts.Length; i++) {
							reason += " " + parts[i];
						}

						playerToBan.ban(duration, reason, player.username);

						playerToBan.Send(MessageID.GAME_KICKED, reason, player.username);

						player.Send(MessageID.MOD_COMMAND_SUCCESS, "Player banned succesfully.");
						Broadcast(MessageID.GAME_PLAYER_MOD_KICKED, playerToBan.username, reason, player.username);

						playerToBan.Disconnect();
					}
					break;
				case "/kick":
					if (parts.Length < 3) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "Not enough parameters, kick requires 2 parameters: name and reason");
						return;
					}

					Player playerToKick = findPlayerByUsername(parts[1]);
					if (playerToKick == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User \"" + parts[1] + "\" not found.");
					}
					else {
						// build reason from rest of the message
						String reason = parts[2];
						for (int i = 3; i < parts.Length; i++) {
							reason += " " + parts[i];
						}
						playerToKick.Send(MessageID.GAME_KICKED, reason, player.username);

						Broadcast(MessageID.GAME_PLAYER_MOD_KICKED, playerToKick.username, reason, player.username);

						playerToKick.Disconnect();
					}
					break;
				case "/warn":
					if (parts.Length < 3) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "Not enough parameters, warn requires 2 parameters: name and reason");
						return;
					}

					Player playerToWarn = findPlayerByUsername(parts[1]);
					if (playerToWarn == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User \"" + parts[1] + "\" not found.");
					}
					else {
						if (playerToWarn.isGuest) {
							player.Send(MessageID.MOD_COMMAND_FAILED, "You can't warn guest");
							break;
						}
						// build reason from rest of the message
						String reason = parts[2];
						for (int i = 3; i < parts.Length; i++) {
							reason += " " + parts[i];
						}
						playerToWarn.warn(reason, player.username);

						player.Send(MessageID.MOD_COMMAND_SUCCESS, "Warn entry added succesfully.");
					}
					break;

				case "/list":
					if (parts.Length < 2) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "Not enough parameters, warn requires 1 parameter: name");
						return;
					}
					Player playerToList = findPlayerByUsername(parts[1]);
					if (playerToList == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User not found.");
					}
					else {
						player.Send(MessageID.MOD_COMMAND_SUCCESS, playerToList.list());
					}
					break;
				case "/listips":
					String ipList = "";
					foreach (Player p in ingamePlayers) {
						ipList += p.username + " - " + p.IPAddress.ToString() + "\n";
					}
					player.Send(MessageID.MOD_COMMAND_SUCCESS, ipList);
					break;
			}
		}

		/*// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message m) {
			if (player.isLagging) {
				if (lagTimer != null) {
					lagTimer.Stop();
				}
				lagTimer = AddTimer(delegate()
				{
					GotMessage2(player, m);
				}, 2000);
			}
			else {
				GotMessage2(player, m);
			}
		}*/

		public override void GotMessage(Player player, Message m) {
			//Console.WriteLine(m.Type);
            List<KeyValuePair<Player, Message>> tmpQueue;

			lock (turnLock) {
				switch (m.Type) {
					case MessageID.GAME_START:
						startGame();
						break;
					case MessageID.MESSAGE_SEND:
						Console.WriteLine("0: " + m.GetString(0));
						if (m.GetString(0).StartsWith("/")) {
							Console.WriteLine("1: " + m.GetString(0));
							handleModCommand(player, m.GetString(0));
						}
						else {
							Console.WriteLine("2: " + m.GetString(0));
							if (player.messageCounter > 2) {
								//player.Send(MessageID.LOBBY_TOO_MANY_MESSAGES);
								messageQueue.Add(new KeyValuePair<Player, Message>(player, Message.Create(MessageID.LOBBY_TOO_MANY_MESSAGES)));
							}
							else {
								player.messageCounter++;
								Console.WriteLine("3: " + player.username);

								if (player.spectating && !player.moderator) {
									Console.WriteLine("4: " + player.moderator);
									foreach (Player p in Players) {
										Console.WriteLine("5: " + p.spectating);
										Console.WriteLine("6: " + p.username);
										if (p.spectating) {
											//p.Send(MessageID.MESSAGE_RECEIVED, player.username, m.GetString(0), player.isPremium(), player.stillPlaying ? false : player.moderator, player.colorID);
											messageQueue.Add(new KeyValuePair<Player, Message>(p, Message.Create(MessageID.MESSAGE_RECEIVED, player.username, m.GetString(0), player.isPremium(), player.stillPlaying ? false : player.moderator, player.colorID)));
										}
									}
								}
								else {
									//Broadcast(MessageID.MESSAGE_RECEIVED, player.username, m.GetString(0), player.isPremium(), player.stillPlaying ? false : player.moderator, player.colorID);
									messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.MESSAGE_RECEIVED, player.username, m.GetString(0), player.isPremium(), player.stillPlaying ? false : player.moderator, player.colorID)));
								}
							}
						}
						break;
					case MessageID.PLAYER_READY:
						handlePlayerReady(player, m);
						break;
					case MessageID.GAME_END_TURN:
						player.idleTurns = 0;
						EndTurn(player);
						player.idleTurns = 0;
						break;
					case MessageID.GAME_ATTACK:
						PerformAttack(player, m.GetInt(0), m.GetInt(1));
						break;
					case MessageID.KICK_PLAYER:
						kickPlayer(player, m.GetInt(0));
						break;
					case MessageID.GAME_FIRST_CONQUER_REGION:
						firstRegionConquer(player, m.GetInt(0), m.GetInt(1));
						break;
					case MessageID.GAME_SURRENDER:
						surrender(player, true, true);
						break;
					case MessageID.GAME_DISTRIBUTION_RESULTS:
						handleDistributionResults(player, m);
						break;
					case MessageID.USER_SET_RACE:
						player.setRace(m.GetInt(0));
						//Broadcast(MessageID.GAME_RACE_CHANGED, player.colorID, player.race);
						messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_RACE_CHANGED, player.colorID, player.race)));
						break;
					case MessageID.GAME_DUMP_MAP:
						/*String dbg = map.dumpRegionsToString();
						DatabaseObject dbo = new DatabaseObject();
						dbo.Set("MapDump", dbg);
						PlayerIO.BigDB.CreateObject("Debug", RoomId, dbo, delegate(DatabaseObject obj) { });*/
						break;
					case MessageID.GAME_TIE_OFFERED:
						handleTieOffered(player);
						break;
					case MessageID.GAME_BOOST_ATTACK_ACTIVATE:
						player.attackBoostActive = !player.attackBoostActive;
						if (player.attackBoostActive) {
							if (player.attackBoosts <= 0 && player.freeAttackBoosts <= 0) {
								player.attackBoostActive = false;
							}
						}
						//Broadcast(MessageID.GAME_BOOST_ATTACK_ACTIVATE, player.Id, player.attackBoostActive);
						messageQueue.Add(new KeyValuePair<Player, Message>(null, Message.Create(MessageID.GAME_BOOST_ATTACK_ACTIVATE, player.Id, player.attackBoostActive)));
						break;
					case MessageID.GAME_BOOST_DEFENSE:
						placeDefenseBoost(player, m);
						break;
				}
				tmpQueue = messageQueue;
				messageQueue = new List<KeyValuePair<Player, Message>>();
			}
			foreach (KeyValuePair<Player, Message> p in tmpQueue) {
				if (p.Key != null) {
					p.Key.Send(p.Value);
				}
				else {
					Broadcast(p.Value);
				}
			}
		}

		// This method get's called whenever you trigger it by calling the RefreshDebugView() method.
		public override System.Drawing.Image GenerateDebugImage() {
			// we'll just draw 400 by 400 pixels image with the current time, but you can
			// use this to visualize just about anything.
			var image = new Bitmap(640,640);
			using(var g = Graphics.FromImage(image)) {
				// fill the background
				g.FillRectangle(Brushes.Blue, 0, 0, image.Width, image.Height);

				// draw the current time
				g.DrawString(DateTime.Now.ToString(), new Font("Verdana",20F),Brushes.Orange, 10,10);

				map.DebugDraw(g);
				// draw a dot based on the DebugPoint variable
				
			}
			return image;
		}

		// During development, it's very usefull to be able to cause certain events
		// to occur in your serverside code. If you create a public method with no
		// arguments and add a [DebugAction] attribute like we've down below, a button
		// will be added to the development server. 
		// Whenever you click the button, your code will run.
		[DebugAction("GenerateMap", DebugAction.Icon.Cog)]
		public void GenerateMap() {
			//Console.WriteLine("The generate map button was clicked!");

			// try generate map as many times as needed to get correct map 
			// statistically should be 1, 2 attempts max
			//map.SetSize(3);
			while (!map.GenerateMap(ingamePlayers)) { };
		}

		[DebugAction("CheckConnectivity", DebugAction.Icon.Cog)]
		public void CheckConnectivity() {
			//Console.WriteLine("The generate map button was clicked!");

			// try generate map as many times as needed to get correct map 
			// statistically should be 1, 2 attempts max
			map.AreRegionsConnected();
		}
	}
}
