import actions.*;
import h3d.Vector;

class Tasks {
    public static var MoveToClick = function (unit : Unit, controller : Controller) {
        return new Task([
            new Move(controller.position)
        ]);
    }
    public static var Patrol = function (unit : Unit, controller : Controller) {
        return new Task([
            new Move(controller.position),
            new Move(unit.position)
        ], true);
    }
    public static var Attack = function (unit : Unit, controller : Controller) {
        if (controller.hasTarget()) {
            return new Task([
                new Attack(controller.target),
                new Wait(0.1),
                new MoveTarget(controller.target, unit.stats.attackRange)
            ], true);
        }
        else {
            return new Task([
                new Move(controller.position)
            ]);
        }
    }
    public static var Gather = function (unit : Unit, controller : Controller) {
        var dropPoint = Utils.getNearestDropPoint(unit, controller);
        if (dropPoint != null) {
            return new Task([
                new Deliver(dropPoint),
                new Move(dropPoint.position, dropPoint.stats.physicsSize + unit.stats.physicsSize + 1),
                new Gather(controller.target),
                new Wait(0.1),
                new Move(controller.position)
            ], true);
        }
        else {
            return new Task([
                new Debug("No CC!")
            ]);
        }
    }
    public static var Deliver = function (unit : Unit, controller : Controller) {
        return new Task([
            new Deliver(controller.target),
            new Move(controller.position, controller.target.stats.physicsSize)
        ]);
    }
    public static var Build = function (spawnBuilding, controller : Controller = null) {
        return function (unit : Unit, controller : Controller) {
            var building = spawnBuilding(controller);
            return new Task([
                new PlaceBuilding(building, controller.position),
                new Move(controller.position)
            ], false, building.stats.cost);
        }
    }
    public static var Train = function (spawnUnit, offset : Vector) {
        return function (unit : Unit, controller : Controller) {
            var trainedUnit = spawnUnit(controller);
            return new Task([
                new TrainUnit(trainedUnit, offset),
            ], trainedUnit.stats.cost);
        }
    }
    public static var Debug = function (unit : Unit, controller : Controller) {
        return new Task([
            new Debug("Hello!")
        ]);
    }
}