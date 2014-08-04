package Menu.MainMenu
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Lobby.Lobby;
	import Menu.Login.LoginScreen;
	import Menu.Login.LoginScreenKong;
	import Menu.MutePanel;
	import Menu.Social.SocialScreen;
	
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.getClassByAlias;
	import flash.net.navigateToURL;
	import flash.utils.getQualifiedClassName;
	
	public class MenuShortcutsPanel extends Sprite
	{
		public function MenuShortcutsPanel(backCallback:Function)
		{
			super();
			
			var bgSprite:Sprite = new Sprite();
			bgSprite.addChild(ResList.GetArtResource("menu_shortcutPanel_bg"));
			bgSprite.x = 148;
			addChild(bgSprite);
			
			y = 560;
			
			var button:Button = new Button(null, onLBPressed, null, 14, -1, 152, 31);
			button.x = 151;
			button.y = 2;
			addChild(button);
			
			button = new Button(null, onSocialPressed, null, 14, -1, 97, 31);
			button.x = 303;
			button.y = 2;
			addChild(button);
			
			button = new Button(null, onForumPressed, null, 14, -1, 85, 31);
			button.x = 401;
			button.y = 2;
			addChild(button);
			
			button = new Button(null, onSignoutPressed, null, 14, -1, 103, 31);
			button.x = 487;
			button.y = 2;
			addChild(button);
			
			if(backCallback != null) {
				var buttonHex:ButtonHex = new ButtonHex("BACK", backCallback, "button_small_gray");
				buttonHex.x = 44;
				buttonHex.y = -2
				addChild(buttonHex);
			}
			
			var mute:MutePanel = new MutePanel(false);
			addChild(mute);
			mute.x = 608;
		}
		
		private function onLBPressed(button:Button):void {
			parent.addChild(new LeaderboardsScreen());
		}
		
		private function onSocialPressed(button:Button):void {
			if(G.user.isGuest) {
				ErrorManager.showCustomError("You need to log in to be able to access social features", 0);
				return;
			}
			
			parent.addChild(new SocialScreen(parent));
		}
				
		private function onCreditsPressed(button:Button):void {
			parent.addChild(new CreditsScreen());
		}
		
		private function onForumPressed(button:Button):void {
			navigateToURL(new URLRequest("http://vortexwars.com/forum"),"_blank");
		}
		
		private function onSignoutPressed(button:Button):void {
			if(G.connection) {
				G.connection.removeMessageHandler("*", G.remoteLogin);
				G.connection.disconnect();
				G.connection = null;
			}
			if(G.userConnection) {
				G.userConnection.disconnect();
				G.userConnection = null;
			}
			
			G.user.reset();
			
			parent.parent.addChild(G.getLoginScreen());
			parent.parent.removeChild(parent);
		}
	}
}