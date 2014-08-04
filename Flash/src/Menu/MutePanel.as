package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Sprite;
	import flash.net.SharedObject;
	
	public class MutePanel extends Sprite
	{
		private var music:Button;
		private var sound:Button;
		
		private var ingame:Boolean;
		
		public function MutePanel(ingame:Boolean)
		{
			super();
			
			this.ingame = ingame;
			
			if(!ingame) {
				addChild(ResList.GetArtResource("soundPanel_bg"));
			}
			music = new Button(null, onMusic, ResList.GetArtResource("music_" + (G.sounds.isMusicEnabled() ? "on" : "off") + (ingame ? "_small" : "")));
			addChild(music);
			
			sound = new Button(null, onSound, ResList.GetArtResource("sound_" + (G.sounds.isSoundEnabled() ? "on" : "off") + (ingame ? "_small" : "")));
			addChild(sound);
			
			if(ingame) {
				music.x = -2;
				music.y = -1;
				sound.y = music.height - 6;
				sound.x = music.x;				
			}
			else {
				//sound.x = 22;
				//sound.y = 7;
				music.x = 68;
				//music.y = 4;
			}
		}
		
		private function onMusic(button:Button):void {
			var so:SharedObject = SharedObject.getLocal("prefs");
			if(G.sounds.toggleMusic()) {
				music.setImage("music_on" + (ingame ? "_small" : ""));
				so.data.muteMusic = 0;
			}
			else {
				music.setImage("music_off" + (ingame ? "_small" : ""));
				so.data.muteMusic = 1;
			}
			try {
				so.flush();
			}
			catch(errObject:Error) {
				// nothing
			}
		}
		
		private function onSound(button:Button):void {
			var so:SharedObject = SharedObject.getLocal("prefs");
			if(G.sounds.toggleSounds()) {
				sound.setImage("sound_on" + (ingame ? "_small" : ""));
				so.data.muteSounds = 0;
			}
			else {
				sound.setImage("sound_off" + (ingame ? "_small" : ""));
				so.data.muteSounds = 1;
			}
			try {
				so.flush();
			}
			catch(errObject:Error) {
				// nothing
			}
		}
	}
}