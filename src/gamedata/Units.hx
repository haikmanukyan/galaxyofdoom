package gamedata;

import h3d.Vector;
import hxd.Key in K;

import actions.*;
import gamedata.States.*;
import gamedata.States.StatesEnum;
import controllers.Controller;

class Units {
	public static function WorkerModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Cube);
		model.getMaterials()[0].color = controller.player.color;

		return model;
	}
	public static function MarineModel (controller : Controller) {
		var model = controller.game.cache.loadModel(hxd.Res.Cube);
		model.getMaterials()[0].color = controller.player.color;
		model.scale(1.1);

		var gun2 = controller.game.cache.loadModel(hxd.Res.Cube);
		gun2.setScale(0.2);
		gun2.scaleZ = 0.4;
		gun2.y = -1;
		gun2.x = -0.1;
		gun2.z = 0.5;
		var gun3 = controller.game.cache.loadModel(hxd.Res.Cube);
		gun3.setScale(0.2);
		gun3.scaleZ = 0.5;
		gun3.y = -1;
		gun3.x = -1;
		gun3.z = 0.2;
		var gun = controller.game.cache.loadModel(hxd.Res.Cube);
		gun.setScale(0.1);
		gun.scaleX = 1.2;
		gun.y = -1;
		gun.x = -1;
		gun.z = 0.9;
		model.addChild(gun);
		model.addChild(gun2);
		model.addChild(gun3);

		return model;
	}


    public static function Worker (controller : Controller) {
		var stats = new UnitStats();
		stats.name = "SCV";
		stats.cost = {minerals: 50, gas: 0};
		stats.movementSpeed = 15;
		
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
				icon: hxd.Res.Skeleton01,
				name: "Deliver", 
				description: ""
			}
        ];
        unit.taskRMB = Tasks.WorkerSmart;
        
        return unit;
	}
	public static function Marine (controller : Controller) {
		var stats = new UnitStats();
		stats.cost = {minerals: 50, gas: 0};
		stats.attackRange = 10;
		stats.name = "Marine";

		var unit = new Unit(controller, MarineModel(controller), stats, StatesEnum.Idle);
		
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
        unit.taskRMB = Tasks.MoveToClick;
        
        return unit;
    }
}