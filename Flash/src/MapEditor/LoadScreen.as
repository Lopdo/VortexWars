package MapEditor
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	import IreUtils.Input;
	
	import Menu.Button;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIOError;

	public class LoadScreen extends Sprite
	{
		private var mapName:TextField;
		private var button:Button;
		private var owner:MapEditorScreen;
		
		public function LoadScreen(owner : MapEditorScreen)
		{
			super();
			
			this.owner = owner;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 12;
			tf.bold = false;
			tf.color = -1;
			tf.align = TextFormatAlign.LEFT;
			
			mapName = new TextField();
			mapName.width = 300;
			mapName.border = true;
			mapName.borderColor = 0xCCCCCC;
			mapName.textColor = 0xFFFFFF;
			mapName.selectable = true;
			mapName.multiline = mapName.wordWrap = false;
			mapName.x = 200;
			mapName.y = 110;
			mapName.height = 20;
			mapName.type = TextFieldType.INPUT;			
			mapName.maxChars = 32;
			mapName.restrict = "a-zA-Z0-9_";			
			mapName.text = "worldmap";
			
			addChild(mapName);
			
			button = new Button("Load", onLoadMapPressed, ResList.GetArtResource("button_small_blue"), 14);
			button.x = 400;
			button.y = 150;
			this.addChild(button);
			
			button = new Button("Cancel", onCancelPressed, ResList.GetArtResource("button_small_blue"), 14);
			button.x = 500;
			button.y = 150;
			this.addChild(button);

			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_LOAD_RESULT, messageReceived);
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_LOAD_FAILED, messageReceived);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);

		}
		
		private function onKeyPressed(event:KeyboardEvent):void {
			if (event.keyCode == Input.KEY_ENTER) {
				onLoadMapPressed();
			}			
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.focus = mapName;
		}
		
		private function onLoadMapPressed():void {
			G.userConnection.send(MessageID.MAP_EDITOR_LOAD, mapName.text);
		}
		
		private function onCancelPressed():void {
			G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_LOAD_RESULT, messageReceived); 
			G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_LOAD_FAILED, messageReceived); 

			owner.cancelLoad();
		}

		private function messageReceived(message:Message):void {
			switch (message.type) {
				case MessageID.MAP_EDITOR_LOAD_RESULT:
					// 0:String - map name
					// 1:int - map width
					// 2:int - map height
					// 3:byte array - map data
					// 4:String - map ID
					try {
						mapName.text = message.getString(0);
						var w:int = message.getInt(1);
						var h:int = message.getInt(2);
						var data:ByteArray = message.getByteArray(3);
						var mapID:string = message.getString(4);
						G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_LOAD_RESULT, messageReceived); 
						G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_LOAD_FAILED, messageReceived); 
						
						owner.loadMap(mapID, mapName.text, w, h, data); 
					}
					catch(err:Error) {
						G.client.errorLog.writeError("LoadScreen.as - MAP_EDITOR_LOAD_RESULT", "mapName: " + mapName + ", error: " + err.errorID, err.getStackTrace(), null);
					}
					break;
				case MessageID.MAP_EDITOR_LOAD_FAILED:
					var err:String = message.getString(0);
					ErrorManager.showCustomError("There was an error. Map has not been loaded!\n" + err, ErrorManager.WARNING_IDLE);
					break;
			}
		}

	}
}