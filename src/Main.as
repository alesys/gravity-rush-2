package
{
	import com.milkmangames.nativeextensions.GoogleGames;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import starling.core.Starling;

	[SWF(frameRate="48",backgroundColor='#000000', height="1136", width="640")]
	public class Main extends Sprite
	{
		private var star:Starling;
		public function Main()
		{
			if ( GoogleGames.isSupported() ) GoogleGames.create();
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP;
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(e:Event):void
		{
			trace( stage.fullScreenWidth, stage.fullScreenHeight);
			trace( stage.width, stage.height );
			var viewport:Rectangle = new Rectangle(0,0,stage.fullScreenWidth, stage.fullScreenHeight);
			this.star = new Starling( Game, this.stage, viewport );
			this.star.stage.stageWidth = 640;
			this.star.stage.stageHeight = Math.round(viewport.height*640/viewport.width);			
			this.star.start();
			this.star.showStats = true;
			trace( viewport );
			trace( this.star.stage.stageWidth, this.star.stage.stageHeight);
			trace( Capabilities.os );
			trace( Capabilities.manufacturer );
			trace( Capabilities.version );
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, deactivate);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activate);
		}
		private function deactivate(e:Event):void
		{
			this.star.stop(true);
		}
		private function activate(e:Event):void
		{
			this.star.start();
		}
		
	}
}