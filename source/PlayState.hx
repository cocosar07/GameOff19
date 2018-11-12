package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import entities.Entity;
import entities.Enemy;

class PlayState extends FlxState
{
	public var map:TileMap;
	public var player:Player;
	public var grappling:Grappling;

	public var rocks:FlxGroup;
	public var enemies:FlxGroup;

	override public function create():Void
	{
		super.create();
		FlxG.camera.bgColor.setRGBFloat(108.9/255, 194.0/255, 202.0/255);

		rocks = new FlxGroup();
		enemies = new FlxGroup();

		map = new TileMap(AssetPaths.map1__tmx, this);
		add(map.backgroundLayer);
		add(map.collisionLayer);

		player = new Player(125, 150);
		add(player);
		player.launchGrapplingSignal.add(launchGrappling);

		grappling = null;

		add(rocks);
		add(enemies);

		var e:Enemy = cast enemies.recycle(Enemy);
		e.setPosition(Std.int(150/8)*8, Std.int(150/8)*8);
		e.player = player;

		FlxG.camera.follow(player, LOCKON, 0.3);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!player.pulled)
		{
			map.collideWithLevel(player);
			FlxG.overlap(rocks, player, null, FlxObject.separate);
			FlxG.overlap(enemies, player, null, FlxObject.separate);
		}

		for (e in enemies)
		{
			var enemy:Entity = cast e;
			if (!enemy.pulled)
			{
				map.collideWithLevel(enemy);
				FlxG.overlap(rocks, enemy, null, FlxObject.separate);
			}
		}

		if (grappling != null && grappling.launched)
		{
			FlxG.overlap(rocks, grappling, grapplingCollision);
			FlxG.overlap(enemies, grappling, grapplingCollision);
		}
	}

	public function launchGrappling():Void
	{
		if (grappling != null)
			return;

		grappling = new Grappling(0, 0, player);
		grappling.setPosition(player.getMidpoint().x, player.getMidpoint().y);
		flixel.math.FlxVelocity.moveTowardsMouse(grappling, grappling.speed);

		grappling.destroyGrappling.add(destroyGrappling);
		add(grappling);
	}

	public function destroyGrappling():Void
	{
		remove(grappling);
		grappling.kill();
		grappling = null;
	}

	public function grapplingCollision(other:FlxObject, _:FlxObject):Void
	{
		var entity:Entity = cast other;

		if (entity == null)
			return;
	
		grappling.setPosition(other.getMidpoint().x, other.getMidpoint().y);	
		grappling.grabbedItem = entity;

		grappling.launched = false;
		grappling.velocity.set(0, 0);
		
		if (!entity.pullable)
		{
			grappling.startPullingPlayer();
		}
		else
		{
			// Pull object
			entity.pulled = true;
		}
	}
}
