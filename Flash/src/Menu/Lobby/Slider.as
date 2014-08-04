package Menu.Lobby
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;

	public class Slider extends Sprite
	{
		public var size:int;
		
		public function Slider()
		{
		}
		
		public function setSize(newSize:int):void {
			while(numChildren > 0) removeChildAt(numChildren - 1);
			
			size = newSize;
			
			addChild(ResList.GetArtResource("lobby_chatListSlider_end"));
			
			var endSize:int = height;
			var b:Bitmap = ResList.GetArtResource("lobby_chatListSlider_mid");
			b.height = size - 2 * endSize;
			b.y = endSize;
			addChild(b);
			
			b = ResList.GetArtResource("lobby_chatListSlider_end");
			b.y = size;// - endSize - endSize;
			b.scaleY = -1;
			addChild(b);
		}
	}
}