package Menu.Lobby
{
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Loading;
	import Menu.MainMenu.ScrollableSprite;
	import Menu.NinePatchSprite;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.flash_proxy;
	
	import mx.utils.StringUtil;
	
	import playerio.Connection;
	import playerio.DatabaseObject;
	
	public class LobbyChat extends Sprite
	{
		private var connection:Connection = null;
		private var chatWindowBottom:TextField;
		private var chatWindow:TextField;
		private var chatUsers:Array = new Array();
		
		private var chatList:ScrollableSprite;

		private var loading:Sprite;
		private var messageSend:String;
		
		private var nameToCheck:String;		// second par of name for guests (or number) or first word of user with space in name
		private var nameToCheckOrig:String; // original full lowercased name
		
		public function LobbyChat(messageSendID:String)
		{
			super();
			this.messageSend = messageSendID;
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 497, 351);
			addChild(bg);
			x = 3;
			y = 186;
			
			bg = new NinePatchSprite("9patch_emboss_panel", 307, 267);
			bg.x = 8;
			bg.y = 13;
			addChild(bg);
			
			bg = new NinePatchSprite("9patch_emboss_panel", 307, 46);
			bg.x = 8;
			bg.y = 292;
			addChild(bg);
			
			bg = new NinePatchSprite("9patch_emboss_panel", 144, 325);
			bg.x = 324;
			bg.y = 13;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 12, 0x858585, true);
			
			// TODO disable lobby chat until player actually connects to lobby room
			chatWindowBottom = new TextField();
			chatWindowBottom.defaultTextFormat = tf;
			chatWindowBottom.type = TextFieldType.INPUT;
			chatWindowBottom.x = 15;
			chatWindowBottom.y = 297;
			chatWindowBottom.width = 292;
			chatWindowBottom.height = 40;
			chatWindowBottom.multiline = true;
			chatWindowBottom.wordWrap = true;
			chatWindowBottom.maxChars = 140;
			chatWindowBottom.addEventListener(KeyboardEvent.KEY_DOWN, onChatKeyPress, false, 0, true);
			chatWindowBottom.addEventListener(KeyboardEvent.KEY_UP, onChatKeyUnpress, false, 0, true);
			addChild(chatWindowBottom);
			
			chatWindow = new TextField();
			chatWindow.x = 14;
			chatWindow.y = 21;
			chatWindow.width = 296;
			chatWindow.height = 254;
			chatWindow.wordWrap = true;
			chatWindow.multiline = true;
			addChild(chatWindow);
			
			chatList = new ScrollableSprite(159, 320);
			chatList.x = 328;
			chatList.y = 17;
			addChild(chatList);
			
			loading = new Sprite();
			loading.graphics.beginFill(0, 0.8);
			loading.graphics.drawRect(0, 0, width, height - 4);
			addChild(loading);
			
			var loader:Loading = new Loading("CONNECTING...", false);
			loader.x = width / 2 - loader.width / 2;
			loader.y = height / 2 - loader.height / 2;
			loading.addChild(loader);
			
			G.client.bigDB.load("ServerData", "ServerInfo", function(dbObject:DatabaseObject):void {
				if(dbObject != null) {
					if(dbObject.Version != G.gameVersion) {
						addMessage("System message", "There is updated version of game available, please refresh your browser", "#858585");
					}
				}
			});
			
			nameToCheckOrig= G.user.name.toLowerCase();
			nameToCheck = G.user.name.toLowerCase();
			if(nameToCheck.substr(0, 5) == "guest")
				nameToCheck = StringUtil.trim(nameToCheck.substr(5));
			nameToCheck = nameToCheck.split(" ")[0];
			//trace(nameToCheck);
		}
		
		public function setConnection(conn:Connection):void {
			connection = conn;
			
			if(loading) {
				removeChild(loading);
				loading = null;
			
				if(stage != null && stage.focus == null)
					stage.focus = chatWindowBottom;
			}
		}
		
		private function onChatKeyPress(event:KeyboardEvent):void {
			if(connection == null) return;
			
			if(event.keyCode == Input.KEY_ENTER && StringUtil.trim(chatWindowBottom.text).length > 0) {
				if(G.user.isGuest) {
					addMessage("Guests are not allowed to chat in the lobby, you can create account for free", "", "#858585");
				}
				else {
					connection.send(messageSend, chatWindowBottom.text);
					chatWindowBottom.text = "";
				}
			}
		}
		
		private function onChatKeyUnpress(event:KeyboardEvent):void {
			if(event.keyCode == Input.KEY_ENTER) {
				chatWindowBottom.text = "";
			}
		}

		private function sortChatUsers(a:LobbyChatPlayer, b:LobbyChatPlayer):int {
			if(a.username.substr(0, 5) == "Guest" && b.username.substr(0, 5) != "Guest") {
				return 1;
			}
			if(a.username.substr(0, 5) != "Guest" && b.username.substr(0, 5) == "Guest") {
				return -1;
			}
			if(a.isModerator && !b.isModerator) {
				return -1;
			}
			if(!a.isModerator && b.isModerator) {
				return 1;
			}
			if(a.isFriend && !b.isFriend) {
				return -1;
			}
			if(!a.isFriend && b.isFriend) {
				return 1;
			}
			if(a.isPremium && !b.isPremium) {
				return -1
			}
			if(!a.isPremium && b.isPremium) {
				return 1;
			}
			return a.username.toLowerCase() < b.username.toLowerCase() ? -1 : 1; 
			//return 0;
		} 
		
		public function addGameUser(id:int, name:String, level:int, isPremium:Boolean, isModerator:Boolean, playerKey:String, rating:int):void {
			// check blacklist
			for each(var blacklistObj:Object in G.user.blackList) {
				if(blacklistObj.a == playerKey) {
					addMessage("", "User " + name + " is in your personal blacklist, reason: \"" + blacklistObj.c + "\"", "#FFFFFF");
					break;
				}
			}
			
			addUser(id, name, level, isPremium, isModerator, playerKey, rating);
		}
		
		public function addUser(id:int, name:String, level:int, isPremium:Boolean, isModerator:Boolean, playerKey:String, rating:int):void {
			//trace(name + " is premium " + isPremium);
			// check if user with this id isn't already there
			for each(var u:LobbyChatPlayer in chatUsers) {
				if(u.ID == id) {
					return;
				}
			}
			
			var user:LobbyChatPlayer = new LobbyChatPlayer(name, level, isPremium, isModerator, id, playerKey, rating);
			chatUsers.push(user);

			for(var i:int = 0; i < chatUsers.length; ++i) {
				chatUsers[i].y = chatUsers[i].height * i;
			}

			chatList.addSprite(user);
			
			chatUsers.sort(sortChatUsers);
			
		}

		public function removeUser(id:int):void {
			var index:int = 0;
			var elementToRemove:int = 0;
			//var found:Boolean = false;
			for each(var user:LobbyChatPlayer in chatUsers) {
				if(user.ID == id) {
					chatList.removeItem(user);
					elementToRemove = index;
					//found = true;
					//continue;
					break;
				}
				index++;
			}
			chatUsers.splice(elementToRemove, 1);
		}
		
		public function addMessage(username:String, message:String, color:String = "#858585"):void {
			if(G.user.isPlayerMuted(username)) return;
			
			if(username != G.user.name) {
				message = SwearList.filter(message);
			}
			
			message = StringUtil.trim(message);

			var textColor:String = "#858585";
			if(message.toLowerCase().indexOf(nameToCheck) != -1 || message.toLowerCase().indexOf(nameToCheckOrig) != -1) {
				textColor = "#FFFFFF";
				G.sounds.playSound("chat_notif");
			}
			var r:RegExp = new RegExp("<", "gi");
			message = message.replace(r, "&lt;");
			r = new RegExp(">", "gi");
			message = message.replace(r, "&gt;");
			//username = username.replace("<", "&lt;").replace(">", "&gt;");
			chatWindow.htmlText += "<b><font face=\"Arial\" size=\"12\" color=\"" + color + "\">" + username + ((message.length > 0 && username.length > 0) ? " ~ " : "") + "</font>" + "<font face=\"Arial\" size=\"12\" color=\"" + textColor + "\">" + message + "</font></b><br />";
			chatWindow.scrollV = chatWindow.numLines;
		}
	}
}