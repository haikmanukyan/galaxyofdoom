package gamedata;

import controllers.Controller;
import gamedata.States.StatesEnum;
import box2D.dynamics.B2BodyType;
import actions.*;
import h3d.Vector;
import hxd.Key in K;

class Buildings {
	public static function BarracksModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Barracks);
		model.setRotation(0,0,3 * Math.PI / 4);
		model.scale(0.05);
		return model;
	}
	public static function CommandCenterModel(controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.CommandCenter);
		model.setRotation(0,0,Math.PI / 4);
		model.scale(0.05);
		return model;		
	}
	public static function StarportModel(controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.StarPort);
		model.setRotation(0,0,3*Math.PI / 4);
		model.scale(0.05);
		return model;		
	}
	public static function FactoryModel(controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Factory);
		model.setRotation(0,0,3*Math.PI / 4);
		model.scale(0.04);
		return model;		
	}
	
    public static function Barracks (controller : Controller) {
		var stats = new UnitStats();
		stats.physicsSize = 4;
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
		stats.physicsSize = 6;
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
	
	public static function Factory (controller : Controller) {
		var stats = new UnitStats();
		stats.physicsSize = 4;
		stats.isBuilding = true;
		stats.isDropPoint = true;
		stats.cost = {minerals: 100, gas: 50};
		stats.movementSpeed = 0;
		stats.name = "Factory";
		
		var building = new Unit(controller, FactoryModel(controller), stats, StatesEnum.Passive, STATIC_BODY);

		building.controlTree = [
			{
				key : K.T,
				action : controller.Start(Tasks.Train(Units.Worker, new Vector(2.5,2.5,0))),
				icon: null,
				name: "Truck", 
				description: ""
			}
        ];
		
        return building;
	}
	
	public static function Starport (controller : Controller) {
		var stats = new UnitStats();
		stats.physicsSize = 4;
		stats.isBuilding = true;
		stats.isDropPoint = true;
		stats.cost = {minerals: 100, gas: 100};
		stats.movementSpeed = 0;
		stats.name = "Starport";
		
		var building = new Unit(controller, StarportModel(controller), stats, StatesEnum.Passive, STATIC_BODY);

		building.controlTree = [
			{
				key : K.D,
				action : controller.Start(Tasks.Train(Units.Worker, new Vector(2.5,2.5,0))),
				icon: null,
				name: "Drone", 
				description: ""
			}
        ];
		
        return building;
    }
}