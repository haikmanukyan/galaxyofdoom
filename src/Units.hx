import States.StatesEnum;
import actions.*;
import h3d.Vector;
import hxd.Key in K;

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

		return model;
	}


    public static function Worker (controller : Controller) {
		var stats = new UnitStats();
		stats.cost = {minerals: 50, gas: 0};
		stats.movementSpeed = 15;
		
		var unit = new Unit(controller, WorkerModel(controller), stats);

        var buildActions = [
			{
				key : K.B,
				action : controller.SetPending(Tasks.Build(Buildings.Barracks), false, Buildings.BarracksModel(controller))
            },
            {
				key : K.C,
				action : controller.SetPending(Tasks.Build(Buildings.CommandCenter), false, Buildings.CommandCenterModel(controller))
			}
		];
		unit.controlTree = [
			{
				key : K.B,
				action : controller.SetTree(buildActions)
			},
			{
				key : K.G,
				action : controller.SetPending(Tasks.Gather)
			},
			{
				key : K.D,
				action : controller.SetPending(Tasks.Deliver)
			}
        ];
        unit.taskRMB = Tasks.MoveToClick;
        
        return unit;
	}
	public static function Marine (controller : Controller) {
		var stats = new UnitStats();
		stats.cost = {minerals: 50, gas: 0};

		var unit = new Unit(controller, MarineModel(controller), stats, StatesEnum.Idle);
		
		unit.controlTree = [
			{
				key : K.A,
				action : controller.SetPending(Tasks.Attack)
			},
			{
				key : K.P,
				action : controller.SetPending(Tasks.Patrol)
			}
		];
        unit.taskRMB = Tasks.MoveToClick;
        
        return unit;
    }
}