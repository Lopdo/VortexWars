package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class NinePatchSprite extends Sprite
	{
		public function NinePatchSprite(texPrefix:String, patchWidth:int, patchHeight:int)
		{
			super();
			
			var b:Bitmap = ResList.GetArtResource(texPrefix + "_topLeft");
			addChild(b);
			
			var tmpWidth:int = patchWidth - b.width;
			var tmpHeight:int = patchHeight - b.height;
			var tmpX:int = b.width;
			var tmpY:int = b.height;
			
			b = ResList.GetArtResource(texPrefix + "_topRight");
			b.x = patchWidth - b.width;
			addChild(b);
			
			tmpWidth -= b.width;
			
			b = ResList.GetArtResource(texPrefix + "_top");
			b.x = tmpX;
			b.width = tmpWidth;
			addChild(b);
			
			b = ResList.GetArtResource(texPrefix + "_bottomLeft");
			b.y = patchHeight - b.height;
			addChild(b);
			
			tmpWidth = patchWidth - b.width;
			tmpX = b.width;
			tmpHeight -= b.height;
			
			b = ResList.GetArtResource(texPrefix + "_bottomRight");
			b.x = patchWidth - b.width;
			b.y = patchHeight - b.height;
			addChild(b);
			
			tmpWidth -= b.width;
			
			b = ResList.GetArtResource(texPrefix + "_bottom");
			b.x = tmpX;
			b.width = tmpWidth;
			b.y = patchHeight - b.height;
			addChild(b);
			
			b = ResList.GetArtResource(texPrefix + "_left");
			b.y = tmpY;
			b.height = tmpHeight;
			addChild(b);
			
			b = ResList.GetArtResource(texPrefix + "_right");
			b.x = patchWidth - b.width;
			b.y = tmpY;
			b.height = tmpHeight;
			addChild(b);
			
			b = ResList.GetArtResource(texPrefix + "_center");
			b.x = tmpX;
			b.y = tmpY;
			b.width = tmpWidth;
			b.height = tmpHeight;
			addChild(b);
		}
	}
}