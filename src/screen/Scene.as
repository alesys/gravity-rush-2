package screen
{
	import flash.net.SharedObject;
	
	import characters.Enemy;
	import characters.Hero;
	
	import items.Columns;
	
	import starling.animation.DelayedCall;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	import starling.textures.TextureSmoothing;
	import starling.utils.HAlign;
	
	public class Scene extends Sprite
	{
		public var hero:Hero;
		private var particles:PDParticleSystem;
		private var explosion:PDParticleSystem;
		private var _score:int;
		private var scores_label:TextField;
		private var limit:int = 800;
		
		private var logo:Image;
		private var gameover:Image;
		private var lava:Sprite;
		private var restart:Button;
		private var scores:Button;
		public function Scene()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		public function getSO():SharedObject
		{
			return SharedObject.getLocal('GravityRush');
		}
		public function flush():void
		{
			getSO().flush();
		}
		override public function removeFromParent(dispose:Boolean=false):void
		{
			Starling.juggler.remove( this.particles );
			Starling.juggler.remove( this.explosion );
			if ( this.particles ) this.particles.removeFromParent(true);
			if ( this.explosion ) this.explosion.removeFromParent(true);
			this.removeChildren(0,-1,true);
			super.removeFromParent(dispose);
		}
		private function initialize():void
		{
		
			this.particles = new PDParticleSystem( Game.instance.assets.getXml('particle'), Game.instance.assets.getTexture('texture') );		
			this.particles.smoothing = TextureSmoothing.NONE;
			this.addChild(this.particles);
			Starling.juggler.add(this.particles);
			
			this.explosion = new PDParticleSystem( Game.instance.assets.getXml('explosion'), Game.instance.assets.getTexture('texture'));
			this.explosion.smoothing = TextureSmoothing.NONE;
			this.addChild(this.explosion);
			Starling.juggler.add(this.explosion);
			
			
			this.hero = new Hero();
			this.addChild( this.hero );
			this.scores_label = new TextField( stage.stageWidth, 120, '0', 'scores_font', 80, 0xFFFFFF,false);
			TextField.getBitmapFont('scores_font').smoothing = TextureSmoothing.NONE;
			this.addChild(this.scores_label);
			
			var startbtn:Button = new Button( Game.instance.assets.getTexture('start'));
			startbtn.scaleX = startbtn.scaleY = .25;
			startbtn.addEventListener( Event.TRIGGERED, handle_startbtn);
			this.addChild( startbtn );
			startbtn.x = stage.stageWidth - startbtn.width >> 1;
			startbtn.y = stage.stageHeight - startbtn.height >> 1;
			
			this.lava = new Sprite();
			var lavaA:Image = new Image(Game.instance.assets.getTexture('lava'));
			var lavaB:Image = new Image(Game.instance.assets.getTexture('lava'));
			
			lavaA.smoothing = TextureSmoothing.NONE;
			lavaB.smoothing = TextureSmoothing.NONE;
			
			lavaB.x = lavaA.width;
			this.lava.addChild( lavaA );
			this.lava.addChild( lavaB );
			
			this.lava.y = limit;
			
			this.addChild(this.lava);
			
			if ( !this.getSO().data.max_score )
			{
				this.getSO().data.max_score = 0;
				this.flush();
			}
			
			this.logo = new Image( Game.instance.assets.getTexture('logo'));
			this.logo.scaleX = this.logo.scaleY = .25;
			this.logo.x = this.stage.stageWidth - this.logo.width >> 1; 
			this.logo.y = 200;
			this.addChild(this.logo);
		}
		public function set score(n:int):void
		{
			this._score = n; 
			this.scores_label.text = n.toString();
		}
		public function get score():int
		{
			return _score;
		}
		private function handle_startbtn(e:Event):void
		{
			Game.instance.assets.getSound('coin').play();
			var a:Button = e.currentTarget as Button;
			a.removeFromParent(true);
			this.stage.removeEventListeners(TouchEvent.TOUCH);
			this.stage.addEventListener(TouchEvent.TOUCH, handle_touch);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			this.hero.start();
			this.hero.jetPack();
			this.spawn_columns();
		}
		private function handle_start(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch( this.stage, TouchPhase.ENDED);
			if ( touch ) 
			{
				this.stage.removeEventListeners(TouchEvent.TOUCH);
				this.stage.addEventListener(TouchEvent.TOUCH, handle_touch);
				this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
				this.hero.start();
				this.hero.jetPack();
				this.spawn_columns();
			}
		}
		private var spawn_columns_call:DelayedCall;
		private function spawn_columns():void
		{
			this.spawn_columns_call = new DelayedCall( this.spawn_column, 3 );
			this.spawn_columns_call.repeatCount = 0;
			Starling.juggler.add( this.spawn_columns_call );
		}
		private function spawn_column():void
		{
			this.addChild( new Columns() );
		}
		private function stop_spawning_columns():void
		{
			Starling.juggler.remove( this.spawn_columns_call ) ;
		}
		private function update():void
		{
			this.particles.emitterX = this.hero.x-16;
			this.particles.emitterY = this.hero.y;
			this.setChildIndex(this.hero, this.numChildren-1);
			this.setChildIndex(this.scores_label, this.numChildren-1);
			this.setChildIndex(this.explosion, this.numChildren-1);
			this.setChildIndex(this.lava, this.numChildren-1);
			if ( !this.hero.isDead && this.hero.y > this.limit )
			{
				this.kill_hero();
			}
			if ( this.logo.parent )
			{
				this.logo.x -= 3;
				if ( this.logo.x < this.logo.width * -1 )
				{
					this.logo.removeFromParent();
				}
			}
			if ( this.lava )
			{
				this.lava.x -=5;
				if ( this.lava.x < -640 )
				{
					this.lava.x+=640;
				}
			}
		}
		
		public function kill_hero():void
		{
			Game.instance.showBanner();
			this.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
			this.explosion.emitterX = this.hero.x;
			this.explosion.emitterY = this.hero.y;
			this.explosion.start(.25);
			hero.die();
			this.stop_spawning_columns();
			this.stage.removeEventListeners(TouchEvent.TOUCH);
			this.show_menu();
		}
		
		private function show_menu():void
		{
			restart = new Button( Game.instance.assets.getTexture('restart'));
			restart.scaleX = restart.scaleY = .25;
			this.addChild(restart);
			restart.x = -100;
			restart.y = stage.stageHeight-restart.height>>1;
			restart.y -= 100;
			
			Starling.juggler.tween( restart, 1, { x:stage.stageWidth-restart.width>>1, transition:Transitions.EASE_OUT_BACK  } );
			
			restart.addEventListener(Event.TRIGGERED, function(e:Event):void
			{
				Game.instance.assets.getSound('coin').play();
				Starling.juggler.remove(explosion);
				Starling.juggler.remove(particles);
				dispatchEventWith(Event.COMPLETE);
				
			});
			
			
			scores = new Button(Game.instance.assets.getTexture('scores'));
			addChild(scores);
			scores.scaleX = scores.scaleY = .25;
			scores.x = stage.stageWidth + 100;
			scores.y = restart.bounds.bottom + 6;
			scores.addEventListener(Event.TRIGGERED, function ():void
			{
				Game.instance.showScoreView();
			});
			Starling.juggler.tween( scores, 1, {x:stage.stageWidth - scores.width >> 1, transition:Transitions.EASE_OUT_BACK});
			
			gameover = new Image( Game.instance.assets.getTexture('gameover') );
			gameover.smoothing = TextureSmoothing.NONE;
			gameover.scaleX = gameover.scaleY = .25;
			addChild(gameover);
			gameover.x = stage.stageWidth-gameover.width>>1;
			gameover.y = -100;
			Starling.juggler.tween( gameover, 1, {y:200, transition:Transitions.EASE_OUT_BACK} );
			
			if ( logo && logo.parent ) logo.removeFromParent();
			
			var max_score:int = this.getSO().data.max_score;
			if ( score > max_score)
			{
				this.getSO().data.max_score = score;
				this.flush();
				max_score = score;
			}
			//
			var menu_score:TextField;
			var menu_maxscore:TextField;
			
			menu_score = new TextField( 200,40, 'SCORE ' + score.toString(), 'scores_font', 24, 0xFFFFFF);
			menu_maxscore = new TextField( 200,40, 'BEST '+max_score.toString(), 'scores_font', 24, 0xFFFFFF);
			
			menu_maxscore.hAlign = menu_score.hAlign = HAlign.LEFT;
			menu_maxscore.x = menu_score.x = stage.stageWidth - scores.width >> 1;
			menu_score.y = scores.bounds.bottom + 20;
			menu_maxscore.y = menu_score.bounds.bottom + 10;
			
			this.addChild(menu_score);
			this.addChild(menu_maxscore);
			if ( score >= this.getSO().data.max_score )
			{
				Game.instance.submitScore( score );
			}
		}
		private function handle_touch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch( this.stage, TouchPhase.BEGAN);
			if (touch)
			{
				this.hero.jetPack();
				this.particles.start( 0.25 ) ;
			}
		}
		private var spawn_enemies_call:DelayedCall;
		private function spawn_enemies():void
		{
			this.spawn_enemies_call = new DelayedCall( this.spawn_enemy, .25 );
			this.spawn_enemies_call.repeatCount = 0;
			Starling.juggler.add( this.spawn_enemies_call );
		}
		private function spawn_enemy():void
		{
			this.addChild(new Enemy());
		}
		private function stop_spawning():void
		{
			Starling.juggler.remove( this.spawn_enemies_call );
		}
	}
}