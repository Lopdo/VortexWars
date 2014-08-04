package Errors
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import playerio.PlayerIOError;

	public class ErrorManager
	{
		public static const ERROR_GAME_FULL:int = 1000;
		public static const ERROR_GAME_STARTED:int = 1001;
		public static const ERROR_GUEST_PROFILE_ACCESS:int = 1002;
		public static const ERROR_REMOTE_LOGIN:int = 1003;
		public static const ERROR_REGISTER:int = 1004;
		public static const ERROR_KICKED:int = 1005;
		public static const ERROR_EMAIL_NOT_SET:int = 1006;
		public static const ERROR_BUY_FAILED:int = 1007;
		public static const ERROR_BUY_SUCCES:int = 1008;
		public static const ERROR_LOCAL_LOGIN:int = 1009;
		public static const ERROR_INVALID_PARAMETER:int = 1010;
		public static const ERROR_TIE_TIMEOUT:int = 1011;
		public static const WARNING_IDLE:int = 1100;
		public static const WARNING_IDLE_KICKED:int = 1101;
		
		private static var manager:ErrorManager = null;
		private var queue:Array = new Array();
		private static var currentError:ErrorScreen = null;
		public static var errorSprite:Sprite;
		
		public function ErrorManager(_parent:Sprite)
		{
			ErrorManager.errorSprite = _parent;
		}
		
		private function showError(error:ErrorObject):void {
			for each(var err:ErrorObject in queue) {
				if(err.ID == error.ID)
					return;
			}
			
			if(currentError) {
				if(currentError.errorID == error.ID) return;
				
				queue.push(error);
			}
			else {
				displayError(error);
			} 
		}
		
		private function displayError(error:ErrorObject):void {
			currentError = new ErrorScreen(error);
			errorSprite.addChild(currentError);
			G.sounds.playSound("error_dialog");
		}
		
		private function dismissError():void {
			if(currentError) {
				errorSprite.removeChild(currentError);
				currentError = null;
			}
			
			if(queue.length > 0) {
				displayError(queue.shift());
			}
		}
		
		public static function init(parent:Sprite):void {
			manager = new ErrorManager(parent);
		}

		public static function showPIOError(error:PlayerIOError):void {
			manager.showError(new ErrorObject(error.message, "ERROR", error.errorID, null));
		}
		
		public static function showCustomError(text:String, id:int, callback:Function = null):void {
			manager.showError(new ErrorObject(text, "ERROR", id, callback));
		}
		
		public static function showCustomError2(text:String, title:String, id:int):void {
			manager.showError(new ErrorObject(text, title, id, null));
		}
		
		public static function dismissError():void {
			manager.dismissError();
		}
	}
}