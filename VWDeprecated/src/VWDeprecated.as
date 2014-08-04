package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	[SWF(width='800', height='600', backgroundColor='#FFFFFF')]
	
	public class VWDeprecated extends Sprite
	{
		[Embed(source="../res/images/bg.png")]				private var bg:Class;
		
		public var domain:String;
		public var parameters:Object;
		
		private var url:String;
		
		public function VWDeprecated()
		{
			Security.allowDomain("*");
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			var bgBitmap:Bitmap = new bg();
			graphics.beginBitmapFill(bgBitmap.bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			// draw loading progress
			var label:TextField = new TextField();
			label.width = 620;
			label.x = 90;
			label.text = "Vortex Wars 1 is no longer available. Please visit Vortex Wars 2 site to continue playing. If you registered on VW1 you can continue with your old account.";
			label.setTextFormat(new TextFormat("Arial", 20, -1, true, null, null, null, null, TextFormatAlign.CENTER));
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 200;
			label.mouseEnabled = false;
			addChild(label);
			
			trace(this.root.loaderInfo.url);
			trace(domain);
			trace(paramObj);
			url = "http://vortexwars.com";
			var paramObj:Object = parameters;
			var i:int = 0;
			for (var keyStr:String in paramObj) 
			{
				var valueStr:String = String(paramObj[keyStr]);
				trace(keyStr + ":\t" + valueStr);
				if(keyStr == "kongregate") {
					url = "http://www.kongregate.com/games/lopdo/Vortexwars2";
				}
				if(keyStr == "fb_api_key") {
					
				}
			}
			if(domain && domain.indexOf("armorgames") != -1) {
				url = "http://armorgames.com/play/13666/vortex-wars-2";
			}
			if(this.root.loaderInfo.url.indexOf("pio$affiliate=fog") != -1) {
				url = "http://www.freeonlinegames.com/game/vortex-wars-2";
			}
			var linkLabel:TextField = new TextField();
			linkLabel.width = 600;
			linkLabel.x = 100;
			linkLabel.text = url;
			linkLabel.setTextFormat(new TextFormat("Arial", 24, -1, true));
			linkLabel.autoSize = TextFieldAutoSize.CENTER;
			linkLabel.y = 400;
			linkLabel.addEventListener(MouseEvent.CLICK, clickLink);
			addChild(linkLabel);
		}
		
		private function clickLink(e:MouseEvent):void
		{
			navigateToURL(new URLRequest(url), '_blank');
		}
	}
}