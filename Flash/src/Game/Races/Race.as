package Game.Races
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;

	public class Race
	{
		public static const RACE_ELVES:int = 0;
		public static const RACE_SNOW_GIANTS:int = 1;
		public static const RACE_LEGIONAIRES:int = 2;
		public static const RACE_SOLDIERS:int = 3;
		public static const RACE_ROBOTS:int = 4;
		public static const RACE_ELEMENTALS:int = 5;
		public static const RACE_PIRATES:int = 6;
		public static const RACE_NINJAS:int = 7;
		public static const RACE_INSECTOIDS:int = 101;
		public static const RACE_DEMONS:int = 102;
		public static const RACE_ANGELS:int = 103;
		public static const RACE_ALIENS:int = 100;
		public static const RACE_VAMPIRES:int = 104;
		public static const RACE_PUMPKINS:int = 105;
		public static const RACE_REPTILES:int = 106;
		public static const RACE_ARACHNIDS:int = 107;
		public static const RACE_DRAGONS:int = 108;
		public static const RACE_SNOWMEN:int = 109;
		public static const RACE_REINDEERS:int = 110;
		public static const RACE_SANTAS:int = 111;
		public static const RACE_NATIVES:int = 112;
		public static const RACE_UNDEAD:int = 113;
		public static const RACE_TERMINATORS:int = 114;
		public static const RACE_BLADE_MASTERS:int = 115;
		public static const RACE_CYBORGS:int = 116;
		public static const RACE_DARK_KNIGHTS:int = 117;
		public static const RACE_TEDDY_BEARS:int = 118;
		public static const RACE_WATCHMEN:int = 119;
		public static const RACE_WEREWOLVES:int = 120;
		public static const RACE_FRANKENSTEINS:int = 121;
		public static const RACE_TANNENBAUMS:int = 122;
		public static const RACE_SNOWFLAKES:int = 123;
		
		public var ID:int;
		public var name:String, shopName:String;
		public var description:String;
		public var bonusDesc:String = "";
		public var unlockLevel:int = 0;
		
		public var regionImage:Bitmap;
		public var symbolSmall:Bitmap;
		public var profileImage:Bitmap;
		
		//public static var profileImageLocked:Bitmap = ResList.GetArtResource("race_profileImage_locked");
		
		public function Race()
		{
		}
		
		public static function Create(race:int):Race {
			switch(race) {
				//case 0: return new RaceRobots(); break;
				case RACE_ELVES: return new RaceElves(); break;
				case RACE_SNOW_GIANTS: return new RaceSnowGiants(); break;
				case RACE_LEGIONAIRES: return new RaceLegionaires(); break;
				case RACE_SOLDIERS: return new RaceSoldiers(); break;
				case RACE_ROBOTS: return new RaceRobots(); break;
				case RACE_ELEMENTALS: return new RaceElementals(); break;
				case RACE_PIRATES: return new RacePirates(); break;
				case RACE_NINJAS: return new RaceNinjas(); break;
				case RACE_INSECTOIDS: return new RaceInsektoids(); break;
				case RACE_DEMONS: return new RaceDemons(); break;
				case RACE_ANGELS: return new RaceAngels(); break;
				case RACE_ALIENS: return new RaceAliens(); break;
				case RACE_PUMPKINS: return new RacePumpkins(); break;
				case RACE_VAMPIRES: return new RaceVampires(); break;
				case RACE_REPTILES: return new RaceReptiles(); break;
				case RACE_ARACHNIDS: return new RaceArachnids(); break;
				case RACE_DRAGONS: return new RaceDragons(); break;
				case RACE_SNOWMEN: return new RaceSnowmen(); break;
				case RACE_REINDEERS: return new RaceReindeers(); break;
				case RACE_SANTAS: return new RaceSantas(); break;
				case RACE_NATIVES: return new RaceNatives(); break;
				case RACE_UNDEAD: return new RaceUndead(); break;
				case RACE_TERMINATORS: return new RaceTerminators(); break;
				case RACE_BLADE_MASTERS: return new RaceBladeMasters(); break;
				case RACE_CYBORGS: return new RaceCyborgs(); break;
				case RACE_DARK_KNIGHTS: return new RaceDarkKnights(); break;
				case RACE_TEDDY_BEARS: return new RaceTeddyBears(); break;
				case RACE_WATCHMEN: return new RaceWatchmen(); break;
				case RACE_WEREWOLVES: return new RaceWerewolves(); break;
				case RACE_FRANKENSTEINS: return new RaceFrankensteins(); break;
				case RACE_SNOWFLAKES: return new RaceSnowflakes(); break;
				case RACE_TANNENBAUMS: return new RaceTannenbaums(); break;
				
				default: return new RaceElves(); break;
			}
			return null;
		}
		
		public function isUnlocked():Boolean {
			return false;
		}
	}
}