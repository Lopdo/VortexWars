package
{
	import flash.events.TimerEvent;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.utils.Timer;

	public class MultiboxPreventer
	{
		private static var lc:LocalConnection;
		
		public function MultiboxPreventer(callback:Function)
		{
			//return;
			
			if(lc == null) {
			try{
				lc = new LocalConnection();
				lc.allowDomain("*");
				lc.client = this;
				lc.connect("_vwConnection");
			} catch(err:ArgumentError)
			{
				lc = null;
				callback();
			}
			}
		}
	}
}