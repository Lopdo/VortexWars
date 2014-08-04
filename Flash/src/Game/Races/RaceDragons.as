package Game.Races
{
	import IreUtils.ResList;

	public class RaceDragons extends Race
	{
		public function RaceDragons()
		{
			super();
			
			ID = Race.RACE_DRAGONS;
			name = "Dragons";
			shopName = "RaceDragons";
			bonusDesc = "5% defense bonus, 5% attack bonus, 10% spawn bonus";
			description = "Only those who treasure the world of Vortex Wars the most can befriend these majestic creatures.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_dragons");
			profileImage = ResList.GetArtResource("race_profileImage_Dragons");
			symbolSmall = ResList.GetArtResource("army_logoDragons");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}