package MapEditor
{
	import Errors.ErrorManager;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.ConfirmationDialog;
	import Menu.Loading;
	import Menu.MainMenu.MainMenu;
	import Menu.MutePanel;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIOError;

	public class MapEditorScreen extends Sprite
	{
		protected static const MODE_MAP:int = 1;
		protected static const MODE_REGION:int = 2;
		protected static const MODE_ERASE_MAP:int = 3;
		protected static const MODE_DRAW_REGION:int = 4;
		protected static const MODE_ERASE_REGION:int = 5;
		protected static const MODE_EDIT_REGION:int = 6;

		// current editor mode
		protected var editMode:int = MODE_MAP;	

		private var button:ButtonHex;
		private var mapBtn:ButtonHex;
		private var regionBtn:ButtonHex;
		
		private var mapSprite:Sprite;
		private var map:MEMap;
		private var logList:LogList;

		private var lastMouseDownX:int, lastMouseDownY:int;
		private var lastDrawnX:int, lastDrawnY:int;
		
		// public timekeeping stuff
		public var gameTime:Number = 0;
		public var timeDelta:Number = 0;
		// private timekeeping stuff used for timeDelta calculations
		private var oldTime:Number = 0;
		private var prevTimeDelta:Number = 0;
		private var startTime:Number;
		
		private var saveRegionBtn:ButtonHex;
		private var mapName:TextField;
		private var mapKey:String = "";
		
		private var loadingScreen:Loading;
		
		private var regionCounter:TextField;
		
		protected var isMapDirty:Boolean = false;
		protected var saveButton:ButtonHex;
		
		protected var maxRegionCount:int;
		
		private var openedFromAdmin:Boolean;
		
		private var zoomLevel:int;
		
		public function MapEditorScreen(mapKey:String, fromAdmin:Boolean = false)
		{
			super();
			
			//mapKey = "dEpDmM2Ju0atB_O9IIl_cw";
			//00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 0B 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 0B 0B 05 05 05 05 05 05 05 05 05 05 00 1F 1F 1F 1F 00 13 13 00 12 12 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 0B 05 00 05 00 05 00 05 00 05 00 05 1F 1F 1F 1F 00 13 13 13 00 12 00 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 26 00 00 00 02 02 00 04 04 0B 0B 05 05 05 05 05 05 05 05 05 05 00 1F 1F 1F 1F 00 13 13 00 12 12 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 26 26 00 00 00 02 02 00 04 04 0C 0C 00 00 00 00 00 00 00 00 00 00 1F 1F 1F 1F 00 13 13 13 00 12 00 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 26 26 26 00 00 02 02 00 04 04 0C 0C 06 06 06 06 06 06 06 06 06 06 00 22 22 22 22 15 15 15 15 12 12 00 04 04 00 02 02 03 00 00 00 00 00 00 00 00 00 00 26 26 26 26 00 00 02 02 00 04 04 0C 06 00 06 00 06 00 06 00 06 00 06 22 22 22 22 22 15 15 15 1C 1C 00 00 04 04 00 02 02 03 00 00 00 00 00 00 00 00 00 26 01 26 00 00 02 02 00 04 04 0C 0C 06 06 06 06 06 06 06 06 06 06 00 22 22 22 22 15 15 15 15 1C 1C 00 04 04 00 02 02 03 03 00 00 00 00 00 00 00 00 00 26 01 01 26 00 00 02 02 00 04 04 0D 0D 00 00 00 00 00 00 00 00 00 00 22 22 22 22 22 17 17 17 1C 1C 00 00 04 04 00 02 02 03 03 00 00 00 00 00 00 00 00 01 01 01 00 00 02 02 00 04 04 0D 0D 07 07 07 07 07 07 07 07 07 07 00 23 23 23 23 17 17 17 17 1C 1C 00 04 04 00 02 02 03 03 03 00 00 00 00 00 00 28 28 01 01 01 01 02 02 02 02 00 04 04 0D 07 00 07 00 07 00 07 00 07 00 07 23 23 23 23 23 17 17 17 1D 1D 00 00 04 04 00 02 02 03 03 03 00 00 00 28 28 28 01 01 01 01 01 02 02 02 00 04 04 11 11 07 07 07 07 07 07 07 07 07 07 00 23 23 25 25 19 19 19 19 1D 1D 00 04 04 04 02 02 03 03 03 03 00 00 00 28 28 28 01 01 01 01 01 01 02 02 02 00 04 04 11 11 00 00 00 00 00 00 00 00 00 00 25 25 25 25 25 19 19 19 1D 1E 00 00 04 04 04 02 02 03 03 03 03 00 00 28 28 28 01 01 01 01 01 02 02 02 00 04 04 11 11 08 08 08 08 08 08 08 08 08 08 00 24 24 25 25 19 19 19 19 1E 1E 00 04 04 04 02 02 03 03 03 03 00 00 00 00 00 28 28 01 01 01 01 02 02 02 02 00 04 04 10 08 00 08 00 08 00 08 00 08 00 08 24 24 24 24 24 18 18 18 1E 1E 00 00 04 04 00 02 02 03 03 03 00 00 00 00 00 00 00 01 01 01 00 00 02 02 00 04 04 10 10 08 08 08 08 08 08 08 08 08 08 00 24 24 24 24 18 18 18 18 1B 1B 00 04 04 00 02 02 03 03 03 00 00 00 00 00 00 00 00 27 01 01 27 00 00 02 02 00 04 04 10 10 00 00 00 00 00 00 00 00 00 00 21 21 21 21 21 18 18 18 1B 1B 00 00 04 04 00 02 02 03 03 00 00 00 00 00 00 00 00 27 01 27 00 00 02 02 00 04 04 0F 0F 09 09 09 09 09 09 09 09 09 09 00 21 21 21 21 16 16 16 16 1B 1B 00 04 04 00 02 02 03 03 00 00 00 00 00 00 00 00 00 27 27 27 27 00 00 02 02 00 04 04 0F 09 00 09 00 09 00 09 00 09 00 09 21 21 21 21 21 16 16 16 1B 1B 00 00 04 04 00 02 02 03 00 00 00 00 00 00 00 00 00 27 27 27 00 00 02 02 00 04 04 0F 0F 09 09 09 09 09 09 09 09 09 09 00 21 21 21 21 16 16 16 16 1A 1A 00 04 04 00 02 02 03 00 00 00 00 00 00 00 00 00 00 00 27 27 00 00 00 02 02 00 04 04 0F 0F 00 00 00 00 00 00 00 00 00 00 20 20 20 20 00 14 14 14 00 1A 00 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 27 00 00 00 02 02 00 04 04 0E 0E 0A 0A 0A 0A 0A 0A 0A 0A 0A 0A 00 20 20 20 20 00 14 14 00 1A 1A 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 0E 0A 00 0A 00 0A 00 0A 00 0A 00 0A 20 20 20 20 00 14 14 14 00 1A 00 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 0E 0E 0A 0A 0A 0A 0A 0A 0A 0A 0A 0A 00 20 20 20 20 00 14 14 00 1A 1A 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 0E 0E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 00 00 00 00 00 00 00 00
			openedFromAdmin = fromAdmin;
			
			maxRegionCount = G.user.hasDeluxeEditor() ? 250 : 40;
			//maxRegionCount = 40;
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);

			mapSprite = new Sprite();
			addChild(mapSprite);

			map = new MEMap(maxRegionCount, G.user.hasDeluxeEditor() ? 200 : 50);
			mapSprite.addChild(map);
			
			var mapMask:Sprite = new Sprite();
			mapMask.graphics.beginFill(0);
			mapMask.graphics.drawRect(0, 0, 570, 600);
			map.mask = mapMask;
			addChild(mapMask);

			map.Finalize();

			var mute:MutePanel = new MutePanel(true);
			mute.x = 6;
			mute.y = 6;
			addChild(mute);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 220, 26);
			editbox.x = 575;
			editbox.y = 10;
			addChild(editbox);
			
			mapName = new TextField();
			mapName.type = TextFieldType.INPUT;			
			mapName.defaultTextFormat = new TextFormat("Arial", 14, -1, true);
			mapName.autoSize = TextFieldAutoSize.LEFT;
			mapName.y = editbox.height / 2 - mapName.height / 2;
			mapName.autoSize = TextFieldAutoSize.NONE;
			mapName.x = 5;
			mapName.width = editbox.width - 10;
			mapName.maxChars = 32;
			mapName.addEventListener(KeyboardEvent.KEY_UP, onKeyPressed, false, 0, true);
			editbox.addChild(mapName);
			
		/**  B U T T O N S **/

			label = new TextField();
			label.text = "Edit mode:";
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 576;
			label.y = 50;
			label.mouseEnabled = false;
			addChild(label);
			
			var emboss:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 220, 48);
			emboss.x = 575;
			emboss.y = 70;
			addChild(emboss);
			
			mapBtn = new ButtonHex("MAP", onEditMapPressed, "button_small_gold", 14, -1, 104);
			mapBtn.x = 578;
			mapBtn.y = 74;
			mapBtn.setOnDownCallback(onButtonPressed);
			this.addChild(mapBtn);
			
			regionBtn = new ButtonHex("REGIONS", onEditRegionPressed, "button_small_gray", 14, -1, 104);
			regionBtn.x = 688;
			regionBtn.y = 74;
			this.addChild(regionBtn);

			saveRegionBtn = new ButtonHex("SAVE REGION", onSaveRegionPressed, "button_small_gold");
			saveRegionBtn.x = 575;
			saveRegionBtn.y = 128;
			saveRegionBtn.visible = false;
			this.addChild(saveRegionBtn);
			
			label = new TextField();
			label.text = "Clear:";
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 576;
			label.y = 176;
			label.mouseEnabled = false;
			addChild(label);
			
			emboss = new NinePatchSprite("9patch_emboss_panel", 220, 48);
			emboss.x = 575;
			emboss.y = 196;
			addChild(emboss);
			
			button = new ButtonHex("MAP", onClearMapPressed, "button_small_gray", 14, -1, 104);
			button.x = 3;
			button.y = 3;
			emboss.addChild(button);
			
			button = new ButtonHex("REGIONS", onClearRegionsPressed, "button_small_gray", 14, -1, 104);
			button.x = 113;
			button.y = 3;
			emboss.addChild(button);
			
			emboss = new NinePatchSprite("9patch_emboss_panel", 220, 50);
			emboss.x = 575;
			emboss.y = 270;
			addChild(emboss);
			
			label = new TextField();
			label.text = "SHIFT + Click to draw\nCTRL + Click to erase";
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 4;
			label.y = 6;
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			emboss.addChild(label);
			
			if(openedFromAdmin) {
				button = new ButtonHex("PREVIEW", function():void { new MapEditorPreviewCreator(mapKey);}, "button_small_gold");
				button.x = 575;
				button.y = 330;
				addChild(button);
			}
			
			var label:TextField = new TextField();
			label.text = "Map errors:";
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 576;
			label.y = 370;
			label.mouseEnabled = false;
			addChild(label);
			
			logList = new LogList();
			logList.x = 575;
			logList.y = 390;
			
			addChild(logList);
			logList.refresh();
			
			emboss = new NinePatchSprite("9patch_emboss_panel", 168, 28);
			emboss.x = 575;
			emboss.y = 506;
			addChild(emboss);
			
			label = new TextField();
			label.text = "Region count:";
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 3;
			label.y = 4;
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			emboss.addChild(label);
			
			// region counter
			regionCounter = new TextField();
			regionCounter.defaultTextFormat = new TextFormat("Arial", 14, -1, true);
			regionCounter.width = 140;
			regionCounter.x = 105;
			regionCounter.y = 4;
			regionCounter.autoSize = TextFieldAutoSize.LEFT
			regionCounter.text = "0/" + maxRegionCount;
			regionCounter.mouseEnabled = false;
			emboss.addChild(regionCounter);

			saveButton = new ButtonHex("SAVE", onSaveMapPressed, "button_small_gray");
			saveButton.x = 575;
			saveButton.y = 550;
			this.addChild(saveButton);
			
			button = new ButtonHex("EXIT", onExitPressed, "button_small_gray");
			button.x = 714;
			button.y = 550;
			button.setOnDownCallback(onButtonPressed);
			this.addChild(button);
			
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_SAVE_SUCCESSFUL, messageReceived);
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_SAVE_FAILED, messageReceived);			
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_LOAD_RESULT, messageReceived);
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_LOAD_FAILED, messageReceived);			
			
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, RemoveFromStage);
			
			loadingScreen = new Loading("LOADING...");
			addChild(loadingScreen);
			
			this.mapKey = mapKey;
			G.userConnection.send(MessageID.MAP_EDITOR_LOAD, mapKey);
			
			var butt:Button = new Button(null, onZoomIn, ResList.GetArtResource("map_zoom_in"));
			butt.x = 605 - button.width;
			butt.y = 7;
			addChild(butt);
			
			butt = new Button(null, onZoomOut, ResList.GetArtResource("map_zoom_out"));
			butt.x = 605 - button.width;
			butt.y = butt.height + 1;
			addChild(butt);
		}
		
		private function updateZoomLevel():void {
			var scaleValue:Number = 1;
			switch(zoomLevel) {
				case 0: scaleValue = 1; break;
				case 1: scaleValue = 0.75; break;
				case 2: scaleValue = 0.5; break;
				case 3: scaleValue = 0.25; break;
			}
			
			mapSprite.scaleX = mapSprite.scaleY = scaleValue;
			map.setMapScale(scaleValue);
		}
		
		private function onZoomIn(button:Button):void {
			zoomLevel--;
			if(zoomLevel < 0) zoomLevel = 0;
			
			updateZoomLevel();
		}
		
		private function onZoomOut(button:Button):void {
			zoomLevel++;			
			if(zoomLevel > 3) zoomLevel = 3;
			
			updateZoomLevel();
		}
		
		protected function onKeyPressed(event:KeyboardEvent):void {
			if(event.keyCode == Input.KEY_ENTER) {
				stage.focus = null;
			}
			else {
				setMapDirty(true);
			}
		}
		
		protected function setMapDirty(dirty:Boolean):void {
			isMapDirty = dirty;
			if(dirty) {
				saveButton.setImage("button_small_gold");
			}
			else {
				saveButton.setImage("button_small_gray");
			}
		} 
		
		public function loadMap(mapName:String, w:int, h:int, mapData:ByteArray):void {
			if(loadingScreen) {
				removeChild(loadingScreen);
				loadingScreen = null;
			}
			
			map.loadMap(w,h,mapData);
			this.mapName.text = mapName;
			
			var errors:Array = new Array();
			var er:String;
			var containsErrors:Boolean = false;
			for(var i:int = 1; i < map.getRegionCount() && !containsErrors; i++) {
				containsErrors = containsErrors || !map.saveRegion(i, errors);
			}
			if (!containsErrors) {
				for each (er in errors) {
					if (er.substr(0,2) == "W:") {
						this.logList.addWarning(er.substr(2));
					} else {
						this.logList.addError(er);
					}
				}
				// if region is ok, just show global errors
				performChecks();
				regionCounter.text = this.map.getRegionCount().toString() + "/" + maxRegionCount;
				//return true;
			} else {
				ErrorManager.showCustomError("There are errors with the region. Please check the log and fix them first.", ErrorManager.WARNING_IDLE, null);
				for each (er in errors) {
					if (er.substr(0,2) == "W:") {
						this.logList.addWarning(er.substr(2));
					} else {
						this.logList.addError(er);
					}
				}
				//return false;
			}
			//performChecks();
		}
			
		private function messageReceived(message:Message):void {
			switch (message.type) {
				case MessageID.MAP_EDITOR_SAVE_SUCCESSFUL : 
					ErrorManager.showCustomError2("Map has been saved successfully.", "SUCCESS", ErrorManager.WARNING_IDLE);
					setMapDirty(false);
					break;
				case MessageID.MAP_EDITOR_SAVE_FAILED:
					var err:String = message.getString(0);
					ErrorManager.showCustomError("There was an error during map saving. Map has not been saved!\n" + err, ErrorManager.WARNING_IDLE);
					break;
				case MessageID.MAP_EDITOR_LOAD_RESULT:
					// 0:String - map name
					// 1:int - map width
					// 2:int - map height
					// 3:byte array - map data
					mapName.text = message.getString(0);
					var w:int = message.getInt(1);
					var h:int = message.getInt(2);
					var data:ByteArray = message.getByteArray(3);
					
					loadMap(mapName.text, w, h, data);
					regionCounter.text = this.map.getRegionCount().toString() + "/" + maxRegionCount;
					break;
				case MessageID.MAP_EDITOR_LOAD_FAILED:
					ErrorManager.showCustomError("There was an error. Map has not been loaded!\n" + message.getString(0), ErrorManager.WARNING_IDLE);
					break;
			}
		}
		
		private function RemoveFromStage(event:Event):void {
			G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_SAVE_SUCCESSFUL, messageReceived); 
			G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_SAVE_FAILED, messageReceived); 
			G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_LOAD_RESULT, messageReceived);
			G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_LOAD_FAILED, messageReceived);
		}
		
/** ON XXX PRESSED - {{{ **/		
		private function onButtonPressed(event:MouseEvent):void {
			Input.mouseHandled = true;
		}
		
		private function onEditMapPressed():void {
			Input.mouseHandled = true;

			if (saveRegionBtn.visible) {
				if (this.saveActiveRegion()) {
					this.editMode = MODE_MAP;
					mapBtn.setImage("button_small_gold");
					regionBtn.setImage("button_small_gray");
					saveRegionBtn.visible = false;
				}
			} else {
				this.editMode = MODE_MAP;
				mapBtn.setImage("button_small_gold");
				regionBtn.setImage("button_small_gray");
			}
		}
		
		private function onEditRegionPressed():void {
			mapBtn.setImage("button_small_gray");
			regionBtn.setImage("button_small_gold");
			
			this.editMode = MODE_REGION;
			Input.mouseHandled = true;
			
		}

		private function onSaveRegionPressed():void {
			if (this.saveActiveRegion()) {
				saveRegionBtn.visible = false;
			}
			Input.mouseHandled = true;
		}
		
		private function onSaveMapPressed():void {
			if (mapName.text == "") {
				ErrorManager.showCustomError("Name cannot be empty.", ErrorManager.WARNING_IDLE);
				return;
			}			
			logList.clearLog();
			
			var isOK:Boolean = performChecks();
			map.prepareForSave();
			G.userConnection.send(MessageID.MAP_EDITOR_SAVE, mapKey, mapName.text, map.mapWidth, map.mapHeight, map.tilesAsByteArray(), !isOK);
		}
		
		private function onExitPressed():void {
			if(isMapDirty)
				ErrorManager.errorSprite.addChild(new ConfirmationDialog("Really exit?\nAll unsaved content will be lost.", "Yes", doExit, "No", null));
			else {
				doExit();
			}
		}
		
		private function doExit():void {
			removeEventListener(Event.ENTER_FRAME, Update);
			this.parent.addChild(openedFromAdmin ? new MapEditorAdmin() : new MapEditorHome());
			this.parent.removeChild(this);						
		}

		private function onClearMapPressed():void {
			ErrorManager.errorSprite.addChild(new ConfirmationDialog("Whole map and all regions will be deleted without UNDO option. Are you sure?", "Yes", doClearMap, "No", null));
		}
		
		private function doClearMap():void {
			this.map.clearMap();
			regionCounter.text = this.map.getRegionCount().toString() + "/" + maxRegionCount;
			setMapDirty(true);
		}
		
		private function onClearRegionsPressed():void {
			ErrorManager.errorSprite.addChild(new ConfirmationDialog("All regions will be deleted without UNDO option. Are you sure?", "Yes", doClearRegions, "No", null));
		}
		
		private function doClearRegions():void {
			this.map.clearRegions();
			regionCounter.text = this.map.getRegionCount().toString() + "/" + maxRegionCount;
			setMapDirty(true);
		}
		
/** ON XXX PRESSED - }}} **/
		
		// moving the map?
		private var moved:Boolean;
		private var validMapMove:Boolean;
		
		private function Update(event:Event):void	{
			
			if(stage == null) return;
			
			var mapMouseX:int;
			var mapMouseY:int;
			switch(zoomLevel) {
				case 0: mapMouseX = Input.mouseX; 
					mapMouseY = Input.mouseY;
					break;
				case 1: mapMouseX = Input.mouseX * 4 / 3;
					mapMouseY = Input.mouseY * 4 / 3;
					break;
				case 2: mapMouseX = Input.mouseX * 2;
					mapMouseY = Input.mouseY * 2;
					break;
				case 3: mapMouseX = Input.mouseX * 4;
					mapMouseY = Input.mouseY * 4;
					break;
			}
			
			if(Input.IsMouseReleased()) {
				validMapMove = false;
			}
			
			//if(Input.mouseX > 5 && Input.mouseX < 540 && Input.mouseY > 5 && Input.mouseY < 590) {
			if(Input.mouseX < 570) {
				if(stage.focus == null && Input.mouseLeft == Input.JUSTPRESSED && !Input.mouseHandled) {
					lastMouseDownX = mapMouseX;
					lastMouseDownY = mapMouseY;
					moved = false;
					validMapMove = true;
				}
				else {
					validMapMove = false;
				}

				if(Input.IsMousePressed() && (Input.IsKeyPressed(Input.KEY_SHIFT) || Input.IsKeyPressed(Input.KEY_CONTROL)) && lastDrawnX == -1) {
					lastDrawnX = mapMouseX;
					lastDrawnY = mapMouseY;
				} 
					
				if(stage.focus == null && (Input.mouseLeft == Input.PRESSED || Input.mouseLeft == Input.JUSTRELEASED) && !Input.mouseHandled) {
					// interpolation stuff used when drawing/erasing
					var deltaX:int = mapMouseX - lastDrawnX;
					var deltaY:int = mapMouseY - lastDrawnY;
					var dist:Number = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
					if(dist < 1) dist = 1;
					var offset:int = 0;

					if (editMode == MODE_MAP) {
						
						if (Input.IsKeyPressed(Input.KEY_SHIFT)) {
							// drawing map
							
							// interpolate if we moved really fast and fill in hexes in between
							do {
								drawMapTile(lastDrawnX + deltaX * offset / dist, lastDrawnY + deltaY * offset / dist);
								offset += 5;
							} while(offset < dist);
							
							map.redrawWorld();
							
							setMapDirty(true);
							
							lastDrawnX = mapMouseX;
							lastDrawnY = mapMouseY;
							
						} else if (Input.IsKeyPressed(Input.KEY_CONTROL)) {
							// erasing map
							do {
								eraseMapTile(lastDrawnX + deltaX * offset / dist, lastDrawnY + deltaY * offset / dist);
								offset += 5;
							} while(offset < dist);
							
							map.redrawWorld();
							//eraseMapTile(Input.mouseX, Input.mouseY);
							setMapDirty(true);
							
							lastDrawnX = mapMouseX;
							lastDrawnY = mapMouseY;
						} else {
							// moving
							if(Math.abs(lastMouseDownX - mapMouseX) > 2 || Math.abs(lastMouseDownY - mapMouseY) > 2 && validMapMove) {
								map.Move(mapMouseX - lastMouseDownX, mapMouseY - lastMouseDownY);
								
								lastMouseDownX = mapMouseX;
								lastMouseDownY = mapMouseY;
								
								moved = true;
							}
						}					
					} else if (editMode == MODE_REGION) { 						
						if (Input.IsKeyPressed(Input.KEY_SHIFT)) {
							// drawing
							do {
								drawRegionTile(lastDrawnX + deltaX * offset / dist, lastDrawnY + deltaY * offset / dist, false);
								offset += 5;
							} while(offset < dist);
							
							//drawRegionTile(Input.mouseX, Input.mouseY, false);
							setMapDirty(true);
							
							lastDrawnX = mapMouseX;
							lastDrawnY = mapMouseY;
						} else if (Input.IsKeyPressed(Input.KEY_CONTROL)) {
							// erasing region
							do {
								eraseRegionTile(lastDrawnX + deltaX * offset / dist, lastDrawnY + deltaY * offset / dist);
								offset += 5;
							} while(offset < dist);
							
							//eraseRegionTile(Input.mouseX, Input.mouseY);
							setMapDirty(true);
							
							lastDrawnX = mapMouseX;
							lastDrawnY = mapMouseY;
						} else {
							// moving map
							if(Math.abs(lastMouseDownX - mapMouseX) > 2 || Math.abs(lastMouseDownY - mapMouseY) > 2 && validMapMove) {
								map.Move(mapMouseX - lastMouseDownX, mapMouseY - lastMouseDownY);
								
								lastMouseDownX = mapMouseX;
								lastMouseDownY = mapMouseY;
								
								moved = true;
								
							} else {
								editRegion(mapMouseX, mapMouseY);
							}						
						}
					}
				}
				
				if(!Input.IsMousePressed() || !(Input.IsKeyPressed(Input.KEY_SHIFT) || Input.IsKeyPressed(Input.KEY_CONTROL))) {
					lastDrawnX = lastDrawnY = -1;
				}
				
				if (Input.IsKeyPressed(Input.KEY_SPACE) && editMode == MODE_REGION && saveRegionBtn.visible) {
					onSaveRegionPressed();
				}  
			}
			
			map.update(timeDelta);
			
			Input.Tick();
		}

		private function drawMapTile(x:int, y:int):void {
			this.map.addTileToWorld(x,y);
		}
				
		private function eraseMapTile(x:int, y:int):void {
			this.map.removeTileFromWorld(x,y);
		}
				
		private function drawRegionTile(x:int, y:int, overdraw:Boolean):void {
			if (this.map.addTileToCurrentRegion(x,y, overdraw)) {
				saveRegionBtn.visible = true;
			}
		}
				
		private function eraseRegionTile(x:int, y:int):void {
			if (this.map.removeTileFromCurrentRegion(x,y)) {
				saveRegionBtn.visible = false;	
				regionCounter.text = this.map.getRegionCount().toString() + "/" + maxRegionCount;
			}
		}
		
		private function editRegion(x:int, y:int):void {
			if (this.map.selectRegionToEdit(x,y)) {
				saveRegionBtn.visible = true;
			}
		}
		
		private function saveActiveRegion():Boolean {
			this.logList.clearLog();
			var errors:Array = new Array();
			var er:String;
			
			if (this.map.saveCurrentRegion(errors)) {
				for each (er in errors) {
					if (er.substr(0,2) == "W:") {
						this.logList.addWarning(er.substr(2));
					} else {
						this.logList.addError(er);
					}
				}
				// if region is ok, just show global errors
				performChecks();
				regionCounter.text = this.map.getRegionCount().toString() + "/" + maxRegionCount;
				return true;
			} else {
				ErrorManager.showCustomError("There are errors with the region. Please check the log and fix them first.", ErrorManager.WARNING_IDLE);
				for each (er in errors) {
					if (er.substr(0,2) == "W:") {
						this.logList.addWarning(er.substr(2));
					} else {
						this.logList.addError(er);
					}
				}
				return false;
			}
			
		}
		
		private function performChecks():Boolean {
			var ok:Boolean = true; 
			
			if (!this.map.checkRegionCount()) {
				//show error
				logList.addError("Number of regions must be more than 8 and less than " + maxRegionCount + ".");
				ok = false;
			} 
			if (!this.map.checkFullWorld()) {
				logList.addError("There is still unused ground with no region on it.");
				ok = false;
			} 
			if (!this.map.checkContinuity()) {
				// show error
				logList.addError("Map is not continuous. There are separated regions in the map.");
				ok = false;
			}
			return ok;
		}
	}
}