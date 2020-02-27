package actions;

import Action.ActionState;
import haxe.Timer;

class Wait extends Action {
    var startTime : Float;
    var currentTime : Float;
    var time : Float;
    
    public function new (time : Float) {
        startTime = haxe.Timer.stamp();
        this.time = time;
    }

    public override function update(dt : Float) {
        currentTime = haxe.Timer.stamp();
        if (currentTime - startTime > time)
            state = ActionState.Complete;
    }

    public override function dump() : Dynamic {
        return {
            type: "Wait",
            amount: time
        };
    }
}