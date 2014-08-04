package 
{
	public class MessageID
	{
		public static const PLAYER_JOINED:String = "a";
		public static const POST_LOGIN_INFO:String = "b";
		public static const GAME_START:String = "c";
		public static const PLAYER_LEFT:String = "d";
		public static const MESSAGE_RECEIVED:String = "e";
		public static const MESSAGE_SEND:String = "f";
		public static const PLAYER_READY:String = "g";
		public static const PLAYER_SET_HOST:String = "h";
		public static const SET_PLAYER_ACTIVE:String = "i";
		public static const GAME_END_TURN:String = "j";
		public static const GAME_POST_TURN_UPDATE:String = "k";
		public static const GAME_ATTACK:String = "l";
		public static const GAME_ATTACK_RESULT:String = "m";
		public static const LOBBY_MESSAGE_SEND:String = "n";
		public static const LOBBY_PLAYER_JOINED:String = "o";
		public static const LOBBY_PLAYER_LEFT:String = "p";
		public static const LOBBY_POST_JOIN:String = "q";
		public static const GAME_PLAYER_DEAD:String = "r";
		public static const GAME_OVER:String = "s";
		public static const GAME_OVER_ALL:String = "t";
		public static const GAME_JOIN_FAIL_GAME_STARTED:String = "u";
		public static const GAME_JOIN_FAIL_GAME_FULL:String = "v";
		public static const REMOTE_LOGIN:String = "w";
		public static const PLAYER_INITIALIZED:String = "x";
		public static const KICK_PLAYER:String = "y";
		public static const PLAYER_KICKED:String = "z";
		public static const GAME_REGION_CONQUERED:String = "A";
		public static const GAME_FIRST_CONQUER_REGION:String = "B";
		public static const GAME_FIRST_REGION_CONQUERED:String = "C";
		public static const PLAYER_SET_ID:String = "D";
		public static const ITEM_BUY:String = "E";
		public static const ITEM_BOUGHT:String = "F";
		public static const ITEM_BUY_FAILED:String = "G";
		public static const GAME_SURRENDER:String = "H";
		public static const GAME_PLAYER_SURRENDERED:String = "I";
		public static const GAME_IDLE_WARNING:String = "J";
		public static const GAME_IDLE_KICK:String = "K";
		public static const GAME_PLAYER_KICKED:String = "L";
		public static const USER_SET_RACE:String = "M";
		public static const USER_SET_USERNAME:String = "N";
		public static const USER_USERNAME_SET:String = "O";
		public static const GAME_TUTORIAL_FINISHED:String = "P";
		public static const PLAYER_BANNED:String = "Q";
		public static const LOBBY_TOO_MANY_MESSAGES:String = "R";
		
		// params:
		// 0:String - map name
		// 1:String - map id ("" if it is new map)
		// 2:int - map width
		// 3:int - map height
		// 4:byte array - map data 
		public static const MAP_EDITOR_SAVE:String = "S";
		// params
		// 0:String - map ID
		public static const MAP_EDITOR_SAVE_SUCCESSFUL:String = "T";
		// params
		// 0:String - error message
		public static const MAP_EDITOR_SAVE_FAILED:String = "U";
		// params
		// 0:String - map ID
		public static const MAP_EDITOR_LOAD:String = "V";
		// params
		// 0:String - map name
		// 1:int - map width
		// 2:int - map height
		// 3:byte array - map data
		// 4:String - map ID
		public static const MAP_EDITOR_LOAD_RESULT:String = "W";
		// params
		// 0:String - error message
		public static const MAP_EDITOR_LOAD_FAILED:String = "X";
		
		public static const GAME_START_MANUAL_DISTRIBUTION:String = "Y";
		public static const GAME_END_MANUAL_DISTRIBUTION:String = "Z";
		public static const GAME_DISTRIBUTION_RESULTS:String = "aa";
		public static const GAME_POST_DISTRIBUTION_UPDATE:String = "ab";
		public static const GAME_RACE_CHANGED:String = "ac";
		public static const GAME_DUMP_MAP:String = "ad";
		public static const LOBBY_START_COUNTDOWN:String = "ae";
		
		public static const GAME_ENABLE_TIE:String = "af";
		public static const GAME_TIE_OFFERED:String = "ag";
		public static const GAME_TIE_ANSWER:String = "ah";
		public static const GAME_TIE_TIMEOUT:String = "ai";
		public static const GAME_TIE_INPROGRESS:String = "aj";
		public static const LOBBY_KICKED:String = "ak";
		public static const USER_SET_HIDE_PREMIUM:String = "al";
		public static const ACHIEVEMENT_UNLOCKED:String = "am";
		public static const ACHIEVEMENT_HOWTOPLAY_VISITED:String = "an";
		public static const USER_SET_BG:String = "ao";
		public static const USER_GET_LOGIN_REWARD:String = "ap";
		public static const GAME_BOOST_ATTACK_ACTIVATE:String = "aq";
		public static const GAME_BOOST_DEFENSE:String = "ar";
		
		public static const FB_INVITES_REWARD:String = "at";
		
		public static const MAP_EDITOR_NEW_MAP:String = "au";
		public static const MAP_EDITOR_NEW_MAP_RESULT:String = "av";
		public static const MAP_EDITOR_DELETE_MAP:String = "aw";
		public static const MAP_EDITOR_DELETE_MAP_RESULT:String = "ax";
		public static const MAP_EDITOR_SUBMIT_MAP:String = "ay";
		public static const MAP_EDITOR_SUBMIT_MAP_RESULT:String = "az";
		
		public static const LOBBY_MAP_RATED:String = "aA";
		
		public static const MAP_EDITOR_DENY_MAP:String = "aB";
		public static const MAP_EDITOR_DENY_MAP_RESULT:String = "aC";
		public static const MAP_EDITOR_ALLOW_MAP:String = "aD";
		public static const MAP_EDITOR_ALLOW_MAP_RESULT:String = "aE";
		
		public static const MOD_COMMAND_FAILED:String = "aF";
		public static const MOD_COMMAND_SUCCESS:String = "aG";
		public static const LOBBY_PLAYER_KICKED:String = "aH";
		
		public static const SPECTATOR_INGAME_JOIN:String = "aI";
		public static const GAME_KICKED:String = "aJ";
		public static const GAME_PLAYER_MOD_KICKED:String = "aK";
		public static const GAME_JOIN_FAIL_RECENTLY_KICKED:String = "aL";
		
		public static const PLAYSMART_ERROR:String = "aM";
		
		public static const SOCIAL_GET_FRIENDLIST:String = "aN";
		public static const SOCIAL_GET_PLAYER_INFO:String = "aO";
		public static const SOCIAL_ADD_FRIEND:String = "aP";
		public static const SOCIAL_ADD_TO_BLACKLIST:String = "aQ";
		public static const SOCIAL_REMOVE_FROM_BLACKLIST:String = "aR";
		public static const SOCIAL_REMOVE_FROM_FRIENDLIST:String = "aS";
		public static const SOCIAL_GET_PLAYER_PROFILE:String = "aT";
		public static const USER_SET_PUBLIC_PROFILE:String = "aU";
		
		public static const MAP_EDITOR_SUBMIT_MAP_NEW:String = "aV";
		public static const REPORT_MAP:String = "aW";
		public static const MAP_EDITOR_BAN:String = "aX";
	}
}