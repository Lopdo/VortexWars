package Menu.Social
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class SocialProfileMapPreview extends Sprite
	{
		public function SocialProfileMapPreview(mapName:String)
		{
			super();
			
			var req:URLRequest = new URLRequest("http://vortexwars.com/maps/" + mapName + ".png");
			var loader:Loader = new Loader();
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event):void { if(loader.content) addChild(loader.content); }, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (error:IOErrorEvent):void {}, false, 0, true);

		}
	}
}