package
{
	import com.adobe.ane.gameCenter.GameCenterAuthenticationEvent;
	import com.adobe.ane.gameCenter.GameCenterController;
	import com.adobe.ane.gameCenter.GameCenterLeaderboardEvent;
	import com.milkmangames.nativeextensions.GoogleGames;
	import com.milkmangames.nativeextensions.events.GoogleGamesEvent;
	import com.revmob.airextension.RevMob;
	
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import screen.Scene;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	import utils.Assets;
	
	public class Game extends Sprite
	{
		public var assets:Assets;
		public var scene:Scene;
		protected static var _instance:Game;
		private var revmob:RevMob;
		public static function get instance():Game { return _instance; } 
		public function Game()
		{
			_instance = this;
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		private function initialize(e:Event):void
		{
			if (isIOS())
			{
				revmob = new RevMob('');
			}
			else
			{
				revmob = new RevMob('');
			}
			this.loadAssets();
			this.setupGameCenter();
		}
		private function loadAssets():void
		{
			this.assets = new Assets(.25);
			this.assets.enqueue(File.applicationDirectory.resolvePath('assets'));
			this.assets.loadQueue( this.onProgress );
		}
		private var gcController:GameCenterController;
		private var googleGames:GoogleGames;
		private function setupGameCenter():void
		{
			trace( 'GameCenterController.isSupported', GameCenterController.isSupported );
			trace( 'GooglePlayGames.isSupported', GoogleGames.isSupported() );
			if ( isIOS() && GameCenterController.isSupported) 
			{
				this.gcController = new GameCenterController();
				if ( !this.gcController.authenticated )
				{
					this.gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATED, onGameCenterAuth);
					this.gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_NOT_AUTHENTICATED, onGameCenterAuthFail);
					this.gcController.addEventListener(GameCenterLeaderboardEvent.SUBMIT_SCORE_SUCCEEDED, onGameScoreSuccess);
					this.gcController.authenticate();
					trace('GameCenter.authenticate()');
				}
			}
			else
			{
				if ( GoogleGames.isSupported() )
				{
					googleGames = GoogleGames.games;
					googleGames.addEventListener(GoogleGamesEvent.SIGN_IN_SUCCEEDED, onGoogleGameAuth);
					googleGames.addEventListener(GoogleGamesEvent.SIGN_IN_FAILED, onGoogleGameAuthFail);
					googleGames.signIn();
				}
			}
		}
		public var isGoogleGames:Boolean;
		private function onGoogleGameAuth(e:GoogleGamesEvent):void
		{
			trace( e);
			isGoogleGames = true;
		}
		private function onGoogleGameAuthFail(e:GoogleGamesEvent):void
		{
			trace( e);
		}
		private function onGameCenterAuthFail(e:GameCenterAuthenticationEvent):void
		{
			trace ( e);
		}
		private function onGameScoreSuccess(e:GameCenterLeaderboardEvent):void
		{
			trace( e );
		}
		
		private function onGameCenterAuth(e:GameCenterAuthenticationEvent):void
		{
			if ( this.gcController.localPlayer )
			{
				trace ('player auth', JSON.stringify(this.gcController.localPlayer),null,' ');
			}
		}
		public function submitScore(n:int):void
		{
			if ( isIOS() && this.gcController && this.gcController.authenticated )
			{
				//
				trace('submitScore', n);
				this.gcController.submitScore( n );
			}
			else if ( !isIOS() && isGoogleGames && googleGames)
			{
				googleGames.submitScore('',n);
			}
		}
		public function showScoreView():void
		{
			if ( isIOS() && this.gcController && this.gcController.authenticated )
			{
				this.gcController.showLeaderboardView();
			}
			else if ( !isIOS() && this.googleGames && this.isGoogleGames )
			{
				googleGames.showLeaderboard('');
			}
		}
		private function onProgress(ratio:Number):void
		{
			if (ratio == 1 )
			{
				assetsLoaded();
			}
		}
		private var background:Image;
		private function assetsLoaded():void
		{
			this.background = new Image(this.assets.getTexture('bg'));
			this.background.smoothing = TextureSmoothing.NONE;
			this.background.pivotX = this.background.width>>1;
			this.background.x = this.stage.stageWidth>>1;
			this.background.y = 0;
			this.addChild(background);
			
			this.scene = new Scene();
			this.scene.addEventListener(Event.COMPLETE, handle_new_game);
			this.addChild(this.scene);
		}
		public function showBanner():void
		{
			
			 var positionX:int = 00;
			 var positionY:int = 0;
			 var width:int = 300;
			 var height:int = 40;
			 
			revmob.showBanner(positionX, positionY, width, height);
		}
		private function handle_new_game():void
		{
			
			revmob.hideBanner();
			this.scene.removeFromParent(true);
			this.assetsLoaded();
		}
		public function isIOS():Boolean{
			if ( Capabilities.os.indexOf('iPhone') > -1 ||
				 Capabilities.manufacturer.indexOf('iOS') > -1 ||
				 Capabilities.version.indexOf('IOS') > -1)
			{
				return true;
			}
			return false;
		}
	}
}