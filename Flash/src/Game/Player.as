package Game
{
	import Game.Races.Race;
	
	import playerio.DatabaseObject;

	public class Player
	{
		public var ID:int;
		public var name:String;
		public var playerKey:String;
		public var colorID:int;
		public var strength:int;
		public var race:Race;
		public var rating:int;
		public var stackedDice:int = 0;
		public var level:int = 0;
		public var attackBoosts:int, defenseBoosts:int = 0;
		public var freeAttackBoosts:int, freeDefenseBoosts:int = 0;
		
		public function Player(id:int, name:String, color:int, strength:int, race:int, level:int, attackBoosts:int, defenseBoosts:int, freeAttackBoosts:int, freeDefenseBoosts:int, playerKey:String = "", rating:int = 0)
		{
			ID = id;
			this.name = name;
			this.playerKey = playerKey;
			colorID = color;
			this.strength = strength;
			this.race = Race.Create(race);
			this.level = level;
			this.attackBoosts = attackBoosts;
			this.defenseBoosts = defenseBoosts;
			this.freeAttackBoosts = freeAttackBoosts;
			this.freeDefenseBoosts = freeDefenseBoosts;
			this.rating = rating;
		}
	}
}