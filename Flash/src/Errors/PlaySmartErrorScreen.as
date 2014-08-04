package Errors
{
	import IreUtils.ResList;
	
	import flash.display.Sprite;
	
	public class PlaySmartErrorScreen extends Sprite
	{
		public function PlaySmartErrorScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
		}
	}
}