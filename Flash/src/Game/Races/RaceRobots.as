package Game.Races
{
	import IreUtils.ResList;

	public class RaceRobots extends Race
	{
		public function RaceRobots()
		{
			super();
			
			ID = 4;
			name = "Robots";
			shopName = "RaceRobots";
			description = "They killed their creators the moment they gained sentience. They have been upgrading themselves and destroying everything in their path ever since.";
			unlockLevel = 8;
			
			regionImage = ResList.GetArtResource("terrain_robots");
			profileImage = ResList.GetArtResource("race_profileImage_Robots");
			symbolSmall = ResList.GetArtResource("army_logoRobots");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceRobots");
		}
	}
}