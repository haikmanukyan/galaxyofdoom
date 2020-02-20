import Unit.HighlightMode;

class Selection {
    public var controller : GameController;
    public var units : Array <Unit>;
    public var activeIdx : Int;
    public var activeUnit : Unit;

    public var isControllable : Bool;

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

    public function getRMB() {
        if (units.length > 0) {
            return units[activeIdx].taskRMB;
        }
        else {
            return null;
        }
    }

    public function getLMB() {
        if (units.length > 0) {
            return units[activeIdx].taskLMB;
        }
        else {
            return null;
        }
    }

    public function StartTask(task, queue : Bool = false) {
        for (unit in units) {
            unit.startTask(task(unit, controller));
        }

    }
}