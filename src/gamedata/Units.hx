package gamedata;

import h3d.Vector;
import hxd.Key in K;

import actions.*;
import gamedata.States.*;
import gamedata.States.StatesEnum;
import controllers.Controller;

class Units {
	public static function WorkerModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.SCV);
		model.getMaterials()[0].color = controller.player.color;
		model.setScale(0.01);

		return model;
	}
	public static function MarineModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Soldier_Idle);
		model.playAnimation(controller.game.cache.loadAnimation(hxd.Res.Soldier_Idle));

		model.getMaterials()[0].color = controller.player.color;

		return model;
	}
	public static function TruckModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Truck);
		model.getMaterials()[0].color = controller.player.color;
		model.setScale(0.011);

		return model;
	}
	public static function HumveeModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Humvee);
		model.getMaterials()[0].color = controller.player.color;
		model.setScale(0.01);

		return model;
	}
	public static function DroneModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Drone);
		model.getMaterials()[0].color = controller.player.color;
		model.z = 5;

		return model;
	}


    public static function Worker (controller : Controller) {
		var stats = new UnitStats();
		stats.name = "SCV";
		stats.cost = {minerals: 50, gas: 0};
		stats.movementSpeed = 15;
		stats.physicsSize = 2;
		
		var unit = new Unit(controller, WorkerModel(controller), stats);

        var buildActions = [
			{
				key : K.B,
				action : controller.SetPending(Tasks.Build(Buildings.Barracks), false, Buildings.BarracksModel(controller)),
				icon: null,
				name: "Barracks", 
				description: ""
			},
			{
				key : K.S,
				action : controller.SetPending(Tasks.Build(Buildings.Starport), false, Buildings.StarportModel(controller)),
				icon: null,
				name: "Starport", 
				description: ""
			},
			{
				key : K.F,
				action : controller.SetPending(Tasks.Build(Buildings.Factory), false, Buildings.FactoryModel(controller)),
				icon: null,
				name: "Factory", 
				description: ""
            },
            {
				key : K.C,
				action : controller.SetPending(Tasks.Build(Buildings.CommandCenter), false, Buildings.CommandCenterModel(controller)),
				icon: null,
				name: "Command Center", 
				description: ""
			}
		];
		unit.controlTree = [
			{
				key : K.B,
				action : controller.SetTree(buildActions),
				icon: null,
				name: "Build",
				description: ""
			},
			{
				key : K.G,
				action : controller.SetPending(Tasks.Gather),
				icon: null,
				name: "Gather", 
				description: ""
			},
			{
				key : K.D,
				action : controller.SetPending(Tasks.Deliver),
				icon: hxd.Res.treeTexture,
				name: "Deliver", 
				description: ""
			}
        ];
        unit.smartTask = Tasks.WorkerSmart;
        
        return unit;
	}
	public static function Marine (controller : Controller) {
		var stats = new UnitStats();
		stats.cost = {minerals: 50, gas: 0};
		stats.attackRange = 10;
		stats.name = "Marine";
		stats.physicsSize = 1.1;

		var unit = new Unit(controller, MarineModel(controller), stats, StatesEnum.Idle);
		unit.animations["idle"] = controller.game.cache.loadAnimation(hxd.Res.Soldier_Idle);
		unit.animations["run"] = controller.game.cache.loadAnimation(hxd.Res.Soldier_Run);
		unit.animations["attack"] = controller.game.cache.loadAnimation(hxd.Res.Soldier_Shoot);
		
		unit.controlTree = [
			{
				key : K.A,
				action : controller.SetPending(Tasks.Attack),
				icon: null,
				name: "Attack", description: ""
			},
			{
				key : K.P,
				action : controller.SetPending(Tasks.Patrol),
				icon: null,
				name: "Patrol", description: ""
			}
		];
        unit.smartTask = Tasks.Move;
        
        return unit;
	}
	public static function Humvee (controller : Controller) {
		var stats = new UnitStats();
		stats.cost = {minerals: 50, gas: 50};
		stats.attackRange = 10;
		stats.physicsSize = 2;
		stats.name = "Humvee";

		var unit = new Unit(controller, HumveeModel(controller), stats, StatesEnum.Idle);
		
		unit.controlTree = [
			{
				key : K.A,
				action : controller.SetPending(Tasks.Attack),
				icon: null,
				name: "Attack", description: ""
			},
			{
				key : K.P,
				action : controller.SetPending(Tasks.Patrol),
				icon: null,
				name: "Patrol", description: ""
			}
		];
        unit.smartTask = Tasks.Move;
        
        return unit;
	}
	public static function Drone (controller : Controller) {
		var stats = new UnitStats();
		stats.cost = {minerals: 50, gas: 50};
		stats.attackRange = 10;
		stats.physicsSize = 2;
		stats.name = "Humvee";

		var unit = new Unit(controller, DroneModel(controller), stats, StatesEnum.Idle);
		
		unit.controlTree = [
			{
				key : K.A,
				action : controller.SetPending(Tasks.Attack),
				icon: null,
				name: "Attack", description: ""
			},
			{
				key : K.P,
				action : controller.SetPending(Tasks.Patrol),
				icon: null,
				name: "Patrol", description: ""
			}
		];
        unit.smartTask = Tasks.Move;
        
        return unit;
	}
	public static function Truck (controller : Controller) {
		var stats = new UnitStats();
		stats.cost = {minerals: 100, gas: 50};
		stats.attackRange = 10;
		stats.physicsSize = 3;
		stats.name = "Truck";

		var unit = new Unit(controller, TruckModel(controller), stats, StatesEnum.Idle);
		
		unit.controlTree = [
			{
				key : K.A,
				action : controller.SetPending(Tasks.Attack),
				icon: null,
				name: "Attack", description: ""
			},
			{
				key : K.P,
				action : controller.SetPending(Tasks.Patrol),
				icon: null,
				name: "Patrol", description: ""
			}
		];
        unit.smartTask = Tasks.Move;
        
        return unit;
	}
	
	public static function Get(unitName : String) {
		switch (unitName) {
			case "Marine":
				return Marine;
			case "SCV":
				return Worker;
			case "Truck":
				return Truck;
			case "Humvee":
				return Humvee;
			case "Drone":
				return Drone;
			case "Barracks":
				return Buildings.Barracks;
			case "CommandCenter":
				return Buildings.CommandCenter;
			case "Factory":
				return Buildings.Factory;
			case "Starport":
				return Buildings.Starport;
		}
		return null;
	}
}