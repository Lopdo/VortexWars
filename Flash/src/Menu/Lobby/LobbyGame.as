package Menu.Lobby
{
	import IreUtils.ResList;
	
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.PlayerIO;
	
	public class LobbyGame extends Sprite
	{
		private var lobby:Lobby;
		private var gameName:String;
		private var gameID:String;
		
		public var isFull:Boolean;
		public var started:Boolean;
		
		public function LobbyGame(id:String, name:String, players:int, maxPlayers:int, lobby:Lobby, started:Boolean, mapGroup:int, mapIndex:int, userMap:String, startType:int, gameType:int, distType:int, boostsEnabled:int, upgradesEnabled:int)
		{
			super();
			
			gameID = id;
			
			if(players > maxPlayers) players = maxPlayers;
			
			gameName = name;
			this.lobby = lobby;
			isFull = players == maxPlayers;
			this.started = started;
			
			addChild(ResList.GetArtResource("lobby_gameBg_" + (started ? "inactive" : "active"))); 
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.bold = true;
			if(started)
				tf.color = 0x938B73;
			else 
				tf.color = 0xEDDEB4;
			tf.size = 14;
			tf.align = TextFormatAlign.CENTER;
			tf.rightMargin = 2;
			
			var gameNameLabel:TextField = new TextField();
			gameNameLabel.x = 13;
			gameNameLabel.width = 200;
			gameNameLabel.mouseEnabled = false;
			gameNameLabel.text = name;
			gameNameLabel.setTextFormat(tf);
			gameNameLabel.autoSize = TextFieldAutoSize.LEFT;
			while(gameNameLabel.width > 200) {
				tf.size = int(tf.size) - 1;
				gameNameLabel.setTextFormat(tf);
				gameNameLabel.autoSize = TextFieldAutoSize.LEFT;
			}
			gameNameLabel.y = 7;
			addChild(gameNameLabel);
			
			if(started)
				tf.color = 0x655f4A;
			else 
				tf.color = 0xA19575;
			
			var s:Sprite = new Sprite();
			var tooltip:TextTooltip;
			
			var playerCount:TextField = new TextField();
			playerCount.width = 30;
			playerCount.mouseEnabled = false;
			playerCount.text = players + "/" + maxPlayers;
			playerCount.setTextFormat(tf);
			s.addChild(playerCount);
			s.x = 14;
			s.y = 32;
			playerCount.autoSize = TextFieldAutoSize.CENTER;
			playerCount.y = 10 - playerCount.height / 2;
			addChild(s);
			tooltip = new TextTooltip("Player count", s);
			
			s = new Sprite();
			var gameTypeLabel:TextField = new TextField();
			gameTypeLabel.width = 38;
			gameTypeLabel.mouseEnabled = false;
			switch(gameType) {
				case 0: 
					gameTypeLabel.text = "HC";
					tooltip = new TextTooltip("Battle type: Hardcore", s);
					break;
				case 1: 
					gameTypeLabel.text = "Att"; 
					tooltip = new TextTooltip("Battle type: Attrition", s);
					break;
				case 2: 
					gameTypeLabel.text = "1v1";
					tooltip = new TextTooltip("Battle type: 1 on 1", s);
					break;
				case 3: 
					gameTypeLabel.text = "1v1q";
					tooltip = new TextTooltip("Battle type: 1 on 1 (quick)", s);
					break;
			}
			s.addChild(gameTypeLabel);
			s.x = 48;
			s.y = 32;
			gameTypeLabel.setTextFormat(tf);
			gameTypeLabel.autoSize = TextFieldAutoSize.CENTER;
			gameTypeLabel.y = 10 - gameTypeLabel.height / 2;
			addChild(s);

			s = new Sprite();
			s.addChild(ResList.GetArtResource("lobby_gameStartType_" + (startType == 0 ? "full" : "conquer") + (started ? "_g" : "")));
			s.x = 95;
			s.y = 34;
			addChild(s);
			
			tooltip = new TextTooltip("Start type: " + (startType == 0 ? "Full map" : "Conquer"), s);
			
			s = new Sprite();
			switch(distType) {
				case 0: 
					s.addChild(ResList.GetArtResource("lobby_gameDistType_random" + (started ? "_g" : "")));
					tooltip = new TextTooltip("New Units: Random", s);
					break;
				case 1: 
					s.addChild(ResList.GetArtResource("lobby_gameDistType_manual" + (started ? "_g" : ""))); 
					tooltip = new TextTooltip("New Units: Manual", s);
					break;
				case 2: 
					s.addChild(ResList.GetArtResource("lobby_gameDistType_border" + (started ? "_g" : ""))); 
					tooltip = new TextTooltip("New Units: Borders", s);
					break;
			}
			s.x = 138;
			s.y = 31;
			addChild(s);
			
			s = new Sprite();
			s.x = 176;
			s.y = 32;
			addChild(s);

			var b:Bitmap;
			if(upgradesEnabled == boostsEnabled) {
				b = ResList.GetArtResource("army_logoAngels");
				b.scaleX = b.scaleY = 26 / b.height;
				b.x = -1;
				b.y = -2;
				s.addChild(b);
				
				b = ResList.GetArtResource("boost_defense_icon");
				b.x = 23;
				b.y = 2;
				s.addChild(b);
				
				tooltip = new TextTooltip("Upgrades and bonuses " + (upgradesEnabled ? "enabled" : "disabled"), s);
			}
			if(upgradesEnabled && !boostsEnabled) {
				b = ResList.GetArtResource("boost_attack_icon");
				b.x = 7;
				b.y = 3;
				s.addChild(b);
				b = ResList.GetArtResource("boost_defense_icon");
				b.x = 21;
				b.y = 2;
				s.addChild(b);
				
				tooltip = new TextTooltip("Upgrades enabled, boosts disabled", s);
			}
			if(!upgradesEnabled && boostsEnabled) {
				b = ResList.GetArtResource("army_logoAngels");
				b.scaleX = b.scaleY = 26 / b.height;
				b.x = -1;
				b.y = -2;
				s.addChild(b);
				
				b = ResList.GetArtResource("army_logoDemons");
				b.scaleX = b.scaleY = 26 / b.height;
				b.x = 16;
				b.y = -2;
				s.addChild(b);
				
				tooltip = new TextTooltip("Upgrades disabled, boosts enabled", s);
			}
			
			if(!upgradesEnabled || !boostsEnabled) {
				var l:Sprite = new Sprite();
				l.graphics.lineStyle(2, 0xFF0000);
				l.graphics.moveTo(4,3);
				l.graphics.lineTo(35,18);
				s.addChild(l);
			}
			
			s = new Sprite();
			s.x = 225;
			s.y = 5;
			addChild(s);

			if(mapGroup == 100) {
				s.addChild(ResList.GetArtResource("mapPreview_random"));
				s.width = 50;
				s.height = 50;
				
				tf.color = 0xFEE027;
				
				var label:TextField = new TextField();
				label.defaultTextFormat = tf;
				switch(mapIndex) {
					case 0: 
						label.text = "S"; 
						tooltip = new TextTooltip("Map: Random small", s);
						break;
					case 1: 
						label.text = "M"; 
						tooltip = new TextTooltip("Map: Random medium", s);
						break;
					case 2: 
						label.text = "L"; 
						tooltip = new TextTooltip("Map: Random large", s);
						break;
					case 3: 
						label.text = "XL"; 
						tooltip = new TextTooltip("Map: Random huge", s);
						break;
					case 4:
						label.text = "XXL"; 
						tooltip = new TextTooltip("Map: Random gigantic", s);
						break;
				}
				
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				label.x = 224;
				label.y = 37;
				addChild(label);
				
				var outline:GlowFilter = new GlowFilter(0x000000,1.0,1.0,1.0,10);
				outline.quality=BitmapFilterQuality.HIGH;
				label.filters = [outline];
			}
			else if(mapGroup == 101) {
				//var req:URLRequest = new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/MapImages/" + userMap + ".png"));
				var req:URLRequest = new URLRequest("http://vortexwars.com/maps/" + userMap + ".png");
				var loader:Loader = new Loader();
				loader.load(req);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
					s.addChild(loader.content);
					s.width = 50;
					s.height = 50;
				}, false, 0, true);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (error:IOErrorEvent):void {}, false, 0, true);
			}
			else {
				s.addChild(ResList.GetArtResource("mapPreview_" + mapGroup + "_" + mapIndex));
				s.width = 50;
				s.height = 50;
				tooltip = new TextTooltip("Map: " + G.getMapName(mapGroup, mapIndex), s);
			}
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			useHandCursor = true;
			buttonMode = true;
		}
		
		public function onMouseDown(event:MouseEvent):void {
			if(started) {
				lobby.onStartedGameClicked(gameID);
			}
			else if(isFull) {
				lobby.onFullGameClicked(gameID);
			}
			else {
				lobby.onGameClicked(gameID);
			}
		}
	}
}