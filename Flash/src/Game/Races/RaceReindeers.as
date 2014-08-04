package Game.Races
{
	import IreUtils.ResList;

	public class RaceReindeers extends Race
	{
		public function RaceReindeers()
		{
			super();
			
			ID = Race.RACE_REINDEERS;
			name = "Reindeer";
			shopName = "RaceReindeers";
			bonusDesc = "+2 attack boosts per game (your boosts only)";
			description = "Trusty steeds that always help Santa with finding naughty children.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_reindeers");
			profileImage = ResList.GetArtResource("race_profileImage_Reindeers");
			symbolSmall = ResList.GetArtResource("army_logoReindeers");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}