package Menu.Social
{
	import Errors.ErrorManager;
	
	import Menu.GameRoom.GameRoom;
	import Menu.Loading;
	import Menu.Lobby.Lobby;
	import Menu.MainMenu.ScrollableSprite;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	
	public class SocialFriendList extends Sprite
	{
		private var friendListPanel:ScrollableSprite;
		private var loading:Loading;
		private var roomId:String;
		private var socialScreen:SocialScreen;
		
		public function SocialFriendList(socialScreen:SocialScreen)
		{
			super();
			
			this.socialScreen = socialScreen;
			
			friendListPanel = new ScrollableSprite(420, 464);
			addChild(friendListPanel);
			
			loading = new Loading("LOADING...", false);
			loading.x = 420 / 2 - loading.width / 2;
			loading.y = 464 / 2 - loading.height / 2;
			addChild(loading);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			G.userConnection.addMessageHandler(MessageID.SOCIAL_GET_FRIENDLIST, onMessageReceived);
			G.userConnection.send(MessageID.SOCIAL_GET_FRIENDLIST);
			
			G.gatracker.trackPageview("/social/friendlist");
		}
		
		private function onRemovedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_GET_FRIENDLIST, onMessageReceived);
		}
		
		private function onMessageReceived(message:Message):void {
			if(message.type == MessageID.SOCIAL_GET_FRIENDLIST || message.type == MessageID.SOCIAL_REMOVE_FROM_FRIENDLIST) {
				friendListPanel.removeAllItems();
				
				var count:int = message.getInt(0);
				var index:int = 1;
				var offset:int = 4;
				var cells:Array = new Array();
				for(var i:int = 0; i < count; i++) {
					var cell:FriendlistPlayerCell = new FriendlistPlayerCell(message.getString(index++), message.getString(index++), message.getInt(index++), message.getNumber(index++), message.getInt(index++), message.getInt(index++), message.getString(index++), message.getString(index++), this);
					/*cell.y = offset;
					friendListPanel.addSprite(cell);
					offset += (cell.height + 4);*/
					cells.push(cell);
				}
				
				cells.sortOn(["onlineStatus", "lastOnline"], Array.DESCENDING); 
				for(i = 0; i < cells.length; i++) {
					cell = cells[i];
					cell.y = offset;
					friendListPanel.addSprite(cell);
					offset += (cell.height + 4);
				}
				
				if(loading) {
					removeChild(loading);
					loading = null;
				}
			}
		}
		
		public function showDetails(playerKey:String, playerName:String):void {
			socialScreen.showUserDetails(playerKey, playerName);
		}
		
		public function removeFriend(playerKey:String):void {
			G.userConnection.send(MessageID.SOCIAL_REMOVE_FROM_FRIENDLIST, playerKey);
			
			loading = new Loading("LOADING...", false);
			loading.x = 420 / 2 - loading.width / 2;
			loading.y = 464 / 2 - loading.height / 2;
			addChild(loading);
		}
		
		public function joinRoom(onlineStatus:int, roomId:String):void {
			if(onlineStatus == 2) {
				//join lobby
				socialScreen.rootSprite.parent.addChild(new Lobby(roomId));
				socialScreen.rootSprite.parent.removeChild(parent.parent.parent.parent.parent);
			}
			else if(onlineStatus == 3) {
				// join game
				loading = new Loading("LOADING...", false);
				loading.x = 420 / 2 - loading.width / 2;
				loading.y = 464 / 2 - loading.height / 2;
				addChild(loading);
				
				this.roomId = roomId;
				
				G.client.multiplayer.listRooms(
					"Wargrounds" + G.gameVersion,				//Type of room
					{Id:roomId},							// filter
					1,							// Limit to 20 results
					0,							// Start at the first room
					handleRoomList,
					handleError
				);
			}
		}
		
		private function handleRoomList(rooms:Array):void {
			if(rooms.length > 0) {
				var ri:RoomInfo = rooms[0];
				if(ri.data.Started) {
					G.client.multiplayer.joinRoom(roomId, { Guest:G.user.isGuest, Name:G.user.name, Spectator:true }, handleJoin, handleError);
				}
				else {
					G.client.multiplayer.joinRoom(roomId, { Guest:G.user.isGuest, Name:G.user.name, Spectator:false }, handleJoin, handleError);
				}
			}
		}
		
		private function handleJoin(connection:Connection):void{
			trace("Sucessfully connected to the multiplayer server");
			
			if(loading) {
				removeChild(loading);
				loading = null;
			}
			
			var g:GameRoom = new GameRoom(connection, roomId);
			//Listen to all messages using a private function
			G.connection = connection;
			
			socialScreen.rootSprite.parent.addChild(g);
			socialScreen.rootSprite.parent.removeChild(parent.parent.parent.parent.parent);
		}
		
		private function handleError(error:PlayerIOError):void {
			trace("handle error");
			if(loading) {
				removeChild(loading);
				loading = null;
			}
			
			if(error.type == PlayerIOError.NoServersAvailable) {
				ErrorManager.showCustomError("No servers found. Please try again later", error.errorID);
				//leave();
			}
			else if(error.type == PlayerIOError.UnknownRoom) {
				ErrorManager.showCustomError("There is no room with given name", error.errorID);
			}
			else if(error.type == PlayerIOError.RoomIsFull) {
				ErrorManager.showCustomError("This game is already at its maximum capacity.", error.errorID);
			}
			else {
				ErrorManager.showPIOError(error);
				trace(error.errorID + " " + error)
			}
		}
	}
}