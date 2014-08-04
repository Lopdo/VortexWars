using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds.Achievements
{
	public class Achievement
	{
		public String name;
		public String niceName;
		public int xpReward;
		public int shardReward;
		protected int difficulty;
		public int Id;

		protected AchievementManager manager;

		virtual public void init(DatabaseObject achievData, AchievementManager m) {
			manager = m;

			name = achievData.Key;
			niceName = achievData.GetString("NiceName");

			xpReward = achievData.GetInt("XPReward");
			shardReward = achievData.GetInt("ShardReward");
			Id = achievData.GetInt("ID");
		}

		virtual public void checkConditions() {}

		protected void awardAchievement() {
			manager.awardAchievement(this);
		}

		//virtual public void fightWon(GameSettings settings, int attackerThrow, int defenderThrow) {

		//}
		virtual public void howToPlayVisited() { }

		virtual public void regionConquered() { }
		virtual public void fightFinished() { }
		virtual public void matchEnded(GameSettings settings, bool won) { }
	}
}
