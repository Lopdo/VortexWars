package FriendList
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class FriendItem extends Sprite
	{
		[Embed(source="../../res/playerItemBg.png")] 		private var playerItemBg:Class;
		[Embed(source="../../res/shard.png")] 		private var shard:Class;
		
		[Embed(source="../../res/army_logoElves.png")] 		private var army_logoElves:Class;
		[Embed(source="../../res/army_logoRobots.png")] 		private var army_logoRobots:Class;
		[Embed(source="../../res/army_logoSoldiers.png")] 		private var army_logoSoldiers:Class;
		[Embed(source="../../res/army_logoLegionaires.png")]	private var army_logoLegionaires:Class;
		[Embed(source="../../res/army_logoSnowGiants.png")]	private var army_logoSnowGiants:Class;
		[Embed(source="../../res/army_logoDemons.png")]		private var army_logoDemons:Class;
		[Embed(source="../../res/army_logoAngels.png")]		private var army_logoAngels:Class;
		[Embed(source="../../res/army_logoElementals.png")]	private var army_logoElementals:Class;
		[Embed(source="../../res/army_logoPirates.png")]		private var army_logoPirates:Class;
		[Embed(source="../../res/army_logoNinjas.png")]		private var army_logoNinjas:Class;
		[Embed(source="../../res/army_logoInsectoids.png")]	private var army_logoInsectoids:Class;
		[Embed(source="../../res/army_logoAliens.png")]		private var army_logoAliens:Class;
		[Embed(source="../../res/army_logoVampires.png")]		private var army_logoVampires:Class;
		[Embed(source="../../res/army_logoPumpkins.png")]		private var army_logoPumpkins:Class;
		
		private var image:Sprite;
		private var raceImg:Sprite;
		private var levelLabel:TextField;
		private var inviteLabel:TextField;
		private var shardSprite:Sprite;
		
		public function FriendItem()
		{
			super();
			
			addChild(new playerItemBg());
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);

			image = new Sprite();
			image.x = image.y = 16;
			addChild(image);
			
			/*raceImg = new Sprite();
			raceImg.x = 75;
			raceImg.y = 12;
			addChild(raceImg);*/
			
			/*levelLabel = new TextField();
			levelLabel.text = "";
			levelLabel.setTextFormat(tf);
			levelLabel.autoSize = TextFieldAutoSize.CENTER;
			levelLabel.mouseEnabled = false;
			addChild(levelLabel);*/
		}
		
		public function clear():void {
			//while(numChildren > 0) removeChildAt(numChildren - 1);
			
			if(image.numChildren > 0)
				image.removeChildAt(0);
			
			if(inviteLabel && contains(inviteLabel)) {
				removeChild(inviteLabel);
				removeChild(shardSprite);
				inviteLabel = null;
				shardSprite = null;
			}
			if(raceImg && contains(raceImg)) {
				removeChild(raceImg);
				removeChild(levelLabel);
				raceImg = null;
				levelLabel = null;
			}
		}
		
		public function initWithFriend(name:String, race:int, level:int, imagePath:String):void {
			var tf:TextFormat = new TextFormat("Arial", 13, -1, true);
			
			new TextTooltip(name, image);
			
			loadPicture(imagePath);
			
			raceImg = new Sprite();
			raceImg.x = 75;
			raceImg.y = 12;
			addChild(raceImg);
			
			var raceName:String = "";
			var b:Bitmap;
			switch(race) {
				case 0: 
					b = new army_logoElves();
					raceName = "Elves";
					break;
				case 1: 
					b = new army_logoSnowGiants(); 
					raceName = "Show Giants";
					break;
				case 2: 
					b = new army_logoLegionaires(); 
					raceName = "Legionaires";
					break;
				case 3: 
					b = new army_logoSoldiers(); 
					raceName = "Soldiers";
					break;
				case 4: 
					b = new army_logoRobots(); 
					raceName = "Robots";
					break;
				case 5: 
					b = new army_logoElementals(); 
					raceName = "Elementals";
					break;
				case 6: 
					b = new army_logoPirates(); 
					raceName = "Pirates";
					break;
				case 7: 
					b = new army_logoNinjas(); 
					raceName = "Ninjas";
					break;
				case 100: 
					b = new army_logoAliens(); 
					raceName = "Aliens";
					break;
				case 101: 
					b = new army_logoInsectoids(); 
					raceName = "Insectoids";
					break;
				case 102: 
					b = new army_logoDemons(); 
					raceName = "Demons";
					break;
				case 103: 
					b = new army_logoAngels(); 
					raceName = "Angels";
					break;
				case 104: 
					b = new army_logoVampires(); 
					raceName = "Vampires";
					break;
				case 105: 
					b = new army_logoPumpkins(); 
					raceName = "Pumpkins";
					break;
				default: 
					b = new army_logoElves(); 
					raceName = "Elves";
					break;
			}
			raceImg.addChild(b);

			new TextTooltip(raceName, raceImg);
			
			tf.size = 12;
			tf.bold = false;
			
			levelLabel = new TextField();
			levelLabel.mouseEnabled = false;
			addChild(levelLabel);
			
			levelLabel.text = level.toString();
			levelLabel.setTextFormat(tf);
			levelLabel.autoSize = TextFieldAutoSize.CENTER;
			levelLabel.x = raceImg.x + raceImg.width / 2 - levelLabel.width / 2;
			levelLabel.y = raceImg.y + raceImg.height / 2 - levelLabel.height / 2 - 3;
		}
		
		private var imageLoader:Loader = new Loader()
			
		private function loadPicture(path:String):void{
			if(path != null){
				//Load picture
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handlePictureLoaded);
				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void{/*Do nothing*/});
				//The facebook static image CDN does not have a crossdomain.xml file so we trap security errors when requesting "no profile" images
				imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function():void{/*Do nothing*/});
				imageLoader.load(new URLRequest(path), new LoaderContext(true));
			}
		}
		
		private function handlePictureLoaded(e:Event):void{
			//Attaching the image might throw a security error, we trap and discard those
			try{
				//Onload add content to imagecontainer
				image.addChild(imageLoader.content);
				//image.width = 50;
				//image.height = 50;
				//image.x = image.y = image.parent.width / 2 - image.width / 2;
				image.y = 15 + 50 / 2 - image.width / 2;
				image.y = 16 + 50 / 2 - image.height / 2;
			}catch(e:Error){/*Do nothing*/}
		}
		
		public function initWithInvite():void {
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			inviteLabel = new TextField();
			inviteLabel.text = "Invite\nFriend\n\n+100   .";
			inviteLabel.setTextFormat(tf);
			inviteLabel.x = 75;
			inviteLabel.width = 60;
			inviteLabel.y = 10;
			inviteLabel.autoSize = TextFieldAutoSize.CENTER;
			inviteLabel.mouseEnabled = false;
			addChild(inviteLabel);
			
			shardSprite = new Sprite();
			shardSprite.addChild(new shard());
			shardSprite.x = 116;
			shardSprite.y = 57;
			shardSprite.scaleX = 0.8;
			shardSprite.scaleY = 0.8;
			Bitmap(shardSprite.getChildAt(0)).smoothing = true;
			addChild(shardSprite);
		}
	}
}