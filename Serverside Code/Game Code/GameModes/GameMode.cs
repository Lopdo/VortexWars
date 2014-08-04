using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds.GameModes
{
	abstract class GameMode {
		
		protected Random rand;
		
		protected GameMode() {
			rand = new Random();

		}

		protected GameMode(Random r) {
			rand = r;
		}

		public static GameMode Create(GameSettings.FightType fightType) {
			switch(fightType) {
				case GameSettings.FightType.HARDCORE: return new WTAGameMode();
				case GameSettings.FightType.ATTRITION: return new AttritionGameMode();
				case GameSettings.FightType.ONEONONE: return new OneOnOneGameMode();
				case GameSettings.FightType.ONEONONE_QUICK: return new OneOnOneQuickGameMode();
			}
			return null;
		}

		protected bool defenseBoostApplies(bool attackerWon, Region target) {
			if (attackerWon) {
				if (target.hasDefenseBoost) {
					target.hasDefenseBoost = false;
					return true;
				}
			}

			return false;
		}

		protected bool attackBoostApplies(bool defenderWon, Region source) {
			if (defenderWon) {
				if (source.owner.attackBoostActive) {
					source.owner.attackBoostActive = false;
					return true;
				}
			}

			return false;
		}

		public abstract List<int> ResolveFight(Region source, Region target, GameSettings settings, Map map);

		// in seconds
		public abstract int fightScreenDuration(int throwsCount);
	}
}
