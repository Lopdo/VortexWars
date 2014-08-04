package Menu.Tooltips
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class ImageTooltip extends BaseTooltip
	{
		private var ownerSprite:DisplayObject;
		private var timer:Timer;
		private var lastX:int, lastY:int;
		
		public function ImageTooltip(imageName:String, owner:DisplayObject)
		{
			super(owner);

			var b:Bitmap = ResList.GetArtResource(imageName);
			b.x = b.y = 2;
			
			//graphics.beginFill(0xFFEBB2);
			graphics.beginFill(0);
			graphics.lineStyle(2, 0xFFEBB2);
			graphics.drawRect(0, 0, b.width + 4, b.height + 4);
			
			addChild(b);
		}
	}
}