using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds
{
	public class GameSettings
	{
		public enum StartType { FULL_MAP, CONQUER };
		public enum TroopsDistributionType { RANDOM, MANUAL, BORDERS };
		public enum FightType { HARDCORE, ATTRITION, ONEONONE, ONEONONE_QUICK };

		public StartType startType;
		public TroopsDistributionType troopsDistType;
		public FightType fightType;
		public int maxPlayers;		// max number of players that could connect to game
		public int startPlayers;	// number of players that actually connected

		public int mapGroup;		// map pack (99 - default pack, 100 - random map, 101 - user map)
		public int mapIndex;		// map from pack (for random maps 0 - S, 4 - XXL)
		public String userMap = "";

		public bool upgradesEnabled;
		public bool boostsEnabled;
	}
}
