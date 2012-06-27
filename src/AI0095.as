package  
{
	import cepa.utils.ToolTip;
	import Box2DAS.Common.V2;
	import fl.events.SliderEvent;
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
		private var zoomInCount:int = 0;
		private var zoomOutCount:int = 0;
		
		public function AI0095() 
		{
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			telaInfo.visible = false;
			
			botaoPlay.addEventListener(MouseEvent.CLICK, lanca);
			menu.botaoReset.addEventListener(MouseEvent.CLICK, reset);
			botaoStop.addEventListener(MouseEvent.CLICK, reset);
			menu.botaoInfo.addEventListener(MouseEvent.CLICK, info);
			telaInfo.addEventListener(MouseEvent.CLICK, info);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, drag);
			stage.addEventListener(MouseEvent.MOUSE_UP, drop);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheel);
			zoomIn.addEventListener(MouseEvent.MOUSE_DOWN, zoom);
			zoomOut.addEventListener(MouseEvent.MOUSE_DOWN, zoom);
			stage.addEventListener(MouseEvent.MOUSE_UP, function () {if (timer != null) timer.stop()});
			//slider.addEventListener(MouseEvent.MOUSE_DOWN, removeStageEvent);
			//slider.addEventListener(MouseEvent.MOUSE_UP, addStageEvent);
			slider.addEventListener(SliderEvent.CHANGE, changeSlider);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent) { if (KeyboardEvent(e).keyCode == Keyboard.ESCAPE) telaInfo.visible = false; aboutScreen.visible = false;} );			
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
			createToolTips();
			
			world.paused = true;
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
			if (e.delta < 0) {
				if (zoomOutCount < 16) {
					world.scaleX = world.scaleY = world.scaleX - 0.05;
					zoomOutCount++;
					zoomInCount--;
				}
			}
			
			if (e.delta > 0) {
				if (zoomInCount < 10) {
					world.scaleX = world.scaleY = world.scaleX + 0.05;
					zoomInCount++;
					zoomOutCount--;
				}
			}
		}
		
		private function zoom(e:MouseEvent):void 
		{
			timer = new Timer(100);
			
			if (e.target is ZoomMenos) {
				zoomMenos(null);
				timer.addEventListener(TimerEvent.TIMER, zoomMenos);
			}
			if (e.target is ZoomMais) {
				zoomMais(null);
				timer.addEventListener(TimerEvent.TIMER, zoomMais);
			}
			
			timer.start();
		}
		
		private function zoomMenos(e:TimerEvent):void {
			if (zoomOutCount < 16) {
				world.scaleX = world.scaleY = world.scaleX - 0.05;
				zoomOutCount++;
				zoomInCount--;
			}
		}
		
		private function zoomMais(e:TimerEvent):void {
			if (zoomInCount < 10) {
				world.scaleX = world.scaleY = world.scaleX + 0.05;
				zoomInCount++;
				zoomOutCount--;
			}
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
				botaoPlay.removeEventListener(MouseEvent.CLICK, continua);
				botaoPlay.addEventListener(MouseEvent.CLICK, lanca);
				botaoPlay.visible = true;
				botaoPause.visible = false;
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
			zoomInCount = 0;
			zoomOutCount = 0;
			
			botaoPlay.visible = true;
			botaoPause.visible = false;
			
			botaoPlay.removeEventListener(MouseEvent.CLICK, continua);
			botaoPlay.addEventListener(MouseEvent.CLICK, lanca);
		}
		
		private function changeSlider(e:SliderEvent):void 
		{
			if (world.paused) return;
			
			botaoPlay.visible = true;
			botaoPause.visible = false;
			
			botaoPlay.removeEventListener(MouseEvent.CLICK, continua);
			botaoPlay.addEventListener(MouseEvent.CLICK, lanca);
		}
		
		private function lanca(e:MouseEvent):void 
		{
			botaoPlay.removeEventListener(MouseEvent.CLICK, lanca);
			botaoPlay.addEventListener(MouseEvent.CLICK, continua);
			botaoPause.addEventListener(MouseEvent.CLICK, pausa);
			
			if (!world.paused || distancia() <= 137) {
				stage.removeEventListener(Event.ENTER_FRAME, onTimer);
				
				for (var i:int = 1; i <= projeteisEstaticos.length; i++ ) world.removeChild(projeteisEstaticos[projeteisEstaticos.length - i]);
				projeteisEstaticos = new Array();
				
				world.removeChild(projetil);
				projetil = null;
				
				criaProjetil();
			}
			
			botaoPlay.visible = false;
			botaoPause.visible = true;
			
			world.canhao.play();
			world.paused = false;
			
			projetil.applyGravity = true;
			projetil.linearVelocityX = slider.value;
			
			stage.addEventListener(Event.ENTER_FRAME, onTimer);
			
		}
		
		private function continua(e:MouseEvent):void 
		{
			stage.addEventListener(Event.ENTER_FRAME, onTimer);
			world.paused = false;
			
			botaoPlay.visible = false;
			botaoPause.visible = true;
		}
		
		private function pausa(e:MouseEvent):void 
		{
			stage.removeEventListener(Event.ENTER_FRAME, onTimer);
			world.paused = true;
			
			botaoPlay.visible = true;
			botaoPause.visible = false;
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
		
		/**
		 * Cria os tooltips nos botões
		 */
		private function createToolTips():void 
		{
			var instTT:ToolTip = new ToolTip(menu.botaoInfo, "Informações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(menu.botaoReset, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var infoTT:ToolTip = new ToolTip(menu.botaoCreditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			
			addChild(instTT);
			addChild(resetTT);
			addChild(infoTT);
		}
	}

}