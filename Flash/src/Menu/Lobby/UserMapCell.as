package Menu.Lobby
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ConfirmationDialog;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIO;
	
	public class UserMapCell extends Sprite
	{
		private var imageSprite:Sprite;
		private var loader:Loader;
		
		private var mapObject:DatabaseObject;
		private var mapPicker:UserMapPicker;
		
		private var bg:Sprite;
		private var emboss:NinePatchSprite;
		
		//private var ratingSprite:Sprite;
		private var mapRatingSprite:UserMapRating;
		
		private var loading:Loading;
		
		public function UserMapCell(mapObj:DatabaseObject, picker:UserMapPicker)
		{
			super();
			
			mapPicker = picker;
			mapObject = mapObj;
			
			bg = new Sprite();
			bg.addChild(ResList.GetArtResource("lobby_map_cell_bg"));
			addChild(bg);
			bg.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			bg.useHandCursor = true;
			bg.buttonMode = true;
			
			var label:TextField = new TextField();
			label.text = mapObject.Name;
			label.setTextFormat(new TextFormat("Arial", 18, -1, true));
			label.x = 10;
			label.y = 4;
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			addChild(label);
			
			label = new TextField();
			label.text = mapObject.OwnerName;
			label.setTextFormat(new TextFormat("Arial", 14, 0xAAAAAA, true));
			label.x = 10;
			label.y = 30;
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			addChild(label);
			
			imageSprite = new Sprite();
			imageSprite.x = width - 50 - 10;
			imageSprite.y = 2;
			imageSprite.mouseEnabled = false;
			imageSprite.scaleX = imageSprite.scaleY = 0.5;
			addChild(imageSprite);
			
			//var req:URLRequest = new URLRequest( PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/MapImages/" + mapObject.key + ".png"));
			var req:URLRequest = new URLRequest("http://vortexwars.com/maps/" + mapObject.key + ".png");
			loader = new Loader();
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageDownloaded, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (error:IOErrorEvent):void {}, false, 0, true);
			
			emboss = new NinePatchSprite("9patch_emboss_panel", 148, 26);
			emboss.x = 162;
			emboss.y = 26;
			bg.addChild(emboss);
			
			mapRatingSprite = new UserMapRating(mapObject);
			mapRatingSprite.x = 4;
			mapRatingSprite.y = 1;
			emboss.addChild(mapRatingSprite);
			
			if(mapObj.RegionCount) {
				label = new TextField();
				label.text = "R:" + mapObj.RegionCount;
				label.setTextFormat(new TextFormat("Arial", 12, -1, true));
				label.autoSize = TextFieldAutoSize.LEFT;
				label.x = emboss.width + emboss.x + 4;
				label.y = emboss.y + emboss.height / 2 - label.height / 2;
				label.selectable = false;
				addChild(label);
				
				new TextTooltip("Region count", label);
			}

			if(mapObj.MapSize) {
				label = new TextField();
				switch(mapObj.MapSize) {
					case 0: label.text = "S"; break;
					case 1: label.text = "M"; break;
					case 2: label.text = "L"; break;
					case 3: label.text = "XL"; break;
					case 4: label.text = "XXL"; break;
				}
				
				label.setTextFormat(new TextFormat("Arial", 12, -1, true));
				label.autoSize = TextFieldAutoSize.LEFT;
				label.x = emboss.width + emboss.x + 40;
				label.y = emboss.y + emboss.height / 2 - label.height / 2;
				label.selectable = false;
				//label.mouseEnabled = false;
				addChild(label);
				
				new TextTooltip("Map size", label);
			}
			
			if(!G.user.isGuest) {
				var button:Button = new Button("", onReportPressed, ResList.GetArtResource("button_map_report"));
				button.x = width - button.width + 5;
				button.y = -5;
				addChild(button);
				
				new TextTooltip("Report map", button);
				
				G.userConnection.addMessageHandler(MessageID.REPORT_MAP, onMessageReceived);
				addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			}
		}
		
		private function onRemovedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			G.userConnection.removeMessageHandler(MessageID.REPORT_MAP, onMessageReceived);
		}
		
		private function onImageDownloaded(event:Event):void {
			imageSprite.addChild(loader.content);
		}
		
		private function onClick(event:MouseEvent):void {
			var b:Bitmap = Bitmap(imageSprite.numChildren > 0 ? imageSprite.getChildAt(0) : null);
			if(b) {
				b = new Bitmap(b.bitmapData);
			}
			mapPicker.selectMap(mapObject.key, b);
			
			bg.removeChildAt(0);
			bg.addChildAt(ResList.GetArtResource("lobby_map_cell_bg_selected"), 0);
		}
		
		public function deselect():void {
			bg.removeChildAt(0);
			bg.addChildAt(ResList.GetArtResource("lobby_map_cell_bg"), 0);
		}
		
		private function onReportPressed(button:Button):void {
			stage.addChild(new ConfirmationDialog("Please use the report button only if the map contains inapropriate content. Blatant misuse of the report button is not allowed", "REPORT", onReportConfirmed, "CANCEL"));
		}
		
		private function onReportConfirmed():void {
			loading = new Loading("REPORTING...");
			loading.x = mapPicker.width / 2 - loading.width / 2;
			loading.y = mapPicker.height / 2 - loading.height / 2;
			mapPicker.addChild(loading);

			G.userConnection.send(MessageID.REPORT_MAP, mapObject.key);
		}
		
		private function onMessageReceived(message:Message):void {
			if(message.type == MessageID.REPORT_MAP) {
				if(loading) {
					mapPicker.removeChild(loading);
					loading = null;
				}
				if(message.getInt(0) == 0) {
					ErrorManager.showCustomError2("Map reported, thank you!", "SUCCESS", 0);
				}
				else {
					ErrorManager.showCustomError2("Map reporting failed, please try again later", "ERROR", 0);
				}
			}
		}
	}
}