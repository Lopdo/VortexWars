package MapEditor
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	
	import Menu.ButtonHex;
	import Menu.ConfirmationDialog;
	import Menu.Loading;
	import Menu.Lobby.Slider;
	import Menu.MainMenu.MainMenu;
	import Menu.MainMenu.MenuShortcutsPanel;
	import Menu.NinePatchSprite;
	import Menu.Upgrades.ShopScreen;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIO;
	
	public class MapEditorHome extends Sprite
	{
		protected var mapListContent:Sprite;
		protected var loading:Loading;
		protected var mapListPanel:NinePatchSprite;
		
		private var contentSize:int;
		private var slider:Slider;
		private var sliderInitialized:Boolean = false;
		
		private var helpSprite:Sprite;
		private var helpSlider:Slider;
		private var helpSliderInitialized:Boolean = false;
		private var helpContentSize:int;
		
		private var activeSlider:Slider;

		public function MapEditorHome()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			mapListPanel = new NinePatchSprite("9patch_emboss_panel", 430, 420); 
			addChild(mapListPanel);
			mapListPanel.x = 10;
			mapListPanel.y = 60;
			
			var emboss:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 330, 420);
			emboss.x = 460;
			emboss.y = 60;
			addChild(emboss);
			
			helpSprite = new Sprite();
			helpSprite.y = 4;
			emboss.addChild(helpSprite);
			
			helpSlider = new Slider();
			helpSlider.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			helpSlider.useHandCursor = true;
			emboss.addChild(helpSlider);
			
			createHelpText();
			
			var mapLoadingSprite:Loading = new Loading("LOADING...", false);
			mapLoadingSprite.x = mapListPanel.width / 2 - mapLoadingSprite.width / 2;
			mapLoadingSprite.y = mapListPanel.height / 2 - mapLoadingSprite.height / 2;
			mapListPanel.addChild(mapLoadingSprite);
			
			mapListContent = new Sprite();
			mapListContent.y = 4;
			mapListPanel.addChild(mapListContent);
			//mapListContent.scrollRect = new Rectangle(0, 0, 408, 396);
			
			slider = new Slider();
			slider.setSize(396);
			slider.x = 413;
			slider.y = 4;
			slider.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			mapListPanel.addChild(slider);
			
			addChild(new MenuShortcutsPanel(onBack));
			
			G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void{
				mapListPanel.removeChild(mapLoadingSprite);

				G.user.mapSlots = playerobject.EditorSlots;
				G.user.playerObject = playerobject;
				
				if(playerobject.Maps.length > 0) {
					G.client.bigDB.loadKeys("CustomMaps", playerobject.Maps, function(mapObjects:Array):void {
						createMapList(mapObjects);	
					});
				}
				else {
					// send empty array
					createMapList(new Array());
				}
			});
			
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_DELETE_MAP_RESULT, messageReceived);
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_SUBMIT_MAP_RESULT, messageReceived);
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, messageReceived);
			
			if(G.localServer) {
				var self:DisplayObject = this;
				var button:ButtonHex = new ButtonHex("ADMIN OLD", function():void {parent.addChild(new MapEditorAdmin()); parent.removeChild(self);}, "button_small_gray");
				button.x = 100;
				button.y = 500;
				addChild(button);
			}
			
			if(G.user.playerObject.Moderator) {
				self = this;
				button = new ButtonHex("ADMIN", function():void {parent.addChild(new MapEditorAdminNew()); parent.removeChild(self);}, "button_small_gray");
				button.x = 700;
				button.y = 500;
				addChild(button);
			}
		}
		
		protected function refresh():void {
			while(mapListContent.numChildren > 0) mapListContent.removeChildAt(mapListContent.numChildren - 1);
			
			var mapLoadingSprite:Loading = new Loading("LOADING...", false);
			mapLoadingSprite.x = mapListPanel.width / 2 - mapLoadingSprite.width / 2;
			mapLoadingSprite.y = mapListPanel.height / 2 - mapLoadingSprite.height / 2;
			mapListPanel.addChild(mapLoadingSprite);

			G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void{
				mapListPanel.removeChild(mapLoadingSprite);
				
				G.user.mapSlots = playerobject.EditorSlots;
				G.user.playerObject = playerobject;
				
				if(playerobject.Maps.length > 0) {
					G.client.bigDB.loadKeys("CustomMaps", playerobject.Maps, function(mapObjects:Array):void {
						createMapList(mapObjects);	
					});
				}
				else {
					// send empty array
					createMapList(new Array());
				}
			});
		}
		
		protected function onBack():void {
			G.userConnection.addMessageHandler("*", messageReceived);
			
			this.parent.addChild(new MainMenu());
			this.parent.removeChild(this);
		}
		
		protected function messageReceived(message:Message):void {
			switch(message.type) {
				case MessageID.MAP_EDITOR_DELETE_MAP_RESULT:
					if(loading) {
						removeChild(loading);
						loading = null;
					}
					if(message.getInt(0) == -1) {
						refresh();
					}
					else {
						ErrorManager.showCustomError("Map couldn't be deleted (error " + message.getInt(0) + "). Please try again later", 0);
					}
					break;
				case MessageID.MAP_EDITOR_SUBMIT_MAP_NEW:
				case MessageID.MAP_EDITOR_SUBMIT_MAP_RESULT:
					if(message.getInt(0) == -1) {
						refresh();
					}
					else {
						if(message.getInt(0) == 1000) {
							ErrorManager.showCustomError("Map submission failed, there were errors in the map. Please fix them and submit the map again", 0);
						}
						else {
							ErrorManager.showCustomError("Map couldn't be submited (error " + message.getInt(0) + "). Please try again later", 0);
						}
					}
					break;
			}
		}
		
		protected function createMapList(maps:Array):void {
			mapListContent.scrollRect = null;
			var i:int, j:int;
			var yOffset:int = 4;
			for(i = 0; i < maps.length; i++) {
				createMapCell(maps[i], i, yOffset);
				yOffset += 110;
			}
			
			if(G.user.hasDeluxeEditor()) {
				for(j = i; j < G.user.mapSlots; j++) {
					createEmptyCell(j, yOffset);
					yOffset += 80;
				}
				createUnlockSlotCell(j, yOffset);
				yOffset += 110;
			}
			else {
				for(j = i; j < 3; j++) {
					createEmptyCell(j, yOffset);
					yOffset += 80;
				}
				createBuyDeluxeCell(j, yOffset);
				yOffset += 110;
			}

			contentSize = yOffset;
			
			if(mapListContent.height < 412) {
				slider.setSize(412);
				slider.y = 4;
			}
			else {
			var maxSize:int = 2000;
			var ratio:Number = mapListContent.height / maxSize;
			var size:int = 392 - ratio * 412;
			if(size < 40) size = 40;
			slider.setSize(size);
			slider.y = 4;
			}
			mapListContent.scrollRect = new Rectangle(0, 0, 408, 412);
		}
		
		protected function createEmptyCell(index:int, yOffset:int):void {
			var cellBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 400, 76); 
			mapListContent.addChild(cellBg);
			cellBg.x = 6;
			cellBg.y = yOffset;
			
			var label:TextField = new TextField();
			label.text = "EMPTY";
			label.setTextFormat(new TextFormat("Arial", 24, -1, true));
			label.x = 20;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = cellBg.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			cellBg.addChild(label);
			
			var button:ButtonHex = new ButtonHex("CREATE NEW", onNewMapClicked, "button_small_gold");
			button.x = cellBg.width - button.width - 10;
			button.y = cellBg.height / 2 - button.height / 2;
			cellBg.addChild(button);
		}
		
		protected function createMapCell(map:DatabaseObject, index:int, yOffset:int):void {
			var cellBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 400, 106); 
			mapListContent.addChild(cellBg);
			cellBg.x = 6;
			cellBg.y = yOffset;
			
			var tf:TextFormat = new TextFormat("Arial", 20, -1, true);
			
			var label:TextField = new TextField();
			label.text = map.Name;
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			while(label.width > 280) {
				tf.size = (int)(tf.size) - 1;
				label.setTextFormat(tf);
			}
			label.y = 8;
			cellBg.addChild(label);
			
			label = new TextField();
			if(map.Status == 0) {
				if(map.ContainsErrors) {
					label.text = "Contains errors";
				}
				else {
					label.text = "Ready for submision";
				}
			}
			else if(map.Status == 1) {
				label.text = "Waiting for review";
			}
			else if(map.Status == 2) {
				label.text = "Submited";
			}
			else if(map.Status == 3) {
				label.text = "Denied: " + map.DenyReason;
			}
			label.setTextFormat(new TextFormat("Arial", 14, 0xAAAAAA, true));
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = 36;
			cellBg.addChild(label);
			
			var button:ButtonHex;
			
			if(map.Status == 0 || map.Status == 3) {
				button = new ButtonHex("EDIT", function():void { onEditMapClicked(map.key); }, "button_small_gold", 14, -1, 100);
				button.x = cellBg.width - button.width - 10;
				button.y = 10;
				cellBg.addChild(button);
			}
			
			if(map.Status != 2) {
				button = new ButtonHex("DELETE", function():void { onDeleteMapClicked(map.key); }, "button_small_gray", 14, -1, 100);
				button.x = cellBg.width - button.width - 10;
				button.y = 56;
				cellBg.addChild(button);
			}
			else {
				var s:Sprite = new Sprite();
				s.x = cellBg.width - 110;
				s.y = cellBg.height / 2 - 50;
				cellBg.addChild(s);
				
				//var req:URLRequest = new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/MapImages/" + map.key + ".png"));
				var req:URLRequest = new URLRequest("http://vortexwars.com/maps/" + map.key + ".png");
				var loader:Loader = new Loader();
				loader.load(req);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {s.addChild(loader.content);}, false, 0, true);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (error:IOErrorEvent):void {}, false, 0, true);
			}
			
			if(map.Status == 0 && !map.ContainsErrors) {
				button = new ButtonHex("SUBMIT", function():void { onSubmitMapClicked(map.key); }, "button_small_gray");
				button.x = 10;
				button.y = 56;
				cellBg.addChild(button);
			}
		}
		
		protected function createUnlockSlotCell(index:int, yOffset:int):void {
			var cellBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 400, 96); 
			mapListContent.addChild(cellBg);
			cellBg.x = 6;
			cellBg.y = yOffset + 10;
			
			var label:TextField = new TextField();
			label.text = "LOCKED";
			label.setTextFormat(new TextFormat("Arial", 20, -1, true));
			label.x = 20;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = 10;
			label.mouseEnabled = false;
			cellBg.addChild(label);
			
			label = new TextField();
			label.text = "Buy additional slots in shop";
			label.setTextFormat(new TextFormat("Arial", 18, -1, true));
			label.x = 20;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = 38;
			label.mouseEnabled = false;
			cellBg.addChild(label);
			
			var button:ButtonHex = new ButtonHex("SHOP", onShopClicked, "button_small_gold");
			button.x = cellBg.width - button.width - 10;
			button.y = cellBg.height / 2 - button.height / 2;
			cellBg.addChild(button);
		}
		
		protected function createBuyDeluxeCell(index:int, yOffset:int):void {
			var cellBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 400, 96); 
			mapListContent.addChild(cellBg);
			cellBg.x = 6;
			cellBg.y = yOffset + 10;
			
			var label:TextField = new TextField();
			label.text = "Buy Deluxe editor to\nunlock aditional slots";
			label.setTextFormat(new TextFormat("Arial", 20, -1, true));
			label.x = 20;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = cellBg.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			cellBg.addChild(label);
			
			var button:ButtonHex = new ButtonHex("SHOP", onShopClicked, "button_small_gold");
			button.x = cellBg.width - button.width - 10;
			button.y = cellBg.height / 2 - button.height / 2;
			cellBg.addChild(button);
		}
		
		protected function onShopClicked():void {
			parent.addChild(new ShopScreen(6));
			parent.removeChild(this);
		}
		
		protected function onNewMapClicked():void {
			addChild(new MENewMapWindow());
		}
		
		public function mapCreated(mapKey:String):void {
			parent.addChild(new MapEditorScreen(mapKey));
			parent.removeChild(this);
		}
		
		protected function onEditMapClicked(mapKey:String):void {
			//mapKey = "srhKfJGJ202uVMXHa1Evnw";
			parent.addChild(new MapEditorScreen(mapKey));
			parent.removeChild(this);
		}
		
		protected function onDeleteMapClicked(mapKey:String):void {
			addChild(new ConfirmationDialog("Are you sure you want to delete this map? This action can't be undone", "DELETE", function():void {onDeleteConfirmed(mapKey);}, "CANCEL")); 
		}
		
		protected function onDeleteConfirmed(mapKey:String):void {
			loading = new Loading("DELETING...");
			addChild(loading);
			
			G.userConnection.send(MessageID.MAP_EDITOR_DELETE_MAP, mapKey);
		}
		
		protected function onSubmitMapClicked(mapKey:String):void {
			addChild(new ConfirmationDialog("Are you sure you want to submit this map for review? You will not be able to change map afterwards", "SUBMIT", function():void {onSubmitConfirmed(mapKey);}, "CANCEL"));
		}
		
		protected function onSubmitConfirmed(mapKey:String):void {
			G.userConnection.send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, mapKey);
		}
		
		private var previousMouseY:int = -1;
		private function onMouseDown(event:MouseEvent):void {
			if(mapListContent.height < mapListContent.scrollRect.height) {
				mapListContent.scrollRect = new Rectangle(0, 0, 408, 412);
				return;
			}
			
			activeSlider = event.target == slider ? slider : helpSlider;
			
			previousMouseY = event.stageY;
			
			if(!sliderInitialized) {
				parent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				sliderInitialized = true;
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if(previousMouseY != -1) {
				var offsetY:int = event.stageY - previousMouseY;
				previousMouseY = event.stageY;
				
				if(activeSlider == helpSlider) {
					var maxOffsetY:int = 412 - helpSlider.size;
					
					helpSlider.y += offsetY;
					if(helpSlider.y < 4) helpSlider.y = 4;
					if(helpSlider.y > 4 + maxOffsetY) helpSlider.y = 4 + maxOffsetY;
					
					var progressRatio:Number = (helpSlider.y - 4) / maxOffsetY;
					var newHeight:int = (helpContentSize - 412) * progressRatio;
					if(newHeight < 0) newHeight = 0;
					helpSprite.scrollRect = new Rectangle(0, newHeight, 330, 412);
				}
				else {
					maxOffsetY = 412 - slider.size;
					
					slider.y += offsetY;
					if(slider.y < 4) slider.y = 4;
					if(slider.y > 4 + maxOffsetY) slider.y = 4 + maxOffsetY;
					
					progressRatio = (slider.y - 4) / maxOffsetY;
					newHeight = (contentSize - 412) * progressRatio;
					if(newHeight < 0) newHeight = 0;
					mapListContent.scrollRect = new Rectangle(0, newHeight, 408, 412);
				}
			}
		}
		
		private function onMouseUp(event:MouseEvent):void {
			previousMouseY = -1;
		}
		
		private function createHelpText():void {
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			if(G.user.hasDeluxeEditor()) {
				var label:TextField = new TextField();
				label.text = "Deluxe Editor";
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.CENTER;
				label.x = helpSprite.parent.width / 2 - label.width / 2;
				label.y = 4;
				label.mouseEnabled = false;
				helpSprite.addChild(label);
				
				var offsetY:int = 4 + label.height + 10;
				
				tf.size = 14;
				tf.bold = false;
				
				label = new TextField();
				label.text = "The Deluxe editor allows you to buy additional map save slots. To do that, go to the Shop and click on the Map Editor tab.\n\nThe limit for number of regions has been raised to 250, so now you can make larger maps.";
				label.setTextFormat(tf);
				label.x = 10;
				label.width = helpSprite.parent.width - 30;
				label.y = offsetY;
				label.multiline = true;
				label.wordWrap = true;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				helpSprite.addChild(label);
				
				offsetY += label.height + 18;
			}
			else {
				label = new TextField();
				label.text = "Free Editor";
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.CENTER;
				label.x = helpSprite.parent.width / 2 - label.width / 2;
				label.y = 4;
				label.mouseEnabled = false;
				helpSprite.addChild(label);
				
				offsetY = 4 + label.height + 10;
				
				tf.size = 14;
				tf.bold = false;
				
				label = new TextField();
				label.text = "The Free editor allows you to make 3 different maps and you are limited to 40 regions per map and smaller canvas. If you wish to make larger or more maps, you will need to purchase the Deluxe editor.\n\nThe Deluxe Editor allows you to make maps with 250 regions, gives you two additional save slots and allows you to unlock more slots if you need them.";
				label.setTextFormat(tf);
				label.x = 10;
				label.width = helpSprite.parent.width - 30;
				label.y = offsetY;
				label.multiline = true;
				label.wordWrap = true;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				helpSprite.addChild(label);
				
				offsetY += label.height + 18;
			}
			
			tf.size = 16;
			tf.bold = true;
			
			label = new TextField();
			label.text = "Map editing";
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.x = 10;
			label.y = offsetY;
			label.mouseEnabled = false;
			helpSprite.addChild(label);
			
			offsetY += label.height + 10;
			
			tf.size = 14;
			tf.bold = false;
			
			label = new TextField();
			label.text = "To begin creating your map, click the CREATE NEW button on one of the available slots and enter a map name or click the EDIT button to resume work on an existing map you have previously saved. This will take you to the editing screen.\n\nCreation of map consists of two steps:\n1. First you create map terrain that will outline shape of map. Completely fill in the area of map where regions will exist.\n2. Second, draw regions on top of that filled map terrain. Create one region at a time and click SAVE REGION (or press SPACE) after drawing each region. Once region is saved, you can create your next region.\n\nNotes: Draw mode (MAP or REGIONS) is switched with buttons in top right corner of the screen. Drawing itself is very simple. You draw using your mouse. Hold SHIFT to draw new tiles, CTRL to erase tiles.";
			label.setTextFormat(tf);
			label.x = 10;
			label.width = helpSprite.parent.width - 30;
			label.y = offsetY;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			helpSprite.addChild(label);
			
			offsetY += label.height + 18;
			
			tf.size = 16;
			tf.bold = true;
			
			label = new TextField();
			label.text = "Map Rules";
			label.setTextFormat(tf);
			label.x = 10;
			label.width = helpSprite.parent.width - 30;
			label.y = offsetY;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			helpSprite.addChild(label);
			
			offsetY += label.height + 10;
			
			tf.size = 14;
			tf.bold = false;
			
			label = new TextField();
			label.text = "There are few basic rules map need to follow to be valid map:\n1. All map tiles need to be covered by regions\n2. Each map has to contain at least 8 regions\n3. Regions can't be too small; minumum size for a region is 5 tiles in group\n4. All regions must be connected. You can't make separate islands.\n\nIn addition to those rules, here is couple of best practices to make the most out of your map:\n -  Don't make regions too big. Maps may get too big and less regions are visible\n -  Make at least 12-16 regions for small maps such that each player has chance to expand at least once";
			label.setTextFormat(tf);
			label.x = 10;
			label.width = helpSprite.parent.width - 30;
			label.y = offsetY;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			helpSprite.addChild(label);
			
			offsetY += label.height + 18;
			
			tf.size = 16;
			tf.bold = true;
			
			label = new TextField();
			label.text = "Map Submission";
			label.setTextFormat(tf);
			label.x = 10;
			label.width = helpSprite.parent.width - 30;
			label.y = offsetY;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			helpSprite.addChild(label);
			
			offsetY += label.height + 10;
			
			tf.size = 14;
			tf.bold = false;
			
			label = new TextField();
			label.text = "Each map needs to be submited to make it is visible to the public. To submit a map:\n1. Make sure it doesn't contain any errors\n2. Press the SUBMIT button which should appear underneath the map name.\n\nNotes: Maps can't be edited or deleted after being submitted, so make sure that you really want to submit that map.\n\nYour map will be denied if it contains inapropriate imagery or has an inapropriate name. If the map contains extremely inapropriate content, submiting such map may lead to 3 days ban. Please be civil about what you make and share.\n\nIf your map gets denied, you will need to change it and resubmit again.";
			label.setTextFormat(tf);
			label.x = 10;
			label.width = helpSprite.parent.width - 30;
			label.y = offsetY;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			helpSprite.addChild(label);
			
			offsetY += label.height + 10;
			
			helpSlider.setSize(200);
			helpSlider.x = 313;
			helpSlider.y = 4;
			helpSlider.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			
			helpContentSize = offsetY;
			
			helpSprite.scrollRect = new Rectangle(0, 0, 330, 412);
		}
	}
}