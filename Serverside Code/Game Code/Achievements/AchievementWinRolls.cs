using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds.Achievements
{
	class AchievementWinRolls : Achievement
	{
		private int winCount;

		public AchievementWinRolls(int condition) {
			winCount = condition;
		}

		public override void checkConditions() {
			DatabaseObject stats = manager.owner.PlayerObject.GetObject("Stats");
			if (stats.GetInt("ConsecutiveRollWins") >= winCount) {
				awardAchievement();
			}
		}

		public override void fightFinished() {
			checkConditions();
		}
	}
}
