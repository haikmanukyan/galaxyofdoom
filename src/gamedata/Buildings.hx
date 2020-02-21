package gamedata;

import controllers.Controller;
import gamedata.States.StatesEnum;
import box2D.dynamics.B2BodyType;
import actions.*;
import h3d.Vector;
import hxd.Key in K;

class Buildings {
	public static function BarracksModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Cube);
		model.scaleX = 2;
		model.scaleY = 1.5;
		model.scaleZ = 1.5;
		model.setRotation(0,0,Math.PI / 4);
		return model;
	}
	public static function CommandCenterModel(controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Cube);
		model.scaleX = 3;
		model.scaleY = 3;
		model.scaleZ = 2;
		model.setRotation(0,0,Math.PI / 4);
		return model;		
	}
	
    public static function Barracks (controller : Controller) {
		var stats = new UnitStats();
		stats.physicsSize = 2;
		stats.isBuilding = true;
		stats.cost = {minerals: 50, gas: 0};
		stats.name = "Barracks";
		stats.movementSpeed = 0;
		
		var building = new Unit(controller, BarracksModel(controller), stats,  StatesEnum.Passive, STATIC_BODY);
		
		building.controlTree = [
			{
				key : K.A,
				action : controller.Start(Tasks.Train(Units.Marine, new Vector(2.5,2.5,0))),
				icon: null,
				name: "Marnie", 
				description: ""
			},
        ];
        return building;
	}
	public static function CommandCenter (controller : Controller) {
		var stats = new UnitStats();
		stats.physicsSize = 3;
		stats.isBuilding = true;
		stats.isDropPoint = true;
		stats.cost = {minerals: 100, gas: 0};
		stats.movementSpeed = 0;
		stats.name = "CommandCenter";
		
		var building = new Unit(controller, CommandCenterModel(controller), stats, StatesEnum.Passive, STATIC_BODY);

		building.controlTree = [
			{
				key : K.S,
				action : controller.Start(Tasks.Train(Units.Worker, new Vector(2.5,2.5,0))),
				icon: null,
				name: "SCV", 
				description: ""
			}
        ];
		
        return building;
    }
}