import h3d.scene.CameraController;
import hxd.Res;
import haxe.Timer;
import controllers.Controller;
import hxd.Key;
import gamedata.Units;
import hxd.Window;
import h3d.scene.Interactive;
import h3d.prim.Cube;
import h3d.scene.Mesh;
import h3d.Vector;
import h3d.scene.Object;
import h3d.prim.ModelCache;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

import controllers.GameController;
import controllers.GhostController;
import gamedata.ResourceNodes.RecourceNodes;


class Test extends hxd.App 
{
	override function init() 
	{
		new h3d.scene.fwd.DirLight(new Vector( 0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x909090);

		var cache = new ModelCache();
		var model = cache.loadModel(Res.Soldier_Idle);
		model.setScale(0.1);
		s3d.addChild(model);
		model.playAnimation(cache.loadAnimation(Res.Soldier_Idle));

		new CameraController(s3d).loadFromCamera();

	}

	override function update(dt:Float) {
		
	}
}