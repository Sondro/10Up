package;

import kha.Color;
import kha.math.Vector2;
import kha.Painter;
import kha.Scene;
import projectiles.PistolProjectile;

class PlayerAgent extends Player {
	private var graple: GrapleHook;
	private var grapleVec: Vector2;
	private var grapleLength: Float;
	private var grapleBack = false;
	private var maxGrapleLength: Float = 350;
	private var pulling = false;
	
	public function new(x: Float, y: Float) {
		super(x, y, "jumpman");
		Player.setPlayer(0, this);
		graple = new GrapleHook();
		grapleVec = null;
		grapleLength = 0;
		Scene.the.addHero(graple);
	}
	
	var lastFired : Float = 0;
	
	override public function prepareSpecialAbilityA(gameTime:Float) : Void {
		isCrosshairVisible = true;
	}
	
	/**
	  Pistole
	**/
	override public function useSpecialAbilityA(gameTime : Float) : Void {
		if (lastFired + 0.2 < gameTime) {
			var projectile = new PistolProjectile( null, 5, 5, this.z);
			projectile.x = muzzlePoint.x + (lookRight ? 0.8 : -0.8) * (projectile.width * crosshair.x);
			projectile.y = muzzlePoint.y + (lookRight ? 0.8 : -0.8) * (projectile.height * crosshair.y);
			projectile.speedx = 15 * crosshair.x;
			projectile.speedy = 15 * crosshair.y;
			projectile.accy = 0;
			Scene.the.addProjectile( projectile );
			lastFired = gameTime;
		}
		isCrosshairVisible = false;
	}
	
	/**
	  Haken
	**/
	override public function useSpecialAbilityB(gameTime : Float) : Void {
		grapleVec = new Vector2(crosshair.x, crosshair.y);
		grapleBack = false;
		grapleLength = 0;
	}
	
	override public function update() {
		super.update();
		graple.x = x + 10;
		graple.y = y + 5;
		graple.rotation.angle = Math.atan2(crosshair.y, crosshair.x);
		
		if (grapleVec != null) {
			if (pulling) {
				x += grapleVec.x * 5;
				y += grapleVec.y * 5;
				grapleLength -= grapleVec.length * 5;
				if (grapleLength < 20 || Scene.the.collidesSprite(this)) {
					x -= grapleVec.x * 5;
					y -= grapleVec.y * 5;
					grapleLength = 0;
					pulling = false;
					grapleVec = null;
					accy = 0.2;
					speedy = -5;
				}
			}
			else {
				if (grapleBack) {
					grapleLength -= 10;
					if (grapleLength < 0) {
						grapleLength = 0;
						grapleBack = false;
						grapleVec = null;
					}
				}
				else {
					grapleLength += 10;
					if (grapleLength > maxGrapleLength) {
						grapleLength -= (grapleLength - maxGrapleLength);
						grapleBack = true;
					}
					if (Scene.the.collidesPoint(new Vector2(hookX(), hookY()))) {
						grapleBack = false;
						pulling = true;
						accy = 0;
						speedy = 0;
					}
				}
			}
		}
	}
	
	private function hookX(): Float {
		return x + 10 + grapleVec.x * grapleLength;
	}
	
	private function hookY(): Float {
		return y + 5 + grapleVec.y * grapleLength;
	}
	
	override public function render(painter:Painter): Void {
		super.render(painter);
		if (grapleVec != null) {
			painter.setColor(Color.fromBytes(0, 0, 0));
			painter.drawLine(x + 10, y + 5, hookX(), hookY());
		}
	}
}
