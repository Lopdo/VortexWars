package
{
	import Errors.ErrorManager;
	
	import Menu.DailyRewardScreen;
	import Menu.FBInviteRewardScreen;
	import Menu.Login.LoginFacebook;
	import Menu.Login.LoginPlaySmart;
	import Menu.Login.LoginScreen;
	import Menu.Login.LoginScreenAG;
	import Menu.Login.LoginScreenKong;
	
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIOError;
	
	public class G
	{
		public static const colors:Array = new Array(0xC70000, 0x4353FF, 0xC9C700, 0x019327, 0xB4065D, 0xFF7F00, 0x009597, 0x934200);
		public static const borderColors:Array = new Array(0xFFE3C3C, 0x5080FF, 0xFFFC17, 0x00ff42, 0xF660AB, 0xFFA200, 0x00FCFF, 0xA9651C);
		public static const nameColors:Array = new Array(0xFFE3C3C, 0x4353FF, 0xFFFC17, 0x019327, 0xF660AB, 0xFF7F00, 0x00FCFF, 0xA9651C);
		public static const htmlColors:Array = new Array("#FF0000", "#0d1563", "#FFFC17", "#00ff42", "#F660AB", "#FF6700", "#00FCFF", "#A9651C");
		public static var client:Client;
		public static var userConnection:Connection;
		public static var connection:Connection;
		public static var user:User;
		public static var gameSprite:Sprite;
		public static var tooltipSprite:Sprite;
		public static var errorSprite:Sprite;
		public static var sounds:SoundManager;
		public static const gameID:String = "wargrounds-pvrpqmt1ee2jwqueof8ig";
		//beta
		//public static const gameID:String = "vortexwarsbeta-r9avn9xzek2cs5j5j1dqha";
		public static const gameVersion:String = "2.4";
		public static var invitedTo:String = null;
		public static var host:String = null;
		//public static var showTutorial:Boolean = true;
		public static var gatracker:AnalyticsTracker;
		
		public static const HOST_ARMORGAMES:String = "armorgames";
		public static const HOST_KONGREGATE:String = "kongregate";
		public static const HOST_VW:String = "";
		public static const HOST_FACEBOOK:String = "facebook";
		public static const HOST_PLAYSMART:String = "playsmart";
		
		public static var kongregate:*;
		// armorgames AGI reference
		public static var agi:Object;
		
		// debug stuff
		public static var localServer:Boolean = false;
		public static var lagsEnabled:Boolean = false;
		public static var roomID:String = "-1";
		
		public static var loaderParams:Object;
		
		public static function loginRewardReceived(message:Message):void {
			errorSprite.addChild(new DailyRewardScreen(message.getInt(0), message.getInt(1)));
		}
		
		public static function fbInviteRewardReceived(message:Message):void {
			errorSprite.addChild(new FBInviteRewardScreen(message.getInt(0)));
		}
		
		public static function setUserConnection(con:Connection):void {
			G.userConnection = con;
			G.userConnection.addDisconnectHandler(onUserConnectionDisconnect);
		}
		
		private static function onUserConnectionDisconnect():void {
			G.client.multiplayer.createJoinRoom(
				G.user.name,						//Room id. If set to null a random roomid is used
				"UserRoom" + G.gameVersion,			//The game type started on the server
				false,								//Should the room be visible in the lobby?
				null,					//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{Name:G.user.name},									//User join data
				handleUserRoomJoin,					//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		private static function handleUserRoomJoin(connection:Connection):void {
			G.setUserConnection(connection);
			//G.userConnection = connection;
			connection.addMessageHandler(MessageID.REMOTE_LOGIN, G.remoteLogin);
			connection.addMessageHandler(MessageID.PLAYER_BANNED, G.banned);
			connection.addMessageHandler(MessageID.USER_GET_LOGIN_REWARD, G.loginRewardReceived);
			connection.addMessageHandler(MessageID.ACHIEVEMENT_UNLOCKED, G.user.achievementUnlocked);
		}
		
		private static function handleError(error:PlayerIOError):void {
			
		}
		
		public static function disconnect():void {
			G.user.reset();
			
			if(G.connection != null) {
				G.connection.removeMessageHandler(MessageID.REMOTE_LOGIN, G.remoteLogin);
				G.connection.removeMessageHandler(MessageID.PLAYER_BANNED, G.banned);
				G.connection.removeMessageHandler(MessageID.USER_GET_LOGIN_REWARD, G.loginRewardReceived);
				G.connection.disconnect();
				G.connection = null;
			}
			
			if(G.userConnection != null) {
				G.userConnection.removeDisconnectHandler(onUserConnectionDisconnect);
				G.userConnection.disconnect();
				G.userConnection = null;
			}

			/*if(G.userConnection != null) {
				G.userConnection.disconnect();
				G.userConnection = null;
			}*/
		}
		
		public static function remoteLogin(message:Message):void {
			gameSprite.removeChildAt(0);
			gameSprite.addChild(G.getLoginScreen());
			
			disconnect();
			
			ErrorManager.showCustomError("Your account has been used on different computer, you have been signed out", ErrorManager.ERROR_REMOTE_LOGIN, null);
		}
		
		public static function banned(message:Message):void {
			trace("banned");
			gameSprite.removeChildAt(0);
			gameSprite.addChild(G.getLoginScreen());
			
			disconnect();
			
			ErrorManager.showCustomError("Your account has been banned for following reason: " + message.getString(0) + (message.getInt(1) == -1 ? "\n\nYour have been banned forever" : "\n\nYour ban will expire in: " + message.getInt(1) + " days") , ErrorManager.ERROR_REMOTE_LOGIN, null);
		}
		
		public static function kicked(reason:String):void {
			gameSprite.removeChildAt(0);
			gameSprite.addChild(G.getLoginScreen());
			
			disconnect();
			
			ErrorManager.showCustomError("You have been kicked for following reason: " + reason, ErrorManager.ERROR_REMOTE_LOGIN, null);
		}
		
		public static function getMapName(group:int, index:int):String {
			switch(group) {
				case 0:
				{
					switch(index) {
						case 0: return "World"; break;
						case 1: return "Europe"; break;
						case 2: return "USA"; break;
						case 3: return "Africa"; break;
					}
				}
					break;
				case 1:
				{
					switch(index) {
						case 0: return "Symetry 2"; break;
						case 1: return "Symetry 4"; break;
						case 2: return "Symetry 6"; break;
						case 3: return "Symetry 8"; break;
					}
				}
					break;
				case 2:
				{
					switch(index) {
						case 0: return "Angels"; break;
						case 1: return "Devils"; break;
						case 2: return "Insectoids"; break;
						case 3: return "Arachnids"; break;
					}
				}
					break;
				case 3:
				{
					switch(index) {
						case 0: return "Pumpkin"; break;
						case 1: return "Grave"; break;
						case 2: return "Ghost"; break;
						case 3: return "Bat"; break;
					}
				}
					break;
				case 99:
				{
					switch(index) {
						case 0: return "Vortex"; break;
						case 1: return "Cells"; break;
						case 2: return "Comedian"; break;
						case 3: return "Slovakia"; break;
						case 4: return "Burger"; break;
						case 5: return "Cubes"; break;
						case 6: return "Swirl"; break;
						case 7: return "Hourglass"; break;
						case 8: return "Islands"; break;
						case 9: return "Triangles"; break;
					}
				}
					break;
			}
			return "Unknown map";
		}
		
		public static function getLoginScreen():Sprite {
			if(G.host == G.HOST_KONGREGATE) {
				return new LoginScreenKong();
			}
			else if(G.host == G.HOST_ARMORGAMES) {
				return new LoginScreenAG();
			}
			else if(G.host == G.HOST_FACEBOOK) {
				return new LoginFacebook();
			}
			else if(G.host == G.HOST_PLAYSMART) {
				return new LoginPlaySmart();
			}
			else {
				return new LoginScreen();
			}
		}
	}
}