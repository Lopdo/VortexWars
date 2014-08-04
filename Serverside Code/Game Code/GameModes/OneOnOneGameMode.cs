using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds.GameModes
{
	class OneOnOneGameMode : GameMode {
		public override List<int> ResolveFight(Region source, Region target, GameSettings settings, Map map) {
			List<int> result = new List<int>();
			// add game mode identifier
			//result.Add(2);

			int prevSourceDice = source.dice;
			int prevTargetDice = target.dice;

			List<int> throws = new List<int>();

			while(source.dice > 1 && target.dice > 0) {
				int attackerThrow = rand.Next(6) + 1;
				int defenderThrow = rand.Next(6) + 1;
				if (attackerThrow == defenderThrow) {
					continue;
				}
				if(attackerThrow > defenderThrow) {
					target.dice--;
				}
				else {
					source.dice--;
				}
				throws.Add(attackerThrow);
				throws.Add(defenderThrow);
			}

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

			result.Add(throws.Count);
			foreach(int i in throws) {
				result.Add(i);
			}
			return result;
		}

		public override int fightScreenDuration(int throwsCount) {
			// remove non-throw data
			throwsCount -= 2;
			return 2 * (throwsCount / 2);
		}
	}
}
