package Menu
{
	import IreUtils.ResList;
	
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class LevelIcon extends Sprite
	{
		private var tooltip:TextTooltip;
		private var bd:BitmapData;
		
		public function LevelIcon(level:int)
		{
			super();
			
			setLevel(level);
		}
		
		public function setLevel(level:int):void {
			if(tooltip) {
				tooltip.remove();
				tooltip = null;
			}
			
			while(numChildren > 0) removeChildAt(numChildren - 1);
			
			if(level > 0) {
				tooltip = new TextTooltip("LVL " + level, this);
				
				if(level > 54) level = 54;
				var b:Bitmap = ResList.GetArtResource("ranks");
				bd = new BitmapData(22, 28, true);
				bd.copyPixels(b.bitmapData, new Rectangle(22*((level - 1) % 9), 28*(int)((level - 1) / 9), 22, 28), new Point(0, 0));
				var rankBitmap:Bitmap = new Bitmap(bd);
				addChild(rankBitmap);
			}
		}
	}
}