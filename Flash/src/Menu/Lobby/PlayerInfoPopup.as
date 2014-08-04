package Menu.Lobby
{
	import Errors.ErrorManager;
	
	import IreUtils.Input;
	
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import playerio.Message;
	
	public class PlayerInfoPopup extends Sprite
	{
		private var bg:NinePatchSprite;
		private var content:Sprite;
		
		private var loading:Loading;
		
		private var matches:int, wins:int;
		
		private var playerKey:String;
		private var playerCell:LobbyChatPlayer;
		
		public function PlayerInfoPopup(playerId:String, posX:int, posY:int, offsetHeight:int, playerCell:LobbyChatPlayer)
		{
			super();
			
			this.playerCell = playerCell;
			
			playerKey = playerId;
			
			graphics.beginFill(0, 0.3);
			graphics.drawRect(0, 0, 800, 600);
			graphics.beginFill(0, 0);
			graphics.drawRect(posX, posY - height, 136, height);
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			bg = new NinePatchSprite("9patch_context", 136, 150);
			bg.x = posX;
			if(posY + bg.height > 580) {
				bg.y = posY - offsetHeight - bg.height;
			}
			else {
				bg.y = posY;
			}
			
			addChild(bg);
			
			content = new Sprite();
			bg.addChild(content);
			
			loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			G.userConnection.addMessageHandler(MessageID.SOCIAL_GET_PLAYER_INFO, onPlayerInfoReceived);
			G.userConnection.addMessageHandler(MessageID.SOCIAL_ADD_FRIEND, onAddFriendReceived);
			G.userConnection.addMessageHandler(MessageID.SOCIAL_ADD_TO_BLACKLIST, onAddToBlacklistReceived);
			G.userConnection.send(MessageID.SOCIAL_GET_PLAYER_INFO, playerId);
		}
		
		private function fillPlayerInfo(isFriend:Boolean, isBlacklisted:Boolean):void {
			while(content.numChildren > 0) content.removeChildAt(content.numChildren - 1);
			
			content.visible = true;
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1);
			
			var label:TextField = new TextField();
			label.text = "Matches: " + matches;
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.x = 10;
			label.y = 10;
			content.addChild(label);
			
			label = new TextField();
			label.text = "Wins: " + wins;
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.x = 10;
			label.y = 30;
			content.addChild(label);
			
			tf.align = TextFieldAutoSize.CENTER;
			
			//var offset:int = 54;
			var button:ButtonHex;
			if(!isFriend) {
				button = new ButtonHex("ADD FRIEND", onAddFriend, "button_small_gold", 12, -1, 110);
				button.x = 136 / 2 - button.width / 2;
				button.y = 54;
				content.addChild(button);
				
				//offset += button.height + 2;
			}
			else {
				label = new TextField();
				label.text = "Player is on your friendlist";
				label.setTextFormat(tf);
				label.mouseEnabled = false;
				label.width = 116;
				//label.x = 10;
				label.y = 56;
				label.wordWrap = true;
				label.multiline = true;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.x = 136 / 2 - label.width / 2;
				content.addChild(label);
			}
			
			if(!isBlacklisted) {
				button = new ButtonHex("BAN PLAYER", onBlacklist, "button_small_gray", 12, -1, 110);
				button.x = 136 / 2 - button.width / 2;
				button.y = 100;
				content.addChild(button);
			}
			else {
				label = new TextField();
				label.text = "Player is on your blacklist";
				label.setTextFormat(tf);
				label.mouseEnabled = false;
				label.width = 116;
				label.y = 100;
				label.wordWrap = true;
				label.multiline = true;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.x = 136 / 2 - label.width / 2;
				content.addChild(label);
			}
			
			//if(playerCell)
			//	playerCell.refreshBg();
		}
		
		private function onPlayerInfoReceived(message:Message):void {
			if(loading) {
				bg.removeChild(loading);
				loading = null;
			}
			
			matches = message.getInt(0);
			wins = message.getInt(1);
			
			fillPlayerInfo(message.getBoolean(2), message.getBoolean(3));
		}
		
		private function onAddFriendReceived(message:Message):void {
			if(loading) {
				bg.removeChild(loading);
				loading = null;
			}
			
			if(message.getBoolean(0)) {
				fillPlayerInfo(message.getBoolean(1), message.getBoolean(2));
			}
			else {
				ErrorManager.showCustomError2("Adding to friends failed, please try again later", "Error", 0);
			}
		}
		
		private function onAddToBlacklistReceived(message:Message):void {
			if(loading) {
				bg.removeChild(loading);
				loading = null;
			}
			
			if(message.getBoolean(0)) {
				fillPlayerInfo(message.getBoolean(1), message.getBoolean(2));
				var newEntry:Object = new Object();
				newEntry.a = message.getString(3);
				newEntry.b = message.getString(4);
				newEntry.c = message.getString(5);
				G.user.blackList.push(newEntry);
			}
			else {
				ErrorManager.showCustomError2("Adding to blacklist failed, please try again later", "Error", 0);
			}
		}
		
		private function onMouseClick(event:MouseEvent):void {
			if(event.stageX < bg.x || event.stageX > bg.x + bg.width || event.stageY < bg.y || event.stageY > bg.y + bg.height) {
				removePopup();
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			if(event.keyCode == Input.KEY_ESC) {
				removePopup();
			}
		}
		
		private function removePopup():void {
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_GET_PLAYER_INFO, onPlayerInfoReceived);
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_ADD_FRIEND, onAddFriendReceived);
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_ADD_TO_BLACKLIST, onAddToBlacklistReceived);
			removeEventListener(MouseEvent.CLICK, onMouseClick);
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			parent.removeChild(this);
		}
		
		private function onAddFriend():void {
			content.visible = false;
			
			loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			G.userConnection.send(MessageID.SOCIAL_ADD_FRIEND, playerKey);
		}
		
		private function onBlacklist():void {
			G.errorSprite.addChild(new BlacklistReasonPopup(onBlacklistConfirmed));
		}
		
		private function onBlacklistConfirmed(reason:String):void {
			content.visible = false;
			
			loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			G.userConnection.send(MessageID.SOCIAL_ADD_TO_BLACKLIST, playerKey, reason);
		}
	}
}