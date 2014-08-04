package Menu.Lobby
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.MenuSelector;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.ColorTransform;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.utils.StringUtil;
	
	import playerio.PlayerIO;
	
	public class CreateGameScreen extends Sprite
	{
		private var gameName:TextField;
		private var gameType:MenuSelector, maxPlayers:MenuSelector, startType:MenuSelector, troopsDist:MenuSelector;
		private var mapGroup:MenuSelector, mapDetail:MenuSelector, minLevel:MenuSelector, upgrades:MenuSelector;
		private var userMapsButton:ButtonHex;
		
		private var so:SharedObject;
		private var mapPreview:Sprite;
		
		private var currentUserMap:String;
		
		public function CreateGameScreen()
		{
			super();
			
			try {
				so = SharedObject.getLocal("prefs");
				if(!so.data.hasOwnProperty("gameType")) {
					so.data.gameType = 1;
				}
				if(!so.data.hasOwnProperty("mapGroup")) {
					so.data.mapGroup = 101;
				}
				if(!so.data.hasOwnProperty("mapDetail")) {
					so.data.mapDetail = 2;
				}
				if(!so.data.hasOwnProperty("userMap")) {
					so.data.userMap = "";
				}
				if(!so.data.hasOwnProperty("startType")) {
					so.data.startType = 1;
				}
				if(!so.data.hasOwnProperty("maxPlayers")) {
					so.data.maxPlayers = 8;
				}
				if(!so.data.hasOwnProperty("troopsDist")) {
					so.data.troopsDist = 1;
				}
				if(!so.data.hasOwnProperty("minLevel")) {
					so.data.minLevel = 0;
				}
				if(!so.data.hasOwnProperty("bonusesEnabled")) {
					so.data.bonusesEnabled = 3;
				}
				so.flush();
			}
			catch(errObject:Error) {
				// nothing
			}
			
			currentUserMap = so.data.userMap;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var bgSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 550, 410);
			bgSprite.x = width / 2 - bgSprite.width / 2;
			bgSprite.y = height / 2 - bgSprite.height / 2;
			addChild(bgSprite);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.text = "CREATE GAME";
			label.setTextFormat(tf);
			label.width = bgSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bgSprite.addChild(label);
			
			tf.size = 14;

			var line:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 388, 44);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 50;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "GAME NAME:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = 112;
			editbox.y = line.height / 2 - editbox.height/2;
			line.addChild(editbox);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			
			gameName = new TextField();
			gameName.defaultTextFormat = editTF;
			gameName.x = 10;
			gameName.y = 4;
			gameName.width = editbox.width - 20;
			gameName.autoSize = TextFieldAutoSize.LEFT;
			gameName.autoSize = TextFieldAutoSize.NONE;
			gameName.width = editbox.width - 20;
			gameName.text = G.user.name + "'s game";
			gameName.maxChars = 20;
			gameName.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 125, 125, 125, 0);
			if(!G.user.isGuest) {
				gameName.type = TextFieldType.INPUT;
				gameName.setSelection(0, gameName.text.length);
			}
			else {
				gameName.alwaysShowSelection = false;
			}
			
			editbox.addChild(gameName);
			
			var mapBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 170, 241);
			mapBg.x = 12;
			mapBg.y = 110;
			bgSprite.addChild(mapBg);
			
			label = new TextField();
			label.text = "CHOOSE MAP";
			label.setTextFormat(tf);
			label.width = mapBg.width;
			label.y = 8;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			mapBg.addChild(label);
			
			mapPreview = new Sprite();
			mapPreview.x = 35;
			mapPreview.y = 40;
			mapBg.addChild(mapPreview);
			
			mapGroup = new MenuSelector(160, 30);
			mapGroup.x = 5;
			mapGroup.y = 160;
			//if(G.localServer)
			mapGroup.AddItem("User maps", 101);
			mapGroup.AddItem("Random", 100);
			mapGroup.AddItem("Default pack", 99);
			if(!G.user.isGuest && G.client.payVault.has("MapPack_0"))
				mapGroup.AddItem("World Pack", 0);
			if(!G.user.isGuest && G.client.payVault.has("MapPack_1"))
				mapGroup.AddItem("Symmetries", 1);
			if(!G.user.isGuest && G.client.payVault.has("MapPack_2"))
				mapGroup.AddItem("Races", 2);
			if(!G.user.isGuest && G.client.payVault.has("MapPack_3"))
				mapGroup.AddItem("Halloween", 3);
			mapGroup.callback = onMapGroupChanged;
			mapBg.addChild(mapGroup);
			
			mapDetail = new MenuSelector(160, 30);
			mapDetail.x = 5;
			mapDetail.y = 200;
			mapBg.addChild(mapDetail);
			mapDetail.callback = onMapDetailChanged;

			userMapsButton = new ButtonHex("CHOOSE", onUserMapsClicked, "button_small_gray");
			userMapsButton.x = 5 + 80 - userMapsButton.width / 2;
			userMapsButton.y = 196;
			userMapsButton.visible = false;
			mapBg.addChild(userMapsButton);
			
			var lastMapDetail:int = so.data.mapDetail;
			mapGroup.SetActiveItemByData(so.data.mapGroup);
			mapDetail.SetActiveItemByData(lastMapDetail);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = 192;
			line.y = 110;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "START TYPE:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			startType = new MenuSelector(200, line.height);
			startType.x = 130;
			startType.AddItem("Full map", 0);
			startType.AddItem("Conquer", 1);
			line.addChild(startType);
			startType.SetActiveItem(so.data.startType);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = 192;
			line.y = 151;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "NEW TROOPS:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);

			troopsDist = new MenuSelector(200, line.height);
			troopsDist.x = 130;
			troopsDist.AddItem("Random", 0);
			troopsDist.AddItem("Manual", 1);
			troopsDist.AddItem("Borders", 2);
			line.addChild(troopsDist);
			troopsDist.SetActiveItem(so.data.troopsDist);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = 192;
			line.y = 192;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "GAME TYPE:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			gameType = new MenuSelector(200, line.height);
			gameType.x = 130;
			gameType.AddItem("Hardcore", 0);
			gameType.AddItem("Attrition", 1);
			//gameType.AddItem("1 on 1", 2);
			gameType.AddItem("1 on 1 quick", 3);
			line.addChild(gameType);
			gameType.SetActiveItemByData(so.data.gameType);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = 192;
			line.y = 233;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "MAX PLAYERS:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			maxPlayers = new MenuSelector(200, line.height);
			maxPlayers.x = 130;
			maxPlayers.AddItem("2", 2);
			maxPlayers.AddItem("3", 3);
			maxPlayers.AddItem("4", 4);
			maxPlayers.AddItem("5", 5);
			maxPlayers.AddItem("6", 6);
			maxPlayers.AddItem("7", 7);
			maxPlayers.AddItem("8", 8);
			line.addChild(maxPlayers);
			maxPlayers.SetActiveItem(so.data.maxPlayers - 2);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = 192;
			line.y = 274;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "MIN LEVEL:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			minLevel = new MenuSelector(200, line.height);
			minLevel.x = 130;
			minLevel.AddItem("Any", 0);
			if(!G.user.isGuest)
				minLevel.AddItem("No Guests", 1);
			if(G.user.level > 5)
				minLevel.AddItem("5", 5);
			if(G.user.level > 10)
				minLevel.AddItem("10", 10);
			if(G.user.level > 15)
				minLevel.AddItem("15", 15);
			if(G.user.level > 20)
				minLevel.AddItem("20", 20);
			line.addChild(minLevel);
			minLevel.SetActiveItemByData(so.data.minLevel);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = 192;
			line.y = 315;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "UPGRADES:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			upgrades = new MenuSelector(200, line.height);
			upgrades.x = 130;
			upgrades.AddItem("All enabled", 3);
			upgrades.AddItem("Upgrades only", 1);
			upgrades.AddItem("Boosts only", 2);
			upgrades.AddItem("All disabled", 0);
			line.addChild(upgrades);
			upgrades.SetActiveItemByData(so.data.bonusesEnabled);
			
			var button:ButtonHex = new ButtonHex("CREATE", onCreate, "button_small_gold");
			button.x = bgSprite.width - button.width - 120;
			button.y = 360;
			bgSprite.addChild(button);
			
			button = new ButtonHex("CANCEL", onCancel, "button_small_gray");
			button.x = 120;
			button.y = 360;
			bgSprite.addChild(button);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			G.gatracker.trackPageview("/createGameScreen");
		}
		
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			stage.focus = null;
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.focus = gameName;
		}
		
		private function onCreate():void {
			if(StringUtil.trim(gameName.text).length == 0) {
				ErrorManager.showCustomError("Game name cannot be empty", ErrorManager.ERROR_INVALID_PARAMETER, null);
				return;
			}
			if(mapGroup.GetCurrentItemData() == 101 && (currentUserMap == null || currentUserMap.length == 0)) {
				ErrorManager.showCustomError("You need to choose map before you are allowed to continue", ErrorManager.ERROR_INVALID_PARAMETER, null);
				return;
			}
			
			try {
				so.data.gameType = gameType.GetCurrentItemData();
				so.data.mapDetail = mapGroup.GetCurrentItemData() != 101 ? mapDetail.GetCurrentItemData() : 0;
				so.data.startType = startType.GetCurrentItemData();
				so.data.maxPlayers = maxPlayers.GetCurrentItemData();
				so.data.troopsDist = troopsDist.GetCurrentItemData();
				so.data.mapGroup = mapGroup.GetCurrentItemData();
				so.data.minLevel = minLevel.GetCurrentItemData();
				so.data.bonusesEnabled = upgrades.GetCurrentItemData();
				so.data.userMap = currentUserMap;
				so.flush();
			}
			catch(errObject:Error) {
				// nothing
			}
			
			/*Log.CustomMetric("GameTypeCreated_" + so.data.gameType, "GamePrefsGameType");
			if(mapGroup.GetCurrentItemData() == 100)
				Log.CustomMetric("MapSizeCreated_" + so.data.mapDetail, "GamePrefsMap");
			else if(mapGroup.GetCurrentItemData() == 101) {
				Log.CustomMetric("UserMap", "GamePrefsMap");
				Log.CustomMetric(currentUserMap, "UserMaps");
			}
			else {
				Log.CustomMetric("MapIndex_" + so.data.mapGroup + "_" + so.data.mapDetail, "GamePrefsMap");
			}
			Log.CustomMetric("TroopsDistCreated_" + so.data.troopsDist, "GamePrefsTroopsDist");
			Log.CustomMetric("StartTypeCreated_" + so.data.startType, "GamePrefsStartType");
			Log.CustomMetric("MaxPlayersCreated_" + so.data.maxPlayers, "GamePrefsMaxPlayers");
			Log.CustomMetric("Race_" + G.user.race.ID, "Race");
			//Log.CustomMetric(so.data.upgradesEnabled, "UpgradesEnabled");*/
			
			G.gatracker.trackEvent("GameSettings", "Type", so.data.gameType + "");
			if(mapGroup.GetCurrentItemData() == 100) {
				G.gatracker.trackEvent("GameSettings", "MapType", "random");
				G.gatracker.trackEvent("GameSettings", "Size", so.data.mapDetail + "");
			}
			else if(mapGroup.GetCurrentItemData() == 101) {
				G.gatracker.trackEvent("GameSettings", "MapType", "userMap");
				G.gatracker.trackEvent("GameSettings", "UserMap", currentUserMap);
			}
			else {
				G.gatracker.trackEvent("GameSettings", "MapType", "premade");
				G.gatracker.trackEvent("GameSettings", "PremadeMap", so.data.mapGroup + "_" + so.data.mapDetail);
			}
			G.gatracker.trackEvent("GameSettings", "TroopsDistribution", so.data.troopsDist + "");
			G.gatracker.trackEvent("GameSettings", "StartType", so.data.startType + "");
			G.gatracker.trackEvent("GameSettings", "MaxPlayers", so.data.maxPlayers + "");
			G.gatracker.trackEvent("GameSettings", "MinLevel", minLevel.GetCurrentItemData() + "");
			G.gatracker.trackEvent("GameSettings", "Race", G.user.race.ID + "");
			G.gatracker.trackEvent("GameSettings", "Upgrades", upgrades.GetCurrentItemData() + "");
			
			var upgEnabled:int = 0;
			var bEnabled:int = 0;
			if(upgrades.GetCurrentItemData() == 3) {
				upgEnabled = bEnabled = 1;
			}
			else if(upgrades.GetCurrentItemData() == 2) {
				bEnabled = 1;
			}
			else if(upgrades.GetCurrentItemData() == 1) {
				upgEnabled = 1;
			}
			Lobby(this.parent).CreateGame({name:gameName.text, gameType:gameType.GetCurrentItemData(), mapGroup:mapGroup.GetCurrentItemData(), mapDetail:(mapGroup.GetCurrentItemData() == 101 ? 0 : mapDetail.GetCurrentItemData()), userMap:(mapGroup.GetCurrentItemData() == 101 ? currentUserMap : ""), startType:startType.GetCurrentItemData(), maxPlayers:maxPlayers.GetCurrentItemData(), troopsDist:troopsDist.GetCurrentItemData(), minLevel:minLevel.GetCurrentItemData(), upgradesEnabled:upgEnabled, boostsEnabled:bEnabled});
		}
		
		private function onMapGroupChanged(index:int):void {
			mapDetail.removeAllItems();
			userMapsButton.visible = false;
			mapDetail.visible = true;
			
			switch(mapGroup.GetCurrentItemData()) {
				case 101: {
					if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
					userMapsButton.visible = true;
					mapDetail.visible = false;
					setUserMap(currentUserMap);
				}
					break;
				case 100: {
					if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
					mapPreview.addChild(ResList.GetArtResource("mapPreview_random"));
					mapDetail.AddItem("Small", 0);
					mapDetail.AddItem("Medium", 1);
					mapDetail.AddItem("Large", 2);
					mapDetail.AddItem("Huge", 3);
					mapDetail.AddItem("Gigantic", 4);
				}
					break;
				case 0: {
					if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
					mapDetail.AddItem(G.getMapName(0, 0), 0);
					mapDetail.AddItem(G.getMapName(0, 1), 1);
					mapDetail.AddItem(G.getMapName(0, 2), 2);
					mapDetail.AddItem(G.getMapName(0, 3), 3);
					mapDetail.SetActiveItem(0);
				}
					break;
				case 1: {
					if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
					mapDetail.AddItem(G.getMapName(1, 0), 0);
					mapDetail.AddItem(G.getMapName(1, 1), 1);
					mapDetail.AddItem(G.getMapName(1, 2), 2);
					mapDetail.AddItem(G.getMapName(1, 3), 3);
					mapDetail.SetActiveItem(0);
				}
					break;
				case 2: {
					if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
					mapDetail.AddItem(G.getMapName(2, 0), 0);
					mapDetail.AddItem(G.getMapName(2, 1), 1);
					mapDetail.AddItem(G.getMapName(2, 2), 2);
					mapDetail.AddItem(G.getMapName(2, 3), 3);
					mapDetail.SetActiveItem(0);
				}
					break;
				case 3: {
					if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
					mapDetail.AddItem(G.getMapName(3, 0), 0);
					mapDetail.AddItem(G.getMapName(3, 1), 1);
					mapDetail.AddItem(G.getMapName(3, 2), 2);
					mapDetail.AddItem(G.getMapName(3, 3), 3);
					mapDetail.SetActiveItem(0);
				}
					break;
				case 99: {
					if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
					mapDetail.AddItem(G.getMapName(99, 0), 0);
					mapDetail.AddItem(G.getMapName(99, 1), 1);
					mapDetail.AddItem(G.getMapName(99, 2), 2);
					mapDetail.AddItem(G.getMapName(99, 3), 3);
					mapDetail.AddItem(G.getMapName(99, 4), 4);
					mapDetail.AddItem(G.getMapName(99, 5), 5);
					mapDetail.AddItem(G.getMapName(99, 6), 6);
					mapDetail.AddItem(G.getMapName(99, 7), 7);
					mapDetail.AddItem(G.getMapName(99, 8), 8);
					mapDetail.AddItem(G.getMapName(99, 9), 9);
					
					mapDetail.SetActiveItem(0);
				}
			}
		}
		
		private function onMapDetailChanged(index:int):void {
			if(mapGroup.GetCurrentItemData() < 100) {
				if(mapPreview.numChildren > 0) mapPreview.removeChildAt(0);
				mapPreview.addChild(ResList.GetArtResource("mapPreview_" + mapGroup.GetCurrentItemData() + "_" + mapDetail.GetCurrentItemData()));
			}
		}
		
		private function onCancel():void {
			//so.data.gameType = gameType.GetCurrentItemData();
			//so.data.mapSize = mapSize.GetCurrentItemData();
			//so.data.startType = startType.GetCurrentItemData();
			//so.flush();
			
			Lobby(this.parent).CreateRoomScreenClosed();
		}
		
		private function onUserMapsClicked():void {
			parent.addChild(new UserMapPicker(this));
		}
		
		public function setUserMap(mapKey:String):void {
			currentUserMap = mapKey;
			
			if(mapPreview.numChildren > 0)
				mapPreview.removeChildAt(0);
			mapPreview.addChild(ResList.GetArtResource("mapPreview_user"));
			
			//var req:URLRequest = new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/MapImages/" + mapKey + ".png"));
			var req:URLRequest = new URLRequest("http://vortexwars.com/maps/" + mapKey + ".png");
			var loader:Loader = new Loader();
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
				mapPreview.removeChildAt(0);
				mapPreview.addChild(loader.content);
			}, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (error:IOErrorEvent):void {}, false, 0, true);
		}
	}
}