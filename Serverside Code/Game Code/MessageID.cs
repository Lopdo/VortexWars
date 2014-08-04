using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds {
    class MessageID
    {
        public const String PLAYER_JOINED = "a";
        public const String POST_LOGIN_INFO = "b";
        public const String GAME_START = "c";
        public const String PLAYER_LEFT = "d";
		public const String MESSAGE_RECEIVED = "e";
		public const String MESSAGE_SEND = "f";
		public const String PLAYER_READY = "g";
		public const String PLAYER_SET_HOST = "h";
		public const String SET_PLAYER_ACTIVE = "i";
		public const String GAME_END_TURN = "j";
		public const String GAME_POST_TURN_UPDATE = "k";
		public const String GAME_ATTACK = "l";
		public const String GAME_ATTACK_RESULT = "m";
		public const String LOBBY_MESSAGE_SEND = "n";
		public const String LOBBY_PLAYER_JOINED = "o";
		public const String LOBBY_PLAYER_LEFT = "p";
		public const String LOBBY_POST_JOIN = "q";
		public const String GAME_PLAYER_DEAD = "r";
		public const String GAME_OVER = "s";
		public const String GAME_OVER_ALL = "t";
		public const String GAME_JOIN_FAIL_GAME_STARTED = "u";
		public const String GAME_JOIN_FAIL_GAME_FULL = "v";
		public const String REMOTE_LOGIN = "w";
		public const String PLAYER_INITIALIZED = "x";
		public const String KICK_PLAYER = "y";
		public const String PLAYER_KICKED = "z";
		public const String GAME_REGION_CONQUERED = "A";
		public const String GAME_FIRST_CONQUER_REGION = "B";
		public const String GAME_FIRST_REGION_CONQUERED = "C";
		public const String PLAYER_SET_ID = "D";
		public const String ITEM_BUY = "E";
		public const String ITEM_BOUGHT = "F";
		public const String ITEM_BUY_FAILED = "G";
		public const String GAME_SURRENDER = "H";
		public const String GAME_PLAYER_SURRENDERED = "I";
		public const String GAME_IDLE_WARNING = "J";
		public const String GAME_IDLE_KICK = "K";
		public const String GAME_PLAYER_KICKED = "L";
		public const String USER_SET_RACE = "M";
		public const String USER_SET_USERNAME = "N";
		public const String USER_USERNAME_SET = "O";
		public const String GAME_TUTORIAL_FINISHED = "P";
		public const String PLAYER_BANNED = "Q";
		public const String LOBBY_TOO_MANY_MESSAGES = "R";

		public const String MAP_EDITOR_SAVE = "S";
		public const String MAP_EDITOR_SAVE_SUCCESSFUL = "T";
		public const String MAP_EDITOR_SAVE_FAILED = "U";
		public const String MAP_EDITOR_LOAD = "V";
		public const String MAP_EDITOR_LOAD_RESULT = "W";
        public const String MAP_EDITOR_LOAD_FAILED = "X";

		public const String GAME_START_MANUAL_DISTRIBUTION = "Y";
		public const String GAME_END_MANUAL_DISTRIBUTION = "Z";
		public const String GAME_DISTRIBUTION_RESULTS = "aa";
		public const String GAME_POST_DISTRIBUTION_UPDATE = "ab";
		public const String GAME_RACE_CHANGED = "ac";
		public const String GAME_DUMP_MAP = "ad";
		public const String LOBBY_START_COUNTDOWN = "ae";
		public const String GAME_ENABLE_TIE = "af";
		public const String GAME_TIE_OFFERED = "ag";
		public const String GAME_TIE_ANSWER = "ah";
		public const String GAME_TIE_TIMEOUT = "ai";
		public const String GAME_TIE_INPROGRESS = "aj";
		public const String LOBBY_KICKED = "ak";
		public const String USER_SET_HIDE_PREMIUM = "al";
		public const String ACHIEVEMENT_UNLOCKED = "am";
		public const String ACHIEVEMENT_HOWTOPLAY_VISITED = "an";
		public const String USER_SET_BG = "ao";
		public const String USER_GET_LOGIN_REWARD = "ap";

		public const String GAME_BOOST_ATTACK_ACTIVATE = "aq";
		public const String GAME_BOOST_DEFENSE = "ar";

		public const String FB_INVITED_USERS = "as";
		public const String FB_INVITES_REWARD = "at";

		public const String MAP_EDITOR_NEW_MAP = "au";
		public const String MAP_EDITOR_NEW_MAP_RESULT = "av";
		public const String MAP_EDITOR_DELETE_MAP = "aw";
		public const String MAP_EDITOR_DELETE_MAP_RESULT = "ax";
		public const String MAP_EDITOR_SUBMIT_MAP = "ay";
		public const String MAP_EDITOR_SUBMIT_MAP_RESULT = "az";

		public const String LOBBY_MAP_RATED = "aA";

		public const String MAP_EDITOR_DENY_MAP = "aB";
		public const String MAP_EDITOR_DENY_MAP_RESULT = "aC";
		public const String MAP_EDITOR_ALLOW_MAP = "aD";
		public const String MAP_EDITOR_ALLOW_MAP_RESULT = "aE";

		public const String MOD_COMMAND_FAILED = "aF";
		public const String MOD_COMMAND_SUCCESS = "aG";
		public const String LOBBY_PLAYER_KICKED = "aH";
		public const String SPECTATOR_INGAME_JOIN = "aI";
		public const String GAME_KICKED = "aJ";
		public const String GAME_PLAYER_MOD_KICKED = "aK";
		public const String GAME_JOIN_FAIL_RECENTLY_KICKED = "aL";

		public const String PLAYSMART_ERROR = "aM";

		public const String SOCIAL_GET_FRIENDLIST = "aN";
		public const String SOCIAL_GET_PLAYER_INFO = "aO";
		public const String SOCIAL_ADD_FRIEND = "aP";
		public const String SOCIAL_ADD_TO_BLACKLIST = "aQ";
		public const String SOCIAL_REMOVE_FROM_BLACKLIST = "aR";
		public const String SOCIAL_REMOVE_FROM_FRIENDLIST = "aS";
		public const String SOCIAL_GET_PLAYER_PROFILE = "aT";
		public const String USER_SET_PUBLIC_PROFILE = "aU";

		public const String MAP_EDITOR_SUBMIT_MAP_NEW = "aV";
		public const String REPORT_MAP = "aW";
		public const String MAP_EDITOR_BAN = "aX";
    }
}
