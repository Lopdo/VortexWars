package {
	//////////////////////////////////
	//
	// TODO:
	//	- map tokens (defender, ... ? )
	//	- action tokens (rerol, counter rerol)
	//	- map size? (scrollable maps)
	//	- racial bonuses (20% army growth, 5% attack bonus, 5% defence bonus)
	//	- replays
	//
	//////////////////////////////////
	
	
	import Errors.ErrorManager;
	
	import Game.Game;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Lobby.Lobby;
	import Menu.Login.LoginScreen;
	import Menu.Login.LoginScreenKong;
	import Menu.SaleScreen;
	import Menu.WhatsNewScreen;
	
	import com.google.analytics.GATracker;
	
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.profiler.showRedrawRegions;
	import flash.system.Security;
	
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.TextFlow;
	
	import org.osmf.display.ScaleMode;
	
	import playerio.PlayerIO;
	
	//import playerio.*;
	
	[SWF(width='800', height='600', backgroundColor='#FFFFFF')]

	public class DicewarsClient extends MovieClip{
		
		private var musicLoader:URLLoader;
		
		public var domain:String;
		
		public var parameters:Object;
		
		function DicewarsClient(){
			//stop();
			Security.allowDomain("*");
			Security.loadPolicyFile("http://vortexwars.com/maps/crossdomain.xml");
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			//flash.profiler.showRedrawRegions ( true, 0x0000FF );
			
			try {
				G.loaderParams = parameters;
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			new Resources();
			
			G.sounds = new SoundManager();

			G.errorSprite = new Sprite();
			ErrorManager.init(G.errorSprite);
			
			G.gatracker = new GATracker(this, "UA-23679712-3");
			
			/*var domain_parts:Array = stage.loaderInfo.url.split("://");
			var real_domain:Array = domain_parts[1].split("/");
			var domain:String = real_domain[0];*/
			
			G.user = new User();
			
			Input.Init(stage);			
			stage.frameRate = 40;
			
			var req:URLRequest = new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/music.mp3"));
			musicLoader = new URLLoader(req);
			musicLoader.addEventListener(Event.COMPLETE, onMusicDownloaded);
			
			//var paramObj:Object = stage.loaderInfo.parameters;
			//G.loaderParams = paramObj;
			var paramObj:Object = parameters;
			var i:int = 0;
			for (var keyStr:String in paramObj) 
			{
				var valueStr:String = String(paramObj[keyStr]);
				trace(keyStr + ":\t" + valueStr);
				if(keyStr == "gameName") {
					G.invitedTo = valueStr;
				}
				if(keyStr == "kongregate") {
					G.host = G.HOST_KONGREGATE;
				}
				if(keyStr == "fb_api_key") {
					G.host = G.HOST_FACEBOOK;
				}
			}
			if(domain && domain.indexOf("armorgames") != -1) {
				G.host = G.HOST_ARMORGAMES;
			}
			
			//tmp
			//G.host = G.HOST_PLAYSMART;
		
			//G.host = G.HOST_KONGREGATE;
			trace("domain: " + domain);
			trace("params: " + parameters);
			trace("HOST: " + G.host);
			
			G.gameSprite = new Sprite();
			Security.allowDomain("*");
			G.gameSprite.addChild(G.getLoginScreen());
			G.tooltipSprite = new Sprite();
			
			addChild(G.gameSprite);
			addChild(G.tooltipSprite);
			addChild(G.errorSprite);
			
			var so:SharedObject = SharedObject.getLocal("prefs");
			if(!so.data.hasOwnProperty("whatsNewDisplayed")) {
				G.errorSprite.addChild(new WhatsNewScreen());
				so.data.whatsNewDisplayed = true;
				so.flush();
			}
			}
			catch(err:Error) {
				trace(err.message);
				ErrorManager.showCustomError(err.message, 0, null);
			}
		}
		
		public static function multiboxDetected():void {
			G.gameSprite.removeChildAt(0);
			Security.allowDomain("*");
			G.gameSprite.addChild(G.getLoginScreen());
			
			G.disconnect();
			
			ErrorManager.showCustomError("You can run only one instance of this game on your computer.", ErrorManager.ERROR_LOCAL_LOGIN, null);
		}
		
		private function onMusicDownloaded(event:Event):void {
			musicLoader.removeEventListener(Event.COMPLETE, onMusicDownloaded);
			
			var sound:Sound = new Sound(new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/music.mp3")));
			G.sounds.setMusic(sound);
			G.sounds.playMusic();
		}
	}	
}
