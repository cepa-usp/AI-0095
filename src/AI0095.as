package  
{
	import Box2DAS.Common.V2;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import wck.WCK;
	import wck.World;
	/**
	 * ...
	 * @author Luciano
	 */
	public class AI0095 extends WCK
	{
		private var projetil:Projetil;
		private var projeteisEstaticos:Array = new Array();
		private var timer:Timer;
		
		public function AI0095() 
		{
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//timer = new Timer(10);
			
			//World(world).gravityY = 10;
			
			telaInfo.visible = false;
			
			botaoPlay.addEventListener(MouseEvent.CLICK, lanca);
			menu.botaoReset.addEventListener(MouseEvent.CLICK, reset);
			menu.botaoInfo.addEventListener(MouseEvent.CLICK, info);
			telaInfo.addEventListener(MouseEvent.CLICK, info);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, drag);
			stage.addEventListener(MouseEvent.MOUSE_UP, drop);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheel);
			//slider.addEventListener(MouseEvent.MOUSE_DOWN, removeStageEvent);
			//slider.addEventListener(MouseEvent.MOUSE_UP, addStageEvent);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent) { if (KeyboardEvent(e).keyCode == Keyboard.ESCAPE) telaInfo.visible = false; aboutScreen.visible = false;} );			
			trace("-");
			menu.botaoCreditos.addEventListener(MouseEvent.CLICK, function () { aboutScreen.visible = true; setChildIndex(aboutScreen, numChildren - 1); } );
			aboutScreen.addEventListener(MouseEvent.CLICK, function () { aboutScreen.visible = false; } );
			makeoverOut(menu.botaoReset);
			makeoverOut(menu.botaoInfo);
			makeoverOut(menu.botaoCreditos);
			
			menu.botaoReset.buttonMode = true;
			menu.botaoInfo.buttonMode = true;
			menu.botaoCreditos.buttonMode = true;
			botaoPlay.buttonMode = true;
			botaoPause.buttonMode = true;
			
			aboutScreen.visible = false;
			
			slider.minimum = 0.1;
			slider.maximum = 15;
			slider.snapInterval = 0.01;
			slider.value = 5;
			
			criaProjetil();
		}
		
		private function info(e:MouseEvent):void 
		{
			telaInfo.visible = !telaInfo.visible;
		}
		
		private function addStageEvent(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, drag);
		}
		
		private function removeStageEvent(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, drag);
		}
		
		private function wheel(e:MouseEvent):void 
		{
			if (e.delta < 0) if (world.scaleX - 0.05 > 0) world.scaleX = world.scaleY = world.scaleX - 0.05;
			if (e.delta > 0) world.scaleX = world.scaleY = world.scaleX + 0.05;
		}
		
		private function drop(e:MouseEvent):void 
		{
			world.stopDrag();
		}
		
		private function drag(e:MouseEvent):void 
		{
			if (e.target is Background || e.target.parent is World) world.startDrag();
		}
		
		private function onTimer(e:Event):void 
		{
			projeteisEstaticos.push(new ProjetilEstatico());
			world.addChild(projeteisEstaticos[projeteisEstaticos.length - 1]);
			projeteisEstaticos[projeteisEstaticos.length - 1].x = projetil.x;
			projeteisEstaticos[projeteisEstaticos.length - 1].y = projetil.y;
			world.setChildIndex(projetil, world.numChildren - 1);
			
			if (projeteisEstaticos.length > 40) {
				world.removeChild(projeteisEstaticos[0]);
				projeteisEstaticos.splice(0, 1);
			}
			
			world.setChildIndex(world.canhao, world.numChildren - 1);
			
			if (distancia() <= 137) {
				stage.removeEventListener(Event.ENTER_FRAME, onTimer);
				world.paused = true;
			}
		}
		
		private function distancia():Number
		{
			var dist:Number = Math.sqrt(Math.pow(world.globo.x - projetil.x, 2) + Math.pow(world.globo.y - projetil.y, 2));
			return dist;
		}
		
		private function criaProjetil():void
		{
			projetil = new Projetil();
			projetil.x = 0;
			projetil.y = -155;
			world.addChild(projetil);
			projetil.applyGravity = false;
			projetil.autoSleep = false;
			projetil.allowDragging = false;
			world.setChildIndex(world.canhao, world.numChildren - 1);
		}
		
		private function reset(e:MouseEvent):void 
		{
			//timer.stop();
			//timer.reset();
			stage.removeEventListener(Event.ENTER_FRAME, onTimer);
			
			world.scaleX = world.scaleY = 1;
			world.x = 350;
			world.y = 270;
			
			for (var i:int = 1; i <= projeteisEstaticos.length; i++ ) world.removeChild(projeteisEstaticos[projeteisEstaticos.length - i]);
			projeteisEstaticos = new Array();
			
			world.removeChild(projetil);
			projetil = null;
			
			criaProjetil();
			
			slider.value = 5;
			
			botaoPlay.addEventListener(MouseEvent.CLICK, lanca);
		}
		
		private function lanca(e:MouseEvent):void 
		{
			botaoPlay.removeEventListener(MouseEvent.CLICK, lanca);
			botaoPlay.addEventListener(MouseEvent.CLICK, continua);
			botaoPause.addEventListener(MouseEvent.CLICK, pausa);
			
			world.canhao.play();
			
			//timer.start();
			//timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			projetil.applyGravity = true;
			projetil.linearVelocityX = slider.value;
			
			stage.addEventListener(Event.ENTER_FRAME, onTimer);
			
		}
		
		private function continua(e:MouseEvent):void 
		{
			//timer.start();
			stage.addEventListener(Event.ENTER_FRAME, onTimer);
			world.paused = false;
		}
		
		private function pausa(e:MouseEvent):void 
		{
			//timer.stop();
			stage.removeEventListener(Event.ENTER_FRAME, onTimer);
			world.paused = true;
		}
		
		private function makeoverOut(btn:MovieClip):void
		{
			btn.mouseChildren = false;
			btn.addEventListener(MouseEvent.MOUSE_OVER, over);
			btn.addEventListener(MouseEvent.MOUSE_OUT, out);
		}
		
		private function over(e:MouseEvent):void
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.gotoAndStop(2);
		}
		
		private function out(e:MouseEvent):void
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.gotoAndStop(1);
		}
	}

}