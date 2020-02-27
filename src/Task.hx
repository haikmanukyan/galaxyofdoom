import actions.Play;
import actions.Wait;
import actions.MoveTarget;
import actions.Attack;
import actions.Debug;
import actions.Move;
import controllers.Controller;
import h3d.scene.Object;
import Globals;
import Action.ActionState;

enum TaskState {
    InProgress;
    Complete;
    Failed;
}

class Task {
    public var actions : Array<Action>;
    public var action : Action;
    public var repeat : Bool;
    public var state : TaskState;
    public var unit : Unit;
    public var controller : Controller;
    public var cost : Resource;

    public var preview : Object = null;
    
    var actionQueue : Array<Action>;

    public function new (actions : Array<Action>, repeat : Bool = false, cost : Resource = null) {
        this.actions = actions;
        this.repeat = repeat;
        this.cost = cost == null ? {minerals: 0, gas: 0} : cost;
    }

    function nextAction(){
        if (actionQueue.length > 0) {
            action = actionQueue.pop();
            action.start(unit, controller);
        }
        else {
            if (repeat) 
                start(unit, controller);
            else 
                state = TaskState.Complete;
        }
    }

    public function start(unit : Unit, controller : Controller) {
        if (unit.player.GetResources(cost)) {
            state = TaskState.InProgress;
            this.unit = unit;
            this.controller = controller;
            actionQueue = actions.copy();
            nextAction();
        }
        else {
            trace("FAiled!");
            state = Failed;
        }
    } 
    
    public function stop() {
        state = TaskState.Complete;
    }

    public function update(dt : Float) {
        switch (action.state)
        {
            case InProgress:
                action.update(dt);
            case Complete:
                nextAction();
            case Failed:
                state = Failed;
        }
    }

    public function dump() {
        var actionsDump = new Array();
        for (action in actions)
            actionsDump.push(action.dump());
        return {
            actions:actionsDump,
            repeat: repeat
        }
    }

    public static function fromData(task : Dynamic, controller : Controller) {
        var actions : Array<Action> = new Array<Action>();
        var action : Action = new Debug("Not Implemented!");
        var actionsArray : Array<Dynamic> = task.actions;

        for (actionData in actionsArray) {
            switch (actionData.type) {
                case "Move":
                    action = new Move(Utils.arr2vec(actionData.destination), actionData.stoppingDistance);
                    
                case "MoveTarget":
                    var target = controller.game.getUnitById(actionData.target);
                    if (target != null)
                        action = new MoveTarget(controller.game.getUnitById(actionData.target), actionData.stoppingDistance);

                case "Attack":
                    var target = controller.game.getUnitById(actionData.target);
                    if (target != null) 
                        action = new Attack(target, actionData.amount);

                case "Wait":
                    action = new Wait(actionData.amount);

                case "Play":
                    action = new Play(actionData.animationName);
            }

            actions.push(action);
        }

        trace(task.actions);
        var newTask :Task = new Task(actions, task.repeat);
        return newTask;
    }
}