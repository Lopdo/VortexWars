package
{
	public class HintsManager extends Object
	{
		private static var hints:Array = new Array(
			"Hold shift while clicking on territory to add the maximum number of troops.",
			"When you lose a battle in Hardcore (HC) mode, the number of troops in your attacking territory will always be reduced to 1.",
			"Unlike Attrition (Att) and One on One (1v1q) in Hardcore (HC) game mode your lost attacks do not have chance of lowering opponents defenses.",
			"When using boosts, you spend the free (left) ones first.",
			"You spend attack boosts even if you win your first roll.",
			"You can't move your defense boosts once placed.",
			"If you are using the Reindeer or Snowmen races, you must have pre-paid boosts for the additional boosts to be available.",
			"You can mute anyone by pressing the tiny chat bubble icon next to his name.",
			"Your army strength is calculated according to the largest number of connected territories. Try to avoid having a lot of separate regions.",
			"You can use keyboard shortcuts to use boosts - 'A' for attack, 'D' for defense.",
			"Visit the forum at http://www.vortexwars.com/forum to share your ideas, report bugs and make new friends.",
			"You can change your race, background image and check your stats at the profile screen.",
			"If someone keeps insulting you, mute him.",
			"If you disable bonuses while creating game, you will lose both race bonuses and storage upgrades.",
			"Don't run with scissors, unless you really have to");
		
		public function HintsManager()
		{
			super();
		}
		
		public static function getRandomHint():String {
			//return HintsManager.hints.length + " " + Math.random() * HintsManager.hints.length;
			return HintsManager.hints[(int)(Math.random() * HintsManager.hints.length)];
		}
	}
}