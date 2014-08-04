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
	import playerio.PlayerIOError;
	
	public class MapEditorAdminNew extends Sprite
	{
		protected var mapListContent:Sprite;
		protected var loading:Loading;
		protected var mapListPanel:NinePatchSprite;
		
		private var contentSize:int;
		private var slider:Slider;
		private var sliderInitialized:Boolean = false;
		
		public function MapEditorAdminNew()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			mapListPanel = new NinePatchSprite("9patch_emboss_panel", 530, 400); 
			addChild(mapListPanel);
			mapListPanel.x = 40;
			mapListPanel.y = 80;
			
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
			slider.x = 513;
			slider.y = 4;
			slider.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			mapListPanel.addChild(slider);
			
			addChild(new MenuShortcutsPanel(onBack));
			
			G.client.bigDB.loadRange("CustomMaps", "status", [4], null, null, 9, function(maps:Array):void {
				createMapList(maps);
				mapListPanel.removeChild(mapLoadingSprite);
			}, function(error:PlayerIOError):void {
				//mapListSprite.removeChild(loading);
				ErrorManager.showPIOError(error);
				mapListPanel.removeChild(mapLoadingSprite);
			});
			
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_ALLOW_MAP_RESULT, messageReceived);
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_DENY_MAP_RESULT, messageReceived);
		}
		
		protected function refresh():void {
			while(mapListContent.numChildren > 0) mapListContent.removeChildAt(mapListContent.numChildren - 1);
			
			var mapLoadingSprite:Loading = new Loading("LOADING...", false);
			mapLoadingSprite.x = mapListPanel.width / 2 - mapLoadingSprite.width / 2;
			mapLoadingSprite.y = mapListPanel.height / 2 - mapLoadingSprite.height / 2;
			mapListPanel.addChild(mapLoadingSprite);

			G.client.bigDB.loadRange("CustomMaps", "status", [4], null, null, 9, function(maps:Array):void {
				createMapList(maps);
				mapListPanel.removeChild(mapLoadingSprite);
			}, function(error:PlayerIOError):void {
				//mapListSprite.removeChild(loading);
				ErrorManager.showPIOError(error);
				mapListPanel.removeChild(mapLoadingSprite);
			});
		}
		
		protected function onBack():void {
			G.userConnection.addMessageHandler("*", messageReceived);
			
			this.parent.addChild(new MapEditorHome());
			this.parent.removeChild(this);
		}
		
		protected function messageReceived(message:Message):void {
			switch(message.type) {
				case MessageID.MAP_EDITOR_DENY_MAP_RESULT:
					if(loading) {
						removeChild(loading);
						loading = null;
					}
					if(message.getInt(0) == -1) {
						refresh();
					}
					else {
						ErrorManager.showCustomError("Map couldn't be denied (error " + message.getInt(0) + "). Please try again later", 0, null);
					}
					break;
				case MessageID.MAP_EDITOR_ALLOW_MAP_RESULT:
					if(loading) {
						removeChild(loading);
						loading = null;
					}
					if(message.getInt(0) == -1) {
						refresh();
					}
					else {
						ErrorManager.showCustomError("Map couldn't be allowed (error " + message.getInt(0) + "). Please try again later", 0, null);
					}
					break;
				case MessageID.MAP_EDITOR_BAN:
					if(loading) {
						removeChild(loading);
						loading = null;
					}
					if(message.getInt(0) == -1) {
						refresh();
					}
					else {
						ErrorManager.showCustomError("User ban failed (error " + message.getInt(0) + "). Please try again later", 0, null);
					}
					break;
			}
		}
		
		protected function createMapList(maps:Array):void {
			var i:int, j:int;
			var yOffset:int = 4;
			for(i = 0; i < maps.length; i++) {
				submisionMapCell(maps[i], i, yOffset);
				yOffset += 110;
			}

			contentSize = mapListContent.height;
			
			var maxSize:int = 2000;
			var ratio:Number = mapListContent.height / maxSize;
			var size:int = 392 - ratio * 396;
			if(size < 40) size = 40;
			slider.setSize(size);
			slider.y = 4;
			
			contentSize = yOffset;
			
			mapListContent.scrollRect = new Rectangle(0, 0, 508, 396);
		}
		
		protected function submisionMapCell(map:DatabaseObject, index:int, yOffset:int):void {
			var cellBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 500, 106); 
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
			label.text = map.OwnerName;
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = 30;
			cellBg.addChild(label);
			
			/*label = new TextField();
			label.text = map.OwnerName;
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 130;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = 66;
			cellBg.addChild(label);*/
			
			var sprite:Sprite = new Sprite();
			sprite.x = cellBg.width - 103;
			sprite.y = 3;
			cellBg.addChild(sprite);
			
			//var req:URLRequest = new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/MapImages/" + map.key + ".png"));
			var req:URLRequest = new URLRequest("http://vortexwars.com/maps/" + map.key + ".png");
			var loader:Loader = new Loader();
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
				sprite.addChild(loader.content);
			}, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (error:IOErrorEvent):void { trace(error);}, false, 0, true);
			
			var button:ButtonHex;
			
			button = new ButtonHex("SHOW", function():void { onEditMapClicked(map.key); }, "button_small_gray", 14, -1, 100);
			button.x = cellBg.width - button.width - 110;
			button.y = 10;
			cellBg.addChild(button);
			
			button = new ButtonHex("ALLOW", function():void { onSubmitMapClicked(map.key); }, "button_small_gold");
			button.x = 10;
			button.y = 56;
			cellBg.addChild(button);
			
			button = new ButtonHex("DENY", function():void { onDenyMapClicked(map.key); }, "button_small_gray", 14, -1, 100);
			button.x = 110;
			button.y = 56;
			cellBg.addChild(button);
			
			button = new ButtonHex("BAN", function():void { onBanClicked(map.key); }, "button_small_gray", 14, -1, 100);
			button.x = cellBg.width - button.width - 110;
			button.y = 56;
			cellBg.addChild(button);
		}
		
		protected function onEditMapClicked(mapKey:String):void {
			parent.addChild(new MapEditorScreen(mapKey, false));
			parent.removeChild(this);
		}
		
		protected function onDenyMapClicked(mapKey:String):void {
			addChild(new MapEditorAdminDenyWindow(mapKey));
			//addChild(new ConfirmationDialog("Please state e", "DELETE", function():void {onDeleteConfirmed(mapKey);}, "CANCEL")); 
		}
		
		public function onDenyConfirmed(mapKey:String, reason:String):void {
			loading = new Loading("DELETING...");
			addChild(loading);
			
			G.userConnection.send(MessageID.MAP_EDITOR_DENY_MAP, mapKey, reason);
		}
		
		protected function onSubmitMapClicked(mapKey:String):void {
			addChild(new ConfirmationDialog("Are you sure you want to allow this map?", "ALLOW", function():void {onSubmitConfirmed(mapKey);}, "CANCEL"));
		}
		
		protected function onSubmitConfirmed(mapKey:String):void {
			G.userConnection.send(MessageID.MAP_EDITOR_ALLOW_MAP, mapKey);
		}
		
		protected function onBanClicked(mapKey:String):void {
			addChild(new ConfirmationDialog("Are you sure you want to ban author of this map for 3 days?", "BAN", function():void {onBanConfirmed(mapKey);}, "CANCEL"));
		}
		
		protected function onBanConfirmed(mapKey:String):void {
			G.userConnection.send(MessageID.MAP_EDITOR_BAN, mapKey);
		}
		
		
		private var previousMouseY:int = -1;
		private function onMouseDown(event:MouseEvent):void {
			if(mapListContent.height < mapListContent.scrollRect.height) {
				mapListContent.scrollRect = new Rectangle(0, 0, 508, 396);
				return;
			}
			
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
				var maxOffsetY:int = 392 - slider.size;
				slider.y += offsetY;
				if(slider.y < 4) slider.y = 4;
				if(slider.y > 4 + maxOffsetY) slider.y = 4 + maxOffsetY;
				
				var progressRatio:Number = (slider.y - 4) / maxOffsetY;
				var newHeight:int = (contentSize - 392) * progressRatio;
				if(newHeight < 0) newHeight = 0;
				mapListContent.scrollRect = new Rectangle(0, newHeight, 508, 396);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void {
			previousMouseY = -1;
		}
	}
}