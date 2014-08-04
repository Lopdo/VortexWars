package Game
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.LevelIcon;
	import Menu.Lobby.PlayerInfoPopup;
	import Menu.NinePatchSprite;
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setInterval;
	
	public class SidePanel extends Sprite
	{
		private var playerCells:Array = new Array();
		
		private var playerIndexes:Array;
		
		private var isWide:Boolean;
		
		private var logo:Bitmap;
		private var bg:NinePatchSprite;
		private var bgWide:NinePatchSprite;
		private var moveButton:Button;
		
		public function SidePanel()
		{
			super();
			
			var gameTypeBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 86, 31); 
			gameTypeBg.x = 161;
			gameTypeBg.y = 4;
			addChild(gameTypeBg);
			
			try {
				var so:SharedObject = SharedObject.getLocal("prefs");
				if(!so.data.hasOwnProperty("sidePanelWide")) {
					so.data.sidePanelWide = 1;
				}
				so.flush();
			}
			catch(err:Error) {
				
			}
			
			isWide = so.data.sidePanelWide == 1;
			
			logo = ResList.GetArtResource("logo_gray");
			logo.x = 21;
			logo.y = 534;
			addChild(logo);
			logo.visible = isWide;

			bg = new NinePatchSprite("9patch_transparent_panel", 127, 478);
			bg.x = 118;
			bg.y = 41;
			addChild(bg);
			bg.visible = !isWide;
			
			bgWide = new NinePatchSprite("9patch_transparent_panel", 232, 478);
			bgWide.x = 13;
			bgWide.y = 41;
			addChild(bgWide);
			bgWide.visible = isWide;
			
			moveButton = new Button(null, onShowHide, ResList.GetArtResource("button_side_hide"));
			moveButton.x = 9;
			moveButton.y = 14;
			addChild(moveButton);
			
			if(!isWide) {
				moveButton.x = 40 + 115;
				moveButton.scaleX = -1;
			}
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			Game(parent).setWidePanel(isWide);
		}
		
		public function setGameType(gameType:int, fightType:int):void {
			var gameTypeB:Bitmap;
			switch(gameType) {
				case 0: gameTypeB = ResList.GetArtResource("lobby_gameDistType_random"); break;
				case 1: gameTypeB = ResList.GetArtResource("lobby_gameDistType_manual"); break;
				case 2: gameTypeB = ResList.GetArtResource("lobby_gameDistType_border"); break;
			}
			gameTypeB.x = 167;
			gameTypeB.y = 9;
			addChild(gameTypeB);
			
			var ftTF:TextFormat = new TextFormat("Arial", 12, -1);
			
			var fightTypeLabel:TextField = new TextField();
			switch(fightType) {
				case 0: fightTypeLabel.text = "HC"; break;
				case 1: fightTypeLabel.text = "Att"; break;
				case 2: fightTypeLabel.text = "1v1"; break;
				case 3: fightTypeLabel.text = "1v1q"; break;
			}
			fightTypeLabel.setTextFormat(ftTF);
			fightTypeLabel.x = 206;
			fightTypeLabel.width = 38;
			fightTypeLabel.autoSize = TextFieldAutoSize.CENTER;
			fightTypeLabel.y = 6 + 27/2 - fightTypeLabel.height / 2;
			fightTypeLabel.mouseEnabled = false;
			addChild(fightTypeLabel);
			
			//upgradesEnabled = upgrades;
		}
		
		private function onShowHide(button:Button):void {
			isWide = !isWide;
			var so:SharedObject = SharedObject.getLocal("prefs");
			so.data.sidePanelWide = isWide ? 1 : 0;
			so.flush();
			
			bgWide.visible = isWide;
			bg.visible = !isWide;
			logo.visible = isWide;
			
			if(!isWide) {
				moveButton.x = 40 + 115;
				moveButton.scaleX = -1;
			}
			else {
				moveButton.x = 9;
				moveButton.scaleX = 1;
			}
			
			for each(var cell:SidePanelCell in playerCells) {
				cell.setWide(isWide);
			}
			
			Game(parent).setWidePanel(isWide);
		}
		
		public function AddPlayers(players:Array):void {
			var i:int = 0;
			var offsetX:int = 14;
			var offsetY:int = 0;
			
			var tmpPlayers:Array = new Array();
			for each(var player:Player in players) {
				tmpPlayers.push(player);
			}
			tmpPlayers.sortOn(["colorID"], Array.NUMERIC);
			players = tmpPlayers;
			
			playerIndexes = new Array();
			for each(player in players) {
				offsetY = 7 + 63 * i;
				playerIndexes[player.ID] = i;
				
				playerCells[i] = new SidePanelCell(player, isWide, (Game)(parent));
				playerCells[i].y = i * 58;
				addChild(playerCells[i]);
				
				++i;
			}
		}
		
		public function setActivePlayer(p:int):void {
			for(var i:int = 0; i < playerCells.length; ++i) {
				var cell:SidePanelCell = playerCells[i];
				cell.setActive(i == playerIndexes[p]);
			}
		}
		
		public function setAttackBoostActive(p:int, active:Boolean):void {
			if(playerCells[playerIndexes[p]])
				playerCells[playerIndexes[p]].setAttackBoostActive(active);
		}
		
		public function setDefenseBoostActive(p:int, active:Boolean):void {
			if(playerCells[playerIndexes[p]])
				playerCells[playerIndexes[p]].setDefenseBoostActive(active);
		}
		
		public function setAttackBoostsCount(p:int, count:int, freeCount:int):void {
			if(playerCells[playerIndexes[p]])
				playerCells[playerIndexes[p]].setAttackBoostsCount(count, freeCount);
		}
		
		public function setDefenseBoostsCount(p:int, count:int, freeCount:int):void {
			if(playerCells[playerIndexes[p]])
				playerCells[playerIndexes[p]].setDefenseBoostsCount(count, freeCount);
		}
		
		public function setRegionSize(p:int, str:int):void {
			if(playerCells[playerIndexes[p]])
				playerCells[playerIndexes[p]].setRegionSize(str);
		}
		
		public function setArmySize(p:int, army:int):void {
			if(playerCells[playerIndexes[p]])
				playerCells[playerIndexes[p]].setArmySize(army);
		}
		
		public function setOfferedDraw(index:int, offered:Boolean):void {
			if(playerCells[playerIndexes[index]])
				playerCells[playerIndexes[index]].setOfferedDraw(offered);
		}
		
		public function removePlayer(index:int):void {
			if(playerCells[playerIndexes[index]])
				playerCells[playerIndexes[index]].removePlayer();
		}
		
		public function setBoostsVisible(v:Boolean):void {
			for each(var cell:SidePanelCell in playerCells) {
				cell.setBoostsVisible(v);
			}
		}
		
		public function removeToggleWideButton():void {
			removeChild(moveButton);
		}
	}
}