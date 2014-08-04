using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds.GameModes
{
	class OneOnOneQuickGameMode : GameMode {
		public override List<int> ResolveFight(Region source, Region target, GameSettings settings, Map map) {
			List<int> result = new List<int>();
			result.Add(2);
			int prevSourceDice = source.dice;
			int prevTargetDice = target.dice;

			int wins = 0, loses = 0;

			List<int> throws = new List<int>();
			int battlesCount = 0;
			do {
				battlesCount++;
				source.dice = prevSourceDice;
				target.dice = prevTargetDice;
				wins = loses = 0;

				while (source.dice > 1 && target.dice > 0) {
					int attackerThrow = rand.Next(6) + 1;
					int defenderThrow = rand.Next(6) + 1;
					if (attackerThrow == defenderThrow) {
						continue;
					}
					if (attackerThrow > defenderThrow) {
						target.dice--;
						wins++;
					}
					else {
						source.dice--;
						loses++;
					}

				}
				throws.Add(wins);
				throws.Add(loses);
				Console.WriteLine("target: " + target.dice + "source: " + source.dice);
			} while (defenseBoostApplies(target.dice == 0, target) || attackBoostApplies(source.dice == 1 && target.dice > 0, source));

			// award xp if attack was succesful
			if (target.dice == 0) {
				source.owner.increaseIngameXP(settings.startPlayers, prevSourceDice < prevTargetDice);
				/*if (prevSourceDice < prevTargetDice) {
					source.owner.ingameXP += 2;
				}
				else {
					source.owner.ingameXP += 1;
				}*/
				source.owner.regionsConquered++;
			}

			if (target.dice == 0) {
				target.dice = source.dice - 1;
				if(target.dice < 1) {
					target.dice = 1;
				}
				target.owner = source.owner;
			}
			source.dice = 1;

			result.Add(battlesCount);
			for (int i = 0; i < throws.Count; i++) {
				result.Add(throws[i]);
			}
			//result.Add(throws);
			//result.Add(wins);
			//result.Add(loses);

			return result;
		}

		public override int fightScreenDuration(int throwsCount) {
			return 2;
		}
	}
}
