package Game.Races
{
	import IreUtils.ResList;

	public class RaceLegionaires extends Race
	{
		public function RaceLegionaires()
		{
			super();
			
			ID = 2;
			name = "Legionnaires";
			shopName = "RaceLegionaires";
			description = "Pride and honor is long forgotten, these killing machines fight only in exchange for shiny things of all kinds";
			
			regionImage = ResList.GetArtResource("terrain_bones");
			profileImage = ResList.GetArtResource("race_profileImage_Legionaires");
			symbolSmall = ResList.GetArtResource("army_logoLegionaires");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest;
		}
	}
}