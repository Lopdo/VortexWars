package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Sprite;
	
	public class DynamicBar extends Sprite
	{
		public function DynamicBar(bitmapName:String, desiredWidth:int)
		{
			super();
			
			addChild(ResList.GetArtResource(bitmapName + "_left"));
			var w:int = width;
			
			var mid:Sprite = new Sprite();
			mid.addChild(ResList.GetArtResource(bitmapName + "_mid"));
			mid.width = desiredWidth - 2 * w + 1;
			mid.x = w;
			addChild(mid);
			
			var right:Sprite = new Sprite();
			right.addChild(ResList.GetArtResource(bitmapName + "_right"));
			right.x = desiredWidth - w;
			addChild(right);
		}
	}
}