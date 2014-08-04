package
{
	import IreUtils.ResList;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;

	public class SoundManager
	{
		private var musicVolume:Number = 1;
		private var soundVolume:Number = 1;
		
		private var music:Sound;
		private var musicTransform:SoundTransform = new SoundTransform();
		private var musicChannel:SoundChannel;
		

		public function SoundManager()
		{
			var so:SharedObject = SharedObject.getLocal("prefs");
			if(so.data.muteMusic == 1)
				musicVolume = 0;
			if(so.data.muteSounds == 1)
				soundVolume = 0;
		}
		
		public function setMusic(m:Sound):void {
			music = m;
		}
		
		public function playMusic(volume:Number = -1):void {
			if(volume != -1) musicVolume = volume;
			
			musicChannel = music.play(0, int.MAX_VALUE);
			musicTransform.volume = musicVolume;
			musicChannel.soundTransform = musicTransform;
		}
		
		private function setMusicVolume(volume:Number):void {
			musicVolume = volume;
			musicTransform.volume = volume;
			musicChannel.soundTransform = musicTransform;
		}
		
		public function toggleMusic():Boolean {
			if(musicVolume != 0) {
				musicVolume = 0;
			}
			else {
				musicVolume = 1;
			}
			musicTransform.volume = musicVolume;
			musicChannel.soundTransform = musicTransform;
			return musicVolume != 0;
		}
		
		public function toggleSounds():Boolean {
			if(soundVolume != 0) {
				soundVolume = 0;
			}
			else {
				soundVolume = 1;
			}
			return soundVolume != 0;
		}
		
		public function playSound(soundName:String):SoundChannel {
			if(soundVolume == 0) return null;
			
			return ResList.GetSoundResource(soundName).play();
		}
		
		public function isMusicEnabled():Boolean {
			return musicVolume != 0;
		}
		
		public function isSoundEnabled():Boolean {
			return soundVolume != 0;
		}
	}
}