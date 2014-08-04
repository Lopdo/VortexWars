using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds.Achievements
{
	class AchievementWins : Achievement
	{
		private int winCount;

		public AchievementWins(int condition) {
			winCount = condition;
		}

		public override void checkConditions() {
			DatabaseObject stats = manager.owner.PlayerObject.GetObject("Stats");
			if (stats.GetInt("Wins6Plus") >= winCount) {
				awardAchievement();
			}
		}

		public override void matchEnded(GameSettings settings, bool won) {
			if (!won) return;
			if (settings.startPlayers < 6) return;

			DatabaseObject stats = manager.owner.PlayerObject.GetObject("Stats");
			if (stats.GetInt("Wins6Plus") >= winCount - 1) {
				awardAchievement();
			}
		}
	}
}
