using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds.Achievements
{
	class AchievementConquer : Achievement
	{
		private int regionsToConquer;

		public AchievementConquer(int condition) {
			regionsToConquer = condition;
		}

		public override void checkConditions() {
			if (manager.owner.PlayerObject.GetObject("Stats").GetInt("RegionsConquered") >= regionsToConquer)
				awardAchievement();
		}

		override public void regionConquered() {
			if (manager.owner.PlayerObject.GetObject("Stats").GetInt("RegionsConquered") >= regionsToConquer)
				awardAchievement();
		}
	}
}
