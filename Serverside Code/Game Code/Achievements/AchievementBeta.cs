using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds.Achievements
{
	class AchievementBeta : Achievement
	{
		//public AchievementBeta() {
			
		//}

		//override public void init(DatabaseObject achievData, AchievementManager manager) {
		//	base.init(achievData, manager);
		//}

		public override void checkConditions() {
			if(manager.owner.PlayerObject.GetBool("BetaTester"))
				awardAchievement();
		}
	}
}
