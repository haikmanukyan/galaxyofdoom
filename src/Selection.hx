import controllers.GroupController;
import gamedata.Tasks;
import actions.Move;
import network.LobbyState;
import io.colyseus.Room;
import controllers.GameController;
import Unit.HighlightMode;

class Selection {
    public var controller : GroupController;
    public var units : Array <Unit>;
    public var activeIdx : Int;
    public var activeUnit : Unit;

    public var isControllable : Bool;
    var room : Room<LobbyState>;

    public function new (controller : GameController) {
        this.controller = controller;
        units = new Array<Unit>();
    }

    public function setActive(unit : Unit) {
        activeIdx = units.indexOf(unit);
        activeUnit = unit;
        controller.updateSelection();
    }

    public function select(units : Array<Unit>) {
        room = Network.getInstance().room;
        deselect();

        var remove : Array<Unit> = new Array<Unit>();
        var removeBuildings = false;
        var removeResources = false;
        var removeOther = false;

        for (unit in units) {
            if (!unit.stats.isBuilding && !unit.stats.isResource) {
                removeBuildings = true;
            }
            if (!unit.stats.isResource) {
                removeResources = true;
            }
            if (unit.player == controller.player) {
                removeOther = true;
            }
        }

        
        isControllable = removeOther;

        for (unit in units) {
            if (removeBuildings && unit.stats.isBuilding) {
                remove.push(unit);
            }
            if (unit.player != controller.player && removeOther) {
                remove.push(unit);
            }
            if (removeResources && unit.stats.isResource) {
                remove.push(unit);
            }
        }

        for (unit in remove){
            units.remove(unit);
            unit.highlight(None);
        }
        
        for (unit in units) {
            unit.highlight(Select);
        }
        this.units = units;
        activeIdx = 0;
        if (units.length > 0)
            activeUnit = units[activeIdx];

        controller.updateSelection();
    }

    public function deselect() {
        for (unit in units) {
            unit.highlight(None);
        }
    }

    public function addUnit(unit : Unit) {
        this.units.push(unit);
        unit.highlight(Select);
    }

    public function removeUnit(unit : Unit) {
        this.units.remove(unit);
        unit.highlight(None);
    }

    public function getTree() {
        if (units.length > 0) {
            return units[activeIdx].controlTree;
        }
        else {
            return null;
        }
    }

    public function getSmartTask() {
        if (units.length > 0) {
            return units[activeIdx].smartTask;
        }
        else {
            return null;
        }
    }

    public function dump() {
        var arr:Array<String> = new Array<String>();
        for (unit in units) {
            arr.push(unit.uid);
        }
        return arr;
    }

    public function selectIds(unitIds : Array<String>) {
        var units = new Array<Unit>();
        for (id in unitIds)
            units.push(controller.game.unitMap[id]);
        select(units);
    }

    public function StartTask(taskSpawner, queue : Bool = false) {
        for (unit in units) {   
            var task = taskSpawner(unit, controller);
            unit.startTask(task);
            
            if (room != null) { 
                Network.getInstance().room.send({
                    type: "command",
                    unitIds: dump(),
                    task: task.dump()
                });
            }
        }
    }
}