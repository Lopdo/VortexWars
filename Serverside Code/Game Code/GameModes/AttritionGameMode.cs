using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds.GameModes {
	class AttritionGameMode : GameMode {
		public override List<int> ResolveFight(Region source, Region target, GameSettings settings, Map map) {
			List<int> result = new List<int>();
			// add number of throws (last one is attrition)
			result.Add(3);

			List<int> throws = new List<int>();

			List<int> attackerThrows = new List<int>();
			List<int> defenderThrows = new List<int>();

			int sourceDice = source.dice;
			int targetDice = target.dice;
			if (target.owner != null && target.owner.race == 112 && targetDice == 1 && !target.owner.bonusesDisabled && settings.upgradesEnabled)
				targetDice = 2;

			int attackerThrow = 0;
			int defenderThrow = 0;
			int battlesCount = 0;
			do {
				battlesCount++;
				attackerThrow = 0;
				defenderThrow = 0;
				attackerThrows.Clear();
				defenderThrows.Clear();

				for (int i = 0; i < sourceDice; ++i) {
					int t = rand.Next(6) + 1;
					attackerThrow += t;
					attackerThrows.Add(t);
				}
				for (int i = 0; i < targetDice; ++i) {
					int t = rand.Next(6) + 1;
					defenderThrow += t;
					defenderThrows.Add(t);
				}
				attackerThrow = source.owner.getAttackWithBonus(attackerThrow, settings, source.dice, target.dice, source.owner.attackBoostActive, map, source.hasDefenseBoost);
				
				if (target.owner != null) {
					defenderThrow = target.owner.getDefenseWithBonus(defenderThrow, settings, target.hasDefenseBoost, map);
				}
				throws.Add(attackerThrow);
				throws.Add(defenderThrow);
				Console.WriteLine("attacker: " + attackerThrow + " defender: " + defenderThrow);
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

			int attrition = CalculateAttrition(attackerThrows, defenderThrows);

			if (defenderThrow < attackerThrow) {
				target.dice = source.dice - 1;
				target.owner = source.owner;
				if(target.dice > attrition - 1)
					target.dice = attrition - 1;
				if(target.dice < 1) {
					target.dice = 1;
				}
			}
			else {
				if (target.dice > attrition)
					target.dice = attrition;
				if (target.dice < 1) {
					target.dice = 1;
				}
			}
			source.dice = 1;

			result.Add(attrition);

			return result;
		}

		private int CalculateAttrition(List<int> attackerThrows, List<int> defenderThrows) {

			while (attackerThrows.Count > 0 && defenderThrows.Count > 0) {
				attackerThrows.Sort();
				defenderThrows.Sort();

				int att = attackerThrows[attackerThrows.Count - 1];
				int def = defenderThrows[defenderThrows.Count - 1];

				attackerThrows.RemoveAt(attackerThrows.Count - 1);
				defenderThrows.RemoveAt(defenderThrows.Count - 1);
				if (att > def) {
					attackerThrows.Add(att - def);
				}
				else if (att < def) {
					defenderThrows.Add(def - att);
				}
			}

			return attackerThrows.Count > 0 ? attackerThrows.Count : defenderThrows.Count;
		}

		public override int fightScreenDuration(int throwsCount) {
			return 2;
		}
	}
}
