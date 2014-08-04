package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.PlayerIO;
	
	[SWF(width='800', height='600', backgroundColor='#FFFFFF')]
	
	public class Preloader extends Sprite
	{
		[Embed(source="../res/images/bg.png")]				private var bg:Class;
		[Embed(source="../res/images/hex_bg.png")]				private var hex_bg:Class;
		[Embed(source="../res/images/hex_light.png")]				private var hex_light:Class;
		
		private var preloaderStuff:Sprite;
		
		private var progress:TextField;
		private var loader:Loader;
		
		private var hexLights:Array = new Array;
		
		private var domain:String;
		
		public function Preloader()
		{
			preloaderStuff = new Sprite();
			
			var bgBitmap:Bitmap = new bg();
			preloaderStuff.graphics.beginBitmapFill(bgBitmap.bitmapData);
			preloaderStuff.graphics.drawRect(0, 0, 800, 600);
			
			// draw loading progress
			progress = new TextField();
			progress.width = 800;
			progress.text = "LOADING...";
			progress.setTextFormat(new TextFormat("Arial", 24, -1, true));
			progress.autoSize = TextFieldAutoSize.CENTER;
			progress.y = 300;
			progress.mouseEnabled = false;
			preloaderStuff.addChild(progress);
			
			var hexes:Sprite = new Sprite();
			for(var i:int = 0; i < 12; i++) {
				var hexBG:Bitmap = new hex_bg();
				hexBG.x = (int)((i + 1) / 2) * 22;
				if(i == 0 || i == 11) {
					hexBG.y = 26;
				}
				else {
					hexBG.y = ((int)((i - 1) / 2) % 2 == 0 ? 13 : 0) + ((i - 1) % 2) * 26;
				}
				hexes.addChild(hexBG);
				
				var hexLight:Bitmap = new hex_light();
				hexLight.x = hexBG.x;
				hexLight.y = hexBG.y;
				hexLight.alpha = 0;
				hexes.addChild(hexLight);
				hexLights.push(hexLight);
			}
			hexes.y = 200;
			hexes.x = 400 - hexes.width / 2;
			preloaderStuff.addChild(hexes);
			
			var hintTitle:TextField = new TextField();
			hintTitle.text = "Hint:";
			hintTitle.setTextFormat(new TextFormat("Arial", 20, 0xDDDDDD, true));
			hintTitle.y = 400;
			hintTitle.width = 800;
			hintTitle.autoSize = TextFieldAutoSize.CENTER;
			hintTitle.mouseEnabled = false;
			preloaderStuff.addChild(hintTitle);
			
			var hintLabel:TextField = new TextField();
			hintLabel.text = HintsManager.getRandomHint();
			hintLabel.setTextFormat(new TextFormat("Arial", 18, 0xDDDDDD, true, false, false, null, null, TextFormatAlign.CENTER));
			hintLabel.multiline = true;
			hintLabel.wordWrap = true;
			hintLabel.x = 100;
			hintLabel.width = 800 - 200;
			hintLabel.y = 430;
			hintLabel.autoSize = TextFieldAutoSize.CENTER;
			hintLabel.mouseEnabled = false;
			preloaderStuff.addChild(hintLabel);
				
			Security.allowDomain("*");
			
			// figure out domain we are on for stats tracking
			var domain_parts:Array = this.root.loaderInfo.url.split("://");
			var real_domain:Array = domain_parts[1].split("/");
			domain = real_domain[0];
			
			// parse flash vars 
			var isBeta:Boolean = false;
			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			for (var keyStr:String in paramObj) 
			{
				if(keyStr == "isBeta") {
					isBeta = true;
				}
			}
			
			// load game swf
			loader = new Loader();
			
			var url:String  = PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/VortexWarsGame2.swf");
			//var url:String = domain_parts[0] + "://r.playerio.com/r/wargrounds-pvrpqmt1ee2jwqueof8ig/VortexWarsGamePS.swf";
			
			trace(url);
			
			var urlRequest:URLRequest = new URLRequest(url);
			loader.load(urlRequest);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			addChild(preloaderStuff);
		}
		
		private function onError(error:IOErrorEvent):void {
			trace(error.toString());
		}
		
		private function onProgress(event:ProgressEvent):void {
			var loadedBytes:int = Math.round(event.target.bytesLoaded  / 1024);  
			var totalBytes:int = Math.round(event.target.bytesTotal / 1024);  
			var percent:int = (event.target.bytesLoaded / event.target.bytesTotal) * 100;  
			
			var index:int = percent / (100 / 12);
			for(var i:int = 0; i < index; ++i) {
				hexLights[i].alpha = 1;
			}
			
			if(index < hexLights.length)
				hexLights[index].alpha = percent / (100 / 12) - index; 
		}
		
		private function onComplete(event:Event):void {
			trace(domain);
			removeChild(preloaderStuff);
			Object(loader.content).domain = domain;
			Object(loader.content).parameters = LoaderInfo(this.root.loaderInfo).parameters;
			if(domain) {
				if(domain.indexOf("ungrounded") != -1) {
					Object(loader.content).parameters.pio$affiliate = "newgrounds";
				}
				if(domain.indexOf("notsocasual.com") != -1) {
					Object(loader.content).parameters.pio$affiliate = "notsocasual";
				}
			}
			
			// bubblebox version
			//Object(loader.content).parameters.pio$affiliate = "bubblebox";
			
			trace("affiliate: " + Object(loader.content).parameters.pio$affiliate);
			
			addChild(loader.content);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);  
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
		}
	}
}