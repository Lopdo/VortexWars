using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds.Achievements
{
	class AchievementHowToPlay : Achievement
	{
		public override void howToPlayVisited() {
			awardAchievement();
		}
	}
}
