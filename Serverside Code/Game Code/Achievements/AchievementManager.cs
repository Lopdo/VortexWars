using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds.Achievements
{
	public class AchievementManager
	{
		private Dictionary<String, Achievement> achievList = new Dictionary<String, Achievement> { 
			//{"AchievementBeta", new AchievementBeta()},
			{"AchievementConquer50", new AchievementConquer(50)},
			{"AchievementConquer250", new AchievementConquer(250)},
			{"AchievementConquer1000", new AchievementConquer(1000)},
			{"AchievementConquer5000", new AchievementConquer(5000)},
			{"AchievementConquer20000", new AchievementConquer(20000)},
			{"AchievementHowToPlay", new AchievementHowToPlay()},
			{"AchievementRaceWins3", new AchievementRaceWins(3)},
			{"AchievementRaceWins5", new AchievementRaceWins(5)},
			{"AchievementRaceWins8", new AchievementRaceWins(8)},
			{"AchievementRaceWins10", new AchievementRaceWins(10)},
			{"AchievementRaceWins15", new AchievementRaceWins(15)},
			{"AchievementWins10", new AchievementWins(10)},
			{"AchievementWins50", new AchievementWins(50)},
			{"AchievementWins100", new AchievementWins(100)},
			{"AchievementWins500", new AchievementWins(500)},
			{"AchievementWins2000", new AchievementWins(2000)},
			{"AchievementRollWins3", new AchievementWinRolls(1)},
			{"AchievementRollWins5", new AchievementWinRolls(5)},
			{"AchievementRollWins10", new AchievementWinRolls(10)}
		};

		protected BigDB bigDB;
		public Player owner;

		private List<Achievement> achievements = new List<Achievement>();

		public AchievementManager(BigDB db, Player player) {
			bigDB = db;
			owner = player;

			// load data for all achievements from Database
			bigDB.LoadRange("Achievements", "IDs", null, null, null, 100, delegate(DatabaseObject[] results) {
				if (results != null) {
					foreach (DatabaseObject achievData in results) {
						if(owner.achievements.Contains(achievData.Key)) continue;

						Achievement achiev = achievList[achievData.Key];
						achiev.init(achievData, this);
						achievements.Add(achiev);
						achiev.checkConditions();
					}
				}
				else {
					// todo
				}
			}, delegate(PlayerIOError error) {
				// todo
				Console.WriteLine(error.Message);
			});
		}

		public void awardAchievement(Achievement achiev) {
			bigDB.Load("PlayerObjects", owner.ConnectUserId, delegate(DatabaseObject result) {
				DatabaseObject achievs = result.GetObject("Achievements");
				if (achievs.Contains(achiev.name)) return;

				DatabaseObject achievObject = new DatabaseObject();
				achievObject.Set("Date", DateTime.Now);
				owner.achievements.Set(achiev.name, achievObject);
				owner.awardXP(achiev.xpReward, achiev.shardReward);
				owner.PlayerObject.Save(true, delegate()
				{
					owner.Send(MessageID.ACHIEVEMENT_UNLOCKED, achiev.Id, achiev.name, achiev.xpReward, achiev.shardReward);
					achievements.Remove(achiev);
				});
			});
		}

		/*public void fightWon(GameSettings settings, int attackerThrow, int defenderThrow) {
			foreach (Achievement achiev in achievements) {
				achiev.fightWon(settings, attackerThrow, defenderThrow);
			}
		}*/
		public void howToPlayVisited() {
			foreach (Achievement achiev in achievements) {
				achiev.howToPlayVisited();
			}
		}

		public void regionConquered() {
			foreach (Achievement achiev in achievements) {
				achiev.regionConquered();
			}
		}

		public void fightFinished() {
			foreach (Achievement achiev in achievements) {
				achiev.fightFinished();
			}
		}

		public void matchEnded(GameSettings gameSettings, bool won) {
			foreach (Achievement achiev in achievements) {
				achiev.matchEnded(gameSettings, won);
			}
		}
	}
}
