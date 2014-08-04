package Menu.PlayerProfile
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class AchievementsPanel extends Sprite
	{
		private var bg:Sprite;
		
		private var loading:Loading;
		private var profileDataReady:Boolean = false;
		
		private var achievements:Array = null;
		private var currentAchievementIndex:int = 0;
		
		private var achievImage:Sprite;
		private var achievName:TextField;
		private var achievDesc:TextField;
		private var xpReward:TextField;
		private var shardReward:TextField;
		private var shardIcon:Sprite;
		
		public function AchievementsPanel()
		{
			super();
			
			x = 405;
			y = 19;
			
			bg = new NinePatchSprite("9patch_transparent_panel", 370, 218);
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 20, -1, true);
			
			var label:TextField = new TextField();
			label.text = "ACHIEVEMENTS";
			label.setTextFormat(tf);
			label.width = width;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 8;
			label.mouseEnabled = false;
			addChild(label);
			
			loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			achievImage = new Sprite();
			achievImage.x = bg.width / 2 - 80;
			achievImage.y = 32;
			bg.addChild(achievImage);
			
			achievName = new TextField();
			achievName.defaultTextFormat = new TextFormat("Arial", 18, -1, true);
			achievName.y = 148;
			achievName.mouseEnabled = false;
			achievName.autoSize = TextFieldAutoSize.CENTER;
			bg.addChild(achievName);
			
			achievDesc = new TextField();
			achievDesc.defaultTextFormat = new TextFormat("Arial", 13, -1, false);
			achievDesc.y = 170;
			achievDesc.mouseEnabled = false;
			achievDesc.autoSize = TextFieldAutoSize.CENTER;
			bg.addChild(achievDesc);
			
			xpReward = new TextField();
			xpReward.defaultTextFormat = new TextFormat("Arial", 14, 0x00ff00, true);
			xpReward.autoSize = TextFieldAutoSize.CENTER;
			xpReward.y = 196;
			xpReward.mouseEnabled = false;
			bg.addChild(xpReward);
			
			shardReward = new TextField();
			shardReward.defaultTextFormat = new TextFormat("Arial", 14, 0x3DB7FF, true);
			shardReward.autoSize = TextFieldAutoSize.CENTER;
			shardReward.y = 196;
			shardReward.mouseEnabled = false;
			bg.addChild(shardReward);
			
			shardIcon = new Sprite();
			shardIcon.addChild(ResList.GetArtResource("shop_shard"));
			bg.addChild(shardIcon);
			shardIcon.visible = false;
			
			G.client.bigDB.loadRange("Achievements", "IDs", [], null, null, 100, 
				function(achievs:Array):void{
					achievements = achievs;
					
					if(profileDataReady) {
						displayAchievements();
					}
				}
			);
		}
		
		private function displayAchievements():void {
			loading.parent.removeChild(loading);
			loading = null;
			
			// show right/left arrows
			var button:Button = new Button(null, onPrevAchievement, ResList.GetArtResource("selector_arrow_big"));
			button.x = 38;
			button.y = bg.height / 2 - button.height / 2 - 10;
			bg.addChild(button);
			
			button = new Button(null, onNextAchievement, ResList.GetArtResource("selector_arrow_big"));
			button.scaleX = -1;
			button.x = bg.width - 38;
			button.y = bg.height / 2 - button.height / 2 - 10;
			bg.addChild(button);
			
			currentAchievementIndex = 0;
			showAchievement(currentAchievementIndex);

		}
		
		public function profileDataLoaded():void {
			profileDataReady = true;
			
			if(achievements) {
				displayAchievements();
			}
		}
		
		private function onPrevAchievement(button:Button):void {
			if(currentAchievementIndex > 0)
				currentAchievementIndex--;
			else 
				currentAchievementIndex = achievements.length - 1;
					
			showAchievement(currentAchievementIndex);
		}
		
		private function onNextAchievement(button:Button):void {
			currentAchievementIndex++;
			if(currentAchievementIndex >= achievements.length)
				currentAchievementIndex = 0;
			
			showAchievement(currentAchievementIndex);
		}
		
		private function showAchievement(index:int):void {
			while(achievImage.numChildren > 0) achievImage.removeChildAt(achievImage.numChildren - 1);
			
			var achiev:Object = achievements[index];
			var achievId:int = achiev.ID;
			var level:int = achievId % 100;
			var offset:int = achievId / 100;
			
			achievImage.addChild(ResList.GetArtResource("achiev_lvl" + level));
			achievImage.addChild(ResList.GetArtResource("achiev_icon" + offset));
			
			achievName.text = achiev.NiceName;
			achievName.x = 185 - achievName.width / 2;
			achievDesc.text = achiev.Description;
			achievDesc.x = 185 - achievDesc.width / 2;
			
			xpReward.text = achiev.XPReward + " xp";
			shardReward.text = achiev.ShardReward.toString();
			
			xpReward.x = 185 - (xpReward.width + shardReward.width + shardIcon.width + 12) / 2;
			shardReward.x = xpReward.x + xpReward.width + 10;
			shardIcon.x = shardReward.x + shardReward.width + 2;
			shardIcon.y = shardReward.y + shardReward.height / 2 - shardIcon.height / 2 - 2;
			shardIcon.visible = true;
			
			var achievKey:String = achiev.key;
			var found:Boolean = false;
			for(var a:String in G.user.achievements) {
				if(a == achievKey) {
					found = true;
					break;
				}
			}
			
			var matrix:Array = new Array();
			if(found) {
				matrix=matrix.concat([1,0,0,0,0]);// red
				matrix=matrix.concat([0,1,0,0,0]);// green
				matrix=matrix.concat([0,0,1,0,0]);// blue
				matrix=matrix.concat([0,0,0,1,0]);// alpha
			}
			else {
				const filterVal:Number = 0.3;
				matrix=matrix.concat([filterVal,filterVal,filterVal,0,0]);// red
				matrix=matrix.concat([filterVal,filterVal,filterVal,0,0]);// green
				matrix=matrix.concat([filterVal,filterVal,filterVal,0,0]);// blue
				matrix=matrix.concat([0,0,0,1,0]);// alpha
			}
			
			var my_filter:ColorMatrixFilter=new ColorMatrixFilter(matrix);
			achievImage.filters=[my_filter];
		}
	}
}