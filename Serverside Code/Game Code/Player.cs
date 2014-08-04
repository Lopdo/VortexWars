using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds {
	public class Player : BasePlayer {
        public String username;
		public int colorID = -1;
		public int strength;
		public int stackedDice = 0;
		public bool ready = false;
		public bool isHost = false;
		public float ingameXP = 0;
		public int totalXP;
		public int xp = 0;
		public int shards = 0;
		public int attackBoosts = 0, defenseBoosts = 0;
		public int freeAttackBoosts = 0, freeDefenseBoosts = 0;
		private int attackBoostsTotal = 0, defenseBoostsTotal = 0;
		public bool attackBoostActive;

		public int regionsConquered = 0;
		public int level = 0;
		public bool isGuest = false;
		public bool stillPlaying;
		public bool spectating;
		//public bool isPremium;
		public int race = 0;
		public int background = 0;
		public bool banned;
		public bool hidePremium = false;
		public String bannedReason;

		public bool tieOffered = false;

		public const int MAX_STACKED_DICE = 20;

		public int idleTurns = 0;

		public int messageCounter = 0;
		public Timer messageTimer;

		protected BigDB bigDB;

		protected bool playerObjectDirty;
		protected bool playerObjectSaving;

		public bool moderator = false;

		public int mapSlots = 0;

		// ranking
		public float ratingResult = 0;
		public float rankingOriginal;
		public float rankingGS;
		public float rankingNew;
		public float rankingDeviation;
		public float rankingDeviationGS;
		public float rankingVolatility;

		public Achievements.AchievementManager achievManager;
		public DatabaseObject achievements = null;

		public int finishPlace;

		public ErrorLog errorLog;
		//public bool isLagging = true;

		public bool bonusesDisabled = false;

		public Player() {
        }

		virtual public void Init(BigDB db) {
			Object tmp;

			if (JoinData.ContainsKey("Guest") && Convert.ToBoolean(JoinData["Guest"])) {
				username = JoinData["Name"];
				isGuest = true;
			}

			if (!isGuest) {
				// if username exists, we have registered user so we take that as his name, if it is not set
				// we have guest so we take his name from ConnectUserId
				if (PlayerObject.TryGetValue("Username", out tmp)) {
					username = (String)tmp;
				}
				if (username == null && JoinData.ContainsKey("Name")) {
					username = JoinData["Name"];
				}
				InitializeDB();
				PayVault.Refresh(null);
				bigDB = db;
				achievManager = new Achievements.AchievementManager(bigDB, this);
			}
			else {
				savingFinished();

				rankingOriginal = 0;
				rankingGS = -1500 / 173.7178f;
				rankingDeviation = 350;
				rankingDeviationGS = rankingDeviation / 173.7178f;
			}

			//messageTimer = AddTimer(messageTimerTick, 3000);
		}

		public void messageTimerTick() {
			if (messageCounter > 0)
				messageCounter--;
		}

		public void xpPenalty(int penalty) {
			if (isGuest) return;

			if(penalty > xp) penalty = xp;
			xp -= penalty;

			PlayerObject.Set("XP", xp);
			PlayerObject.Set("TotalXP", PlayerObject.GetInt("TotalXP") - penalty);
			savePlayerData();
		}

		virtual public void awardXP(int newXP, int newShards) {
			if (isGuest) return;

			if (isPremium()) {
				newXP *= 2;
			}

			xp += newXP;
			totalXP += newXP;

			shards += newShards;

			int toNextLevel = Player.GetLevelXP(level);
			while (xp >= toNextLevel) {
				xp -= toNextLevel;
				level++;
				shards += level * 10;
				toNextLevel = Player.GetLevelXP(level);
			}

			PlayerObject.Set("Level", level);
			PlayerObject.Set("XP", xp);
			PlayerObject.Set("Shards", shards);
			PlayerObject.Set("TotalXP", totalXP);
			savePlayerData();
		}

		public float getShardsBonus() {
			if (race == 111) {
				return 0.25f;
			}
			return 0;
		}

		public static int getXPToLevel(int level) {
			return (int)(2.5 * level * (2 * level * level + 3 * level + 71));
		}

		public static int GetLevelXP(int level) {
			return 175 + level * level * 15;
		}

		public bool isPremium() {
			if (isGuest) return false;
			else return (PlayerObject.GetDateTime("PremiumUntil") - DateTime.Now).Seconds > 0;
		}

		public int getMaxStackedDice(GameSettings settings, Map map) {
			int max = MAX_STACKED_DICE;
			if (settings.upgradesEnabled && !isGuest) {
			//if (!isGuest) {
				if (PayVault.Has("ArmyStorageUpg1"))
					max += 10;
				if (PayVault.Has("ArmyStorageUpg2"))
					max += 10;
				if (PayVault.Has("ArmyStorageUpg3"))
					max += Math.Min((int)(map.GetRegionCount() * 0.1), 10);
				if(PayVault.Has("ArmyStorageUpg4"))
					max += Math.Min((int)(map.GetRegionCount() * 0.1), 10);
				if (race == 116 && !bonusesDisabled)
					max += 5;
			}
			return max;
		}

		private void InitializeDB() {
			if (!PlayerObject.Contains("Moderator")) PlayerObject.Set("Moderator", false);
			moderator = PlayerObject.GetBool("Moderator");
			if (!PlayerObject.Contains("HidePremium")) PlayerObject.Set("HidePremium", false);
			hidePremium = PlayerObject.GetBool("HidePremium");
			if (!PlayerObject.Contains("Level")) PlayerObject.Set("Level", 1);
			level = PlayerObject.GetInt("Level");
			if (!PlayerObject.Contains("TotalXP")) PlayerObject.Set("TotalXP", 0);
			totalXP = PlayerObject.GetInt("TotalXP");
			if (!PlayerObject.Contains("XP")) PlayerObject.Set("XP", 0);
			xp = PlayerObject.GetInt("XP");

			if(!PlayerObject.Contains("TotalXPOld")) {
				PlayerObject.Set("TotalXPOld", totalXP);
				PlayerObject.Set("TotalXP", Player.getXPToLevel(level-1) + xp);
			}

			if (!PlayerObject.Contains("Shards")) PlayerObject.Set("Shards", 0);
			shards = PlayerObject.GetInt("Shards");
			if (!PlayerObject.Contains("Race")) PlayerObject.Set("Race", 0);
			race = PlayerObject.GetInt("Race");
			
			if (!PlayerObject.Contains("AttackBoosts")) PlayerObject.Set("AttackBoosts", 10);
			attackBoostsTotal = PlayerObject.GetInt("AttackBoosts");
			if (!PlayerObject.Contains("DefenseBoosts")) PlayerObject.Set("DefenseBoosts", 10);
			defenseBoostsTotal = PlayerObject.GetInt("DefenseBoosts");

			if (!PlayerObject.Contains("Background")) PlayerObject.Set("Background", 0);
			background = PlayerObject.GetInt("Background");
			//if (!PlayerObject.Contains("Premium")) PlayerObject.Set("Premium", false);
			//else isPremium = PlayerObject.GetBool("Premium");
			if (!PlayerObject.Contains("PremiumUntil")) PlayerObject.Set("PremiumUntil", new DateTime(2000, 1, 1, 0, 0, 0));

			if (!PlayerObject.Contains("Banned")) PlayerObject.Set("Banned", false);
			banned = PlayerObject.GetBool("Banned");
			if (!PlayerObject.Contains("BannedReason")) PlayerObject.Set("BannedReason", "");
			bannedReason = PlayerObject.GetString("BannedReason");
			if (!PlayerObject.Contains("BannedUntil")) PlayerObject.Set("BannedUntil", new DateTime(2000, 1, 1, 0, 0, 0));
			banned |= (PlayerObject.GetDateTime("BannedUntil") - DateTime.Now).Seconds > 0;
			if (!PlayerObject.Contains("BanHistory")) PlayerObject.Set("BanHistory", new DatabaseArray());
			if (!PlayerObject.Contains("WarnHistory")) PlayerObject.Set("WarnHistory", new DatabaseArray());

			if (!PlayerObject.Contains("FBInvites")) PlayerObject.Set("FBInvites", new DatabaseArray());

			// editor
			if (!PlayerObject.Contains("EditorSlots")) PlayerObject.Set("EditorSlots", 3);
			mapSlots = PlayerObject.GetInt("EditorSlots");
			if (!PlayerObject.Contains("Maps")) PlayerObject.Set("Maps", new DatabaseArray());
			if (!PlayerObject.Contains("LastPlayedMaps")) PlayerObject.Set("LastPlayedMaps", new DatabaseArray());
			if (!PlayerObject.Contains("LikedMaps")) PlayerObject.Set("LikedMaps", new DatabaseArray());
			if (!PlayerObject.Contains("DislikedMaps")) PlayerObject.Set("DislikedMaps", new DatabaseArray());

			// stats
			DatabaseObject stats = null;
			if (PlayerObject.Contains("Stats")) stats = PlayerObject.GetObject("Stats");
			if (stats == null)
				stats = new DatabaseObject();

			//String key;
			// size
			/*for (int i = 0; i < 5; ++i) {
				// battle type
				for (int j = 0; j < 4; ++j) {
					// start type
					for (int k = 0; k < 2; ++k) {
						key = "Matches_" + i + "_" + j + "_" + k;
						if (!stats.Contains(key)) stats.Set(key, 0);
						key = "Wins_" + i + "_" + j + "_" + k;
						if (!stats.Contains(key)) stats.Set(key, 0);
						//key = "Finished_" + i + "_" + j + "_" + k;
						//if (!stats.Contains(key)) stats.Set(key, 0);
					}
				}
			}*/

			if (!stats.Contains("RegionsConquered")) stats.Set("RegionsConquered", 0);
			if (!stats.Contains("RegionsLost")) stats.Set("RegionsLost", 0);

			if (!stats.Contains("FightWinRatio")) stats.Set("FightWinRatio", 0.0f);
			if (!stats.Contains("FightCount")) stats.Set("FightCount", 0);
			if (!stats.Contains("GameDurationTotal")) stats.Set("GameDurationTotal", 0);
			if (!stats.Contains("GameDurationAverage")) stats.Set("GameDurationAverage", 0.0f);
			if (!stats.Contains("AveragePlayerCount")) stats.Set("AveragePlayerCount", 0.0f);
			if (!stats.Contains("PlayersEliminated")) stats.Set("PlayersEliminated", 0);

			if (!stats.Contains("Wins6Plus")) stats.Set("Wins6Plus", 0);
			if (!stats.Contains("ConsecutiveRollWins")) stats.Set("ConsecutiveRollWins", 0);
			// races
			for (int i = 0; i < 8; ++i) {
				//if (!stats.Contains("RaceMatches_" + i)) stats.Set("RaceMatches_" + i, 0);
				if (!stats.Contains("RaceWins_" + i)) stats.Set("RaceWins_" + i, 0);
			}

			for (int i = 100; i < 124; i++) {
				//if (!stats.Contains("RaceMatches_" + i)) stats.Set("RaceMatches_" + i, 0);
				if (!stats.Contains("RaceWins_" + i)) stats.Set("RaceWins_" + i, 0);
			}
			
			if (!stats.Contains("TotalMatches")) stats.Set("TotalMatches", 0);
			if (!stats.Contains("TotalWins")) stats.Set("TotalWins", 0);
			if (!stats.Contains("TotalFinished")) stats.Set("TotalFinished", 0);

			if (!PlayerObject.Contains("Stats")) PlayerObject.Set("Stats", stats);

			// achievements
			//DatabaseObject achievements = null;
			if (PlayerObject.Contains("Achievements")) achievements = PlayerObject.GetObject("Achievements");
			if (achievements == null)
				achievements = new DatabaseObject();

			//

			if (!PlayerObject.Contains("Achievements")) PlayerObject.Set("Achievements", achievements);

			// award shards if we didn't do it before
			if (!PlayerObject.Contains("ShardsAwarded")) {
				PlayerObject.Set("Shards", shards + stats.GetInt("RegionsConquered"));
				PlayerObject.Set("ShardsAwarded", true);
			}

			// when did we awarded shards for visit last time?
			if (!PlayerObject.Contains("LastShardsReward")) PlayerObject.Set("LastShardsReward", new DateTime(2000, 1, 1, 0, 0, 0));
			if (!PlayerObject.Contains("ConsecutiveVisits")) PlayerObject.Set("ConsecutiveVisits", 0);

			// ranking
			if (!PlayerObject.Contains("RankingRating")) PlayerObject.Set("RankingRating", 1500.0f);
			try {
				rankingNew = rankingOriginal = PlayerObject.GetFloat("RankingRating");
			}
			catch (Exception e) {
				rankingNew = rankingOriginal = (float)PlayerObject.GetInt("RankingRating");
			}
			if (rankingNew < 0) {
				rankingNew = rankingOriginal = 1500.0f;
				PlayerObject.Set("RankingRating", 1500.0f);
			}
			if (!PlayerObject.Contains("RankingDeviation")) PlayerObject.Set("RankingDeviation", 100.0f);
			rankingDeviation = PlayerObject.GetFloat("RankingDeviation");
			if (!PlayerObject.Contains("RankingVolatility")) PlayerObject.Set("RankingVolatility", 0.06f);
			rankingVolatility = PlayerObject.GetFloat("RankingVolatility");
			if (float.IsNaN(rankingDeviation) || float.IsNaN(rankingVolatility) || float.IsInfinity(rankingDeviation) || float.IsInfinity(rankingVolatility) ||
				rankingDeviation > 1000 || rankingVolatility > 1) {
				rankingDeviation = 350.0f;
				PlayerObject.Set("RankingDeviation", 350.0f);
				rankingVolatility = 0.06f;
				PlayerObject.Set("RankingVolatility", 0.06f);
				rankingNew = rankingOriginal = 1500.0f;
				PlayerObject.Set("RankingRating", 1500.0f);
			}
			rankingDeviationGS = rankingDeviation / 173.7178f;
			rankingGS = (rankingOriginal - 1500) / 173.7178f;

			// player presence
			if (!PlayerObject.Contains("RoomName")) PlayerObject.Set("RoomName", "");
			if (!PlayerObject.Contains("RoomId")) PlayerObject.Set("RoomId", "");
			if (!PlayerObject.Contains("PresenceStatus")) PlayerObject.Set("PresenceStatus", 0);
			if (!PlayerObject.Contains("LastSeenOnline")) PlayerObject.Set("LastSeenOnline", DateTime.Now);

			//social
			if (!PlayerObject.Contains("Friends")) PlayerObject.Set("Friends", new DatabaseArray());
			if (!PlayerObject.Contains("Blacklist")) PlayerObject.Set("Blacklist", new DatabaseArray());
			if (!PlayerObject.Contains("PublicProfile")) PlayerObject.Set("PublicProfile", true);

			PlayerObject.Save(savingFinished);
		}

		private void savingFinished() {
			Send(MessageID.PLAYER_INITIALIZED);
		}

		public void playerGotOnline() {
			PlayerObject.Set("PresenceStatus", 1);
			savePlayerData();
		}

		public void playerGotOffline() {
			PlayerObject.Set("PresenceStatus", 0);
			PlayerObject.Set("LastSeenOnline", DateTime.Now);
			savePlayerData();
		}

		public void playerEnteredRoom(String roomId, String roomName, bool isGameRoom) {
			PlayerObject.Set("PresenceStatus", isGameRoom ? 3 : 2);
			PlayerObject.Set("RoomName", roomName);
			PlayerObject.Set("RoomId", roomId);
			savePlayerData();
		}

		public void playerLeftRoom() {
			PlayerObject.Set("PresenceStatus", 1);
			PlayerObject.Set("RoomName", "");
			PlayerObject.Set("RoomId", "");
			savePlayerData();
		}

		public void endGameStats(bool won, int mapSize, GameSettings gameSettings, int gameDuration) {
			if (isGuest) return;

			DatabaseObject stats = PlayerObject.GetObject("Stats");

			int matchCount = stats.GetInt("TotalMatches") + 1;
			if (matchCount < 1) matchCount = 1;
			stats.Set("TotalMatches", matchCount);
			stats.Set("TotalFinished", stats.GetInt("TotalFinished") + 1);
			//stats.Set("Matches_" + mapSize + "_" + (int)gameSettings.fightType + "_" + (int)gameSettings.startType, stats.GetInt("Matches_" + mapSize + "_" + (int)gameSettings.fightType + "_" + (int)gameSettings.startType) + 1);
			//stats.Set("Finished_" + mapSize + "_" + fightType + "_" + startType, stats.GetInt("Finished_" + mapSize + "_" + fightType + "_" + startType) + 1); 
			if (won) {
				stats.Set("TotalWins", stats.GetInt("TotalWins") + 1);
				//stats.Set("Wins_" + mapSize + "_" + (int)gameSettings.fightType + "_" + (int)gameSettings.startType, stats.GetInt("Wins_" + mapSize + "_" + (int)gameSettings.fightType + "_" + (int)gameSettings.startType) + 1);
			}

			//stats.Set("RaceMatches_" + race, stats.GetInt("RaceMatches_" + race) + 1);
			if (won) {
				stats.Set("RaceWins_" + race, stats.GetInt("RaceWins_" + race) + 1);
			}

			// average oponent count
			int oponentSum = (int)(stats.GetFloat("AveragePlayerCount") * (matchCount - 1)) + gameSettings.startPlayers;

			float result = (float)oponentSum / (float)matchCount;
			stats.Set("AveragePlayerCount", result);
			Console.WriteLine("match count: " + matchCount + " oponent sum: " + oponentSum);

			// game duration
			int totalDuration = stats.GetInt("GameDurationTotal");
			totalDuration += gameDuration;
			stats.Set("GameDurationTotal", totalDuration);
			result = (float)totalDuration / (float)matchCount;
			if (System.Single.IsNaN(result))
				result = 0.0f;
			stats.Set("GameDurationAverage", (float)totalDuration / (float)matchCount);

			if (won && gameSettings.startPlayers >= 6) {
				stats.Set("Wins6Plus", stats.GetInt("Wins6Plus") + 1);
			}

			achievManager.matchEnded(gameSettings, won);

			savePlayerData();
		}

		public void updateRanking(List<Player> rankedPlayers) {
			if (this.isGuest) return;

			double variance = rankingVariance(rankingGS, rankedPlayers);
			double delta = rankingDelta(rankingGS, rankedPlayers);
			delta *= variance;

			float newVolatility = (float)rankingUpdateSigma(rankingVolatility, rankingDeviationGS, variance, delta);
			rankingVolatility = newVolatility;

			double pre_deviation = Math.Sqrt(rankingDeviationGS * rankingDeviationGS + newVolatility * newVolatility);
			double newDeviation = 1 / Math.Sqrt(1 / (pre_deviation * pre_deviation) + 1 / variance);
			
			double newRankingGS = 0;
			foreach (Player p in rankedPlayers) {
				newRankingGS += rankingQ(p.rankingDeviationGS) * (p.ratingResult - rankingE(rankingGS, p.rankingGS, p.rankingDeviationGS));
			}
			newRankingGS = newRankingGS * newDeviation * newDeviation;
			newRankingGS += rankingGS;

			rankingNew = (int)(newRankingGS * 173.7178) + 1500;

			Console.WriteLine(username + ": " + stillPlaying + " " + finishPlace);
			Console.WriteLine(rankingOriginal + " " + rankingNew);
			// make sure we don't lose ranking if we win
			if (finishPlace == 1 && rankingNew < rankingOriginal) {
				rankingNew = rankingOriginal;
			}

			if (rankingNew < rankingOriginal - 100) {
				rankingNew = rankingOriginal - 100;
			}

			PlayerObject.Set("RankingRating", rankingNew);
			PlayerObject.Set("RankingDeviation", (float)newDeviation * 173.7178f);
			PlayerObject.Set("RankingVolatility", rankingVolatility);

			savePlayerData();
		}

		private double rankingQ(double deviation) {
			return 1 / Math.Sqrt(1 + 3 * Math.Pow(deviation,2) / Math.Pow(Math.PI,2));
		}

		private double rankingE(float rating, float rating_opponent, double deviation_opponent) {
			return 1 / ( 1 + Math.Exp(-rankingQ(deviation_opponent) * (rating - rating_opponent)) );
		}

		private double rankingDelta(float playermu, List<Player>rankedPlayers) {
			double sum = 0;
			foreach (Player p in rankedPlayers)	{
				sum += rankingQ(p.rankingDeviationGS) * (p.ratingResult - rankingE(rankingGS, p.rankingGS, p.rankingDeviationGS));
			}

			return sum;
		}

		private double rankingVariance(float ranking, List<Player>rankedPlayers) {
			double sum = 0;
			foreach (Player p in rankedPlayers)	{
				double e = rankingE(ranking, p.rankingGS, p.rankingDeviationGS);
				double g = rankingQ(p.rankingDeviationGS);
				sum += g * g * e * (1 - e);
			}

			return 1/sum;
		}

		private double rankingUpdateSigma(float sigma, double deviation, double variance, double delta) {
			double x = 0;
			double a = Math.Log(Math.Pow(sigma,2), Math.E);
			double x_new = a;
			double tau = 0.7;
			double h1 = 0, h2 = 0;
			int counter = 0;
			while (Math.Abs(x - x_new) > 0.0000001) {
				if (counter == 1000) {
					errorLog.WriteError("ranking update sigma reached 1000 iterations: sigma = " + sigma + ", phi = " + deviation + ", variance = " + variance + ", delta = " + delta + ", h1 = " + h1 + ", h2 = "  + h2);
					return sigma;
				}
				x = x_new;
				double d = deviation * deviation + variance + Math.Exp(x);
				h1 = -(x - a) / (tau * tau) - 0.5 * Math.Exp(x) / d + 0.5 * Math.Exp(x) * Math.Pow((delta/d),2);
				h2 = -1 / (tau * tau) - 0.5 * Math.Exp(x) * (deviation * deviation + variance) / (d * d) + 0.5 * (delta * delta) * Math.Exp(x) * ((deviation * deviation) + variance - Math.Exp(x)) / (d * d * d);
				x_new = x-h1/h2;
				counter++;
			} 

			return Math.Exp(x/2);
		}


		public void gameAborted(int mapSize, int fightType, int startType, int gameDuration, int playerCount) {
			if (isGuest) return; 
			
			DatabaseObject stats = PlayerObject.GetObject("Stats");
			int matchCount = stats.GetInt("TotalMatches") + 1;
			if (matchCount < 1) matchCount = 1;
			//stats.Set("Matches_" + mapSize + "_" + (int)fightType + "_" + (int)startType, stats.GetInt("Matches_" + mapSize + "_" + (int)fightType + "_" + (int)startType) + 1);
			stats.Set("TotalMatches", matchCount);

			// average oponent count
			int oponentSum = (int)(stats.GetFloat("AveragePlayerCount") * (matchCount - 1)) + playerCount;
			float result = (float)oponentSum / (float)matchCount;
			if (System.Single.IsNaN(result))
				result = 0.0f;
			stats.Set("AveragePlayerCount", result);

			// game duration
			int totalDuration = stats.GetInt("GameDurationTotal");
			totalDuration += gameDuration;
			stats.Set("GameDurationTotal", totalDuration);
			result = (float)totalDuration / (float)matchCount;
			if (System.Single.IsNaN(result))
				result = 0.0f;
			stats.Set("GameDurationAverage", result);

			Console.WriteLine("match count: " + matchCount + " oponent sum: " + oponentSum);
			Console.WriteLine("match count: " + matchCount + " total duration: " + totalDuration);

			savePlayerData();
		}

		public void fightResult(bool won, bool regionConquered, bool regionLost, bool eliminated) {
			if (isGuest) return; 
			
			DatabaseObject stats = PlayerObject.GetObject("Stats");
			int fightCount = stats.GetInt("FightCount");
			int wonSum = 0;
			if(stats.GetValue("FightWinRatio").GetType() == typeof(float))
				wonSum = (int)(stats.GetFloat("FightWinRatio") * fightCount);
			else
				wonSum = (int)(stats.GetInt("FightWinRatio") * fightCount);

			fightCount++;
			if (fightCount < 1) fightCount = 1;
			stats.Set("FightCount", fightCount);
			if (won) {
				wonSum++;
			}
			
			float result = (float)wonSum / (float)fightCount;
			stats.Set("FightWinRatio", result);
			Console.WriteLine("fight count: " + fightCount + " won sum: " + wonSum);

			if (regionConquered) {
				stats.Set("RegionsConquered", stats.GetInt("RegionsConquered") + 1);
			}
			if (regionLost) {
				stats.Set("RegionsLost", stats.GetInt("RegionsLost") + 1);
			}
			if (eliminated) {
				stats.Set("PlayersEliminated", stats.GetInt("PlayersEliminated") + 1);
			}
			savePlayerData();
		}

		public void regionConquered() {
			if (isGuest) return;

			DatabaseObject stats = PlayerObject.GetObject("Stats");
			stats.Set("RegionsConquered", stats.GetInt("RegionsConquered") + 1);
			savePlayerData();

			achievManager.regionConquered();
		}

		public int getRegenWithBonus(int defaultRegen, GameSettings settings) {
			if (!settings.upgradesEnabled || bonusesDisabled) return defaultRegen;

			double bonus = 1.0;
			if (race == 101)
				bonus = 1.1;
			if (race == 104)
				bonus = 0.9;
			if (race == 105)
				bonus = 1.15;
			if (race == 106)
				bonus = 1.1;
			if (race == 107)
				bonus = 1.1;
			if (race == 108)
				bonus = 1.1;
			if (race == 118)
				bonus = 0.9;

			if(bonus == 1) return defaultRegen;

			return bonus > 1.0 ? (int)Math.Floor(defaultRegen * bonus) : (int)Math.Ceiling(defaultRegen * bonus);
		}

		public int getDefenseWithBonus(int defaultDefense, GameSettings settings, bool usingDefenseBoost, Map map) {
			if (!settings.upgradesEnabled || bonusesDisabled) return defaultDefense;

			double bonus = 1.0;
			if (race == 103)
				bonus = 1.05;
			if (race == 104)
				bonus = 1.05;
			if (race == 105)
				bonus = 0.95;
			if (race == 106)
				bonus = 1.05;
			if (race == 108)
				bonus = 1.05;
			if (race == 118)
				bonus = 0.95;
			if (race == 117 && usingDefenseBoost)
				bonus = 1.1;
			if (race == 121) {
				if (strength <= 5)
					bonus = 1.15;
				else {
					int max = map.GetRegionCount() / 2;
					if (strength >= max)
						bonus = 1;
					else
						bonus = 1 + 0.15 - 0.15 * (strength - 5.0) / (max - 5.0);
				}
			}

			if(bonus == 1) return defaultDefense;

			return bonus > 1.0 ? (int)Math.Floor(defaultDefense * bonus) : (int)Math.Ceiling(defaultDefense * bonus);
		}

		public int getAttackWithBonus(int defaultAttack, GameSettings settings, int attackerStrength, int defenderStrength, bool usingAttackBoost, Map map, bool hasDefenseBoost) {
			if (!settings.upgradesEnabled || bonusesDisabled) return defaultAttack;

			double bonus = 1.0;
			if (race == 102)
				bonus = 1.05;
			if (race == 104)
				bonus = 1.05;
			if (race == 105)
				bonus = 0.95;
			if (race == 107)
				bonus = 1.05;
			if (race == 108)
				bonus = 1.05;
			if (race == 114 && attackerStrength < defenderStrength)
				bonus = 1.15;
			if (race == 118)
				bonus = 0.95;
			if (race == 115 && usingAttackBoost)
				bonus = 1.1;
			if (race == 120) {
				if (strength <= 5)
					bonus = 1.15;
				else {
					int max = map.GetRegionCount() / 2;
					if (strength >= max)
						bonus = 1;
					else
						bonus = 1 + 0.15 - 0.15* (strength - 5.0) / (max - 5.0);
				}
			}
			if (race == 122) {
				bonus = hasDefenseBoost ? 1.2 : 1.0;
			}

			Console.WriteLine("attack bonus: " + bonus);

			if (bonus == 1) return defaultAttack;

			return bonus > 1.0 ? (int)Math.Floor(defaultAttack * bonus) : (int)Math.Ceiling(defaultAttack * bonus);
		}

		public void initConsumablesForGame(GameSettings settings, int regionCount) {
			//if (isGuest || !settings.upgradesEnabled) {
			if(isGuest || !settings.boostsEnabled) {
				freeAttackBoosts = freeDefenseBoosts = attackBoostsTotal = defenseBoostsTotal = 0;
			}
			else {
				int amount;
				if (settings.mapGroup == 100) {
					amount = settings.mapIndex + 1;
				}
				else {
					if (regionCount < 20) amount = 1;
					else if (regionCount < 30) amount = 2;
					else if (regionCount < 50) amount = 3;
					else if (regionCount < 100) amount = 4;
					else amount = 5;
				}
				freeAttackBoosts = freeDefenseBoosts = amount;

				attackBoosts = attackBoostsTotal < amount ? attackBoostsTotal : amount;
				defenseBoosts = defenseBoostsTotal < amount ? defenseBoostsTotal : amount;

				// snowmen give you more defense boosts
				if(race == 109)
					defenseBoosts = defenseBoostsTotal < amount + 2 ? defenseBoostsTotal : amount + 2;
				// reindeers give you more attack boosts
				if (race == 110)
					attackBoosts = attackBoostsTotal < amount + 2 ? attackBoostsTotal : amount + 2;
			}
		}

		public void consumeDefenseBoost() {
			if(freeDefenseBoosts <= 0 && defenseBoosts <= 0) return;

			if (freeDefenseBoosts > 0) {
				freeDefenseBoosts--;
			}
			else {
				defenseBoosts--;
				defenseBoostsTotal--;
				PlayerObject.Set("DefenseBoosts", defenseBoostsTotal);
				savePlayerData();
			}
		}

		public void consumeAttackBoost() {
			if (freeAttackBoosts <= 0 && attackBoosts <= 0) return;

			if (freeAttackBoosts > 0) {
				freeAttackBoosts--;
			}
			else {
				attackBoosts--;
				attackBoostsTotal--;
				PlayerObject.Set("AttackBoosts", attackBoostsTotal);
				savePlayerData();
			}
		}

		public void tutorialFinished() {
			if (PlayerObject.Contains("TutorialFinished")) return;
			PlayerObject.Set("TutorialFinished", 1);
			savePlayerData();
		}

		public void setRace(int raceID) {
			// check if race is unlocked
			bool unlocked = false;
			if (raceID == 100) {
				unlocked = isPremium();
			}
			if (raceID < 3) {
				unlocked = true;
			}
			if(raceID == 3) {
				unlocked = PayVault.Has("RaceSoldiers");
			}
			if(raceID == 4) {
				unlocked = PayVault.Has("RaceRobots");
			}
			if(raceID == 5) {
				unlocked = PayVault.Has("RaceElementals");
			}
			if(raceID == 6) {
				unlocked = PayVault.Has("RacePirates");
			}
			if(raceID == 7) {
				unlocked = PayVault.Has("RaceNinjas");
			}
			if (raceID == 101) {
				unlocked = PayVault.Has("RaceInsectoids");
			}
			if (raceID == 102) {
				unlocked = PayVault.Has("RaceDemons");
			}
			if (raceID == 103) {
				unlocked = PayVault.Has("RaceAngels");
			}
			if (raceID == 104) {
				unlocked = PayVault.Has("RaceVampires");
			}
			if (raceID == 105) {
				unlocked = PayVault.Has("RacePumpkins");
			}
			if (raceID == 106) {
				unlocked = PayVault.Has("RaceReptiles");
			}
			if (raceID == 107) {
				unlocked = PayVault.Has("RaceArachnids");
			}
			if (raceID == 108) {
				unlocked = PayVault.Has("RaceDragons");
			}
			if (raceID == 109) {
				unlocked = PayVault.Has("RaceSnowmen");
			}
			if (raceID == 110) {
				unlocked = PayVault.Has("RaceReindeers");
			}
			if (raceID == 111) {
				unlocked = PayVault.Has("RaceSantas");
			}
			if (raceID == 112) {
				unlocked = PayVault.Has("RaceNatives");
			}
			if (raceID == 113) {
				unlocked = PayVault.Has("RaceUndead");
			}
			if (raceID == 114) {
				unlocked = PayVault.Has("RaceTerminators");
			}
			if (raceID == 115) {
				unlocked = PayVault.Has("RaceBladeMasters");
			}
			if (raceID == 116) {
				unlocked = PayVault.Has("RaceCyborgs");
			}
			if (raceID == 117) {
				unlocked = PayVault.Has("RaceDarkKnights");
			}
			if (raceID == 118) {
				unlocked = PayVault.Has("RaceTeddyBears");
			}
			if (raceID == 119) {
				unlocked = PayVault.Has("RaceWatchmen");
			}
			if (raceID == 120) {
				unlocked = PayVault.Has("RaceWerewolves");
			}
			if (raceID == 121) {
				unlocked = PayVault.Has("RaceFrankensteins");
			}
			if (raceID == 122) {
				unlocked = PayVault.Has("RaceTannenbaums");
			}
			if (raceID == 123) {
				unlocked = PayVault.Has("RaceSnowflakes");
			}


			if (unlocked) {
				race = raceID;
				PlayerObject.Set("Race", raceID);
				savePlayerData();
			}
		}

		public void setBackground(int bg) {
			PlayerObject.Set("Background", bg);
			savePlayerData();
		}

		public void savePlayerData() {
			if (playerObjectSaving) {
				playerObjectDirty = true;
			}
			else {
				playerObjectDirty = false;
				playerObjectSaving = true;
				PlayerObject.Save(savingPOFinished, savingPOFailed);
			}
		}

		private void savingPOFinished() {
			if (playerObjectDirty) {
				playerObjectDirty = false;
				PlayerObject.Save(savingPOFinished, savingPOFailed);
			}
			else {
				playerObjectSaving = false;
			}
		}

		private void savingPOFailed(PlayerIOError error) {
			playerObjectDirty = false;
			PlayerObject.Save(savingPOFinished, savingPOFailed);
		}

		public void addLastPlayedMap(String mapKey) {
			if (isGuest) return;

			DatabaseArray maps = PlayerObject.GetArray("LastPlayedMaps");
			DatabaseObject mapEntry = null;
			DatabaseObject oldestEntry = null;
			int oldestIndex = 0;
			for (int i = 0; i < maps.Count; ++i) {
				DatabaseObject entry = maps.GetObject(i.ToString());
				if (entry.Contains("Map")) {
					if (entry.GetString("Map") == mapKey) {
						mapEntry = entry;
					}
					else {
						if (oldestEntry == null || DateTime.Compare(entry.GetDateTime("Date"), oldestEntry.GetDateTime("Date")) < 0) {
							oldestEntry = entry;
							oldestIndex = i;
						}
					}
				}
			}

			// remove oldest entry if list is full
			//if (maps.Count > 8) {
			//	maps.Remove(oldestIndex.ToString());
			//}
			// if current map is already in last played list, just update date
			if (mapEntry != null) {
				mapEntry.Set("Date", DateTime.Now);
			}
			else {
				DatabaseObject entry = new DatabaseObject();
				entry.Set("Map", mapKey);
				entry.Set("Date", DateTime.Now);
				maps.Add(entry);
			}

			PlayerObject.Remove("LastPlayedMaps");
			//sort the array from the latest to oldest
			DatabaseArray newMaps = new DatabaseArray();
			int newestIndex = 0;
			bool found = false;
			do {
				found = false;
				newestIndex = 0;
				DatabaseObject newestEntry = null;
				//foreach(DatabaseObject entry in maps) {
				for (int i = 0; i < maps.Count; ++i) {
					if(!maps.Contains(i.ToString())) continue;
					DatabaseObject entry = maps.GetObject(i.ToString());
					if (!entry.Contains("Date")) continue;

					if (newestEntry == null || DateTime.Compare(entry.GetDateTime("Date"), newestEntry.GetDateTime("Date")) > 0) {
						newestEntry = entry;
						newestIndex = i;
						found = true;
					}
				}
				if (found) {
					DatabaseObject tmp = maps.GetObject(newestIndex.ToString());
					maps.Remove(newestIndex.ToString());
					bool duplicate = false;
					foreach(DatabaseObject dbo in newMaps) {
						if (dbo.GetString("Map") == tmp.GetString("Map")) {
							duplicate = true;
							break;
						}
					}
					if (duplicate)
						continue;

					DatabaseObject tmp2 = new DatabaseObject();
					tmp2.Set("Map", tmp.GetString("Map"));
					tmp2.Set("Date", tmp.GetDateTime("Date"));
					//newMaps.Add(tmp2);
					newMaps.Insert(0, tmp2);
				}
			} while (found && newMaps.Count < 8);

			//newMaps = (DatabaseArray)newMaps.Reverse();

			PlayerObject.Set("LastPlayedMaps", newMaps);

			/*maps = PlayerObject.GetArray("LastPlayedMaps");
			for (int i = 0; i < maps.Count; i++) {
				Console.WriteLine(maps.GetObject(i).GetString("Map"));
			}*/

			savePlayerData();
		}

		public void ban(int duration, String reason, String mod) {
			if (duration == -1) {
				PlayerObject.Set("Banned", true);
			}
			else {
				PlayerObject.Set("BannedUntil", DateTime.Now.AddDays(duration));
			}

			PlayerObject.Set("BannedReason", reason);

			DatabaseObject banEntry = new DatabaseObject();
			banEntry.Set("D", DateTime.Now);
			banEntry.Set("Dur", duration);
			banEntry.Set("R", reason);
			banEntry.Set("M", mod);

			PlayerObject.GetArray("BanHistory").Add(banEntry);

			savePlayerData();
			//PlayerObject.Save();
		}

		public void warn(String reason, String mod) {
			DatabaseObject banEntry = new DatabaseObject();
			banEntry.Set("D", DateTime.Now);
			banEntry.Set("R", reason);
			banEntry.Set("M", mod);

			PlayerObject.GetArray("WarnHistory").Add(banEntry);

			//PlayerObject.Save();
			savePlayerData();
		}

		public string list() {
			String result = "";
			if (isGuest) {
				result = "Listing data for " + username + ":\n";
			}
			else {
				result = "Listing data for " + username + " (key " + PlayerObject.Key + "):\n";

				DatabaseArray bans = PlayerObject.GetArray("BanHistory");
				if (bans.Count > 0) {
					result += "Bans (" + bans.Count + "):\n";
					foreach (DatabaseObject ban in bans) {
						result += String.Format("{0:d.M.yyyy HH:mm:ss}", ban.GetDateTime("D"));
						result += " - (" + ban.GetInt("Dur") + "days) " + ban.GetString("R");
						result += " (" + ban.GetString("M") + ")\n";
					}
				}
				else {
					result += "No bans found\n";
				}

				DatabaseArray warns = PlayerObject.GetArray("WarnHistory");
				if (warns.Count > 0) {
					result += "Warns (" + warns.Count + "):\n";
					foreach (DatabaseObject warn in warns) {
						result += String.Format("{0:d.M.yyyy HH:mm:ss}", warn.GetDateTime("D"));
						result += " - " + warn.GetString("R");
						result += " (" + warn.GetString("M") + ")\n";
					}
				}
				else {
					result += "No warns found\n";
				}
			}

			result += "current IP: " + IPAddress.ToString() + "\n";

			return result;
		}

		public void increaseIngameXP(int startPlayerCount, bool weakerBonus) {
			ingameXP += (startPlayerCount * 0.3f) * (weakerBonus ? 2 : 1);
		}

		public void rollWin(int attackDice, int defenseDice) {
			if (isGuest) return;

			if (attackDice <= defenseDice) {
				DatabaseObject stats = PlayerObject.GetObject("Stats");
				stats.Set("ConsecutiveRollWins", stats.GetInt("ConsecutiveRollWins") + 1);

				achievManager.fightFinished();

				savePlayerData();
			}
		}

		public void rollLose(int attackDice, int defenseDice) {
			if (isGuest) return;

			if (attackDice <= defenseDice) {
				DatabaseObject stats = PlayerObject.GetObject("Stats");
				stats.Set("ConsecutiveRollWins", 0);

				achievManager.fightFinished();

				savePlayerData();
			}
		}

		public bool disablesBonuses() {
			return race == 123;
		}
	}
}
