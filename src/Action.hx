import h3d.anim.Animation;

enum ActionState {
    InProgress; 
    Complete;
    Failed;
}

class Action {
    public var state : ActionState;
    public var unit : Unit;
    public var controller : Controller;

    public function start(unit : Unit, controller:Controller) {
        state = ActionState.InProgress;
        this.unit = unit;
        this.controller = controller;
    }

    public function update(dt:Float) {
    }
}