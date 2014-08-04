using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using PlayerIO.GameLibrary;

namespace Wargrounds.Achievements
{
	class AchievementRaceWins : Achievement
	{
		private int raceWins;

		public AchievementRaceWins(int condition) {
			raceWins = condition;
		}

		public override void checkConditions() {
			DatabaseObject stats = manager.owner.PlayerObject.GetObject("Stats");
			int counter = 0;
			for (int i = 0; i < 8; i++) {
				if (stats.GetInt("RaceWins_" + i) > 0) {
					counter++;
				}
			}
			for (int i = 100; i < 121; i++) {
				if (stats.GetInt("RaceWins_" + i) > 0) {
					counter++;
				}
			}

			if (counter >= raceWins) {
				awardAchievement();
			}
		}

		public override void matchEnded(GameSettings settings, bool won) {
			if (!won) return;

			DatabaseObject stats = manager.owner.PlayerObject.GetObject("Stats");
			int counter = 0;
			for (int i = 0; i < 8; i++) {
				if (stats.GetInt("RaceWins_" + i) > 0 || i == manager.owner.race) {
					counter++;
				}
			}
			for (int i = 100; i < 121; i++) {
				if (stats.GetInt("RaceWins_" + i) > 0 || i == manager.owner.race) {
					counter++;
				}
			}

			if (counter >= raceWins) {
				awardAchievement();
			}
		}
	}
}
