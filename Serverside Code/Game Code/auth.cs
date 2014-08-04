using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;
using System.Security.Cryptography;
namespace Wargrounds
{
	public class AuthPlayer : BasePlayer
	{
	}

	[RoomType("Auth2.4")]
	public class MatchMaker : Game<AuthPlayer>
	{
		private string secret = "b715b6f1e50d89df61892bf3acb58707";
		// This method is called when an instance of your the game is created
		public override void GameStarted() {


		}

		public override void UserJoined(AuthPlayer player) {
			/*if(player.ConnectUserId.IndexOf("armor") == 0) { 
				
				player.Send("auth", Create(player.ConnectUserId, secret));

			}else player.Disconnect();*/
		}

		public override void AttemptGotMessage(BasePlayer player, Message message) {
			switch (message.Type) {
				case "auth": {

						string id = message.GetString(0);
						if (id.Substring(0, 5) == "armor") {
							player.Send("auth", Create(id, secret));
						}



						break;
					}
			}
		}

		public override bool AllowUserJoin(AuthPlayer player) {
			return base.AllowUserJoin(player);
		}

		public static string Create(string userId, string sharedSecret) {
			int unixTime = (int)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalSeconds;
			var hmac = new HMACSHA1(Encoding.UTF8.GetBytes(sharedSecret)).ComputeHash(Encoding.UTF8.GetBytes(unixTime + ":" + userId));
			return unixTime + ":" + toHexString(hmac);
		}

		private static string toHexString(byte[] bytes) {
			return BitConverter.ToString(bytes).Replace("-", "").ToLowerInvariant();
		}


	}
}
