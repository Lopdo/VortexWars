using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds.GameModes
{
	class WTAGameMode : GameMode {

		public override List<int> ResolveFight(Region source, Region target, GameSettings settings, Map map) {
			List<int> result = new List<int>();
			// add number of throws
			result.Add(2);

			int battlesCount = 0;
			List<int> throws = new List<int>();

			int sourceDice = source.dice;
			int targetDice = target.dice;
			if (target.owner != null && target.owner.race == 112 && targetDice == 1 && !target.owner.bonusesDisabled && settings.upgradesEnabled)
				targetDice = 2;

			int attackerThrow = 0;
			int defenderThrow = 0;

			do {
				battlesCount++;
				attackerThrow = 0;
				defenderThrow = 0;
				for (int i = 0; i < sourceDice; ++i) {
					attackerThrow += rand.Next(6) + 1;
				}
				for (int i = 0; i < targetDice; ++i) {
					defenderThrow += rand.Next(6) + 1;
				}
				attackerThrow = source.owner.getAttackWithBonus(attackerThrow, settings, sourceDice, targetDice, source.owner.attackBoostActive, map, source.hasDefenseBoost);

				if (target.owner != null) {
					defenderThrow = target.owner.getDefenseWithBonus(defenderThrow, settings, target.hasDefenseBoost, map);
				}

				throws.Add(attackerThrow);
				throws.Add(defenderThrow);

			} while (defenseBoostApplies(attackerThrow > defenderThrow, target) || attackBoostApplies(attackerThrow <= defenderThrow, source));

			result.Add(battlesCount);
			for (int i = 0; i < throws.Count; i++) {
				result.Add(throws[i]);
			}
			//result.Add(attackerThrow);
			//result.Add(defenderThrow);

			// award xp if attack was succesful
			if (attackerThrow > defenderThrow) {
				source.owner.increaseIngameXP(settings.startPlayers, source.dice < target.dice);
				source.owner.rollWin(source.dice, target.dice);
				source.owner.regionsConquered++;
			}
			else {
				source.owner.rollLose(source.dice, target.dice);
			}

			if (defenderThrow < attackerThrow) {
				target.dice = source.dice - 1;
				target.owner = source.owner;
			}
			source.dice = 1;

			return result;
		}

		public override int fightScreenDuration(int throwsCount) {
			return 2;
		}
	}
}
