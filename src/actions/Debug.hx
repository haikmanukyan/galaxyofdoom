package actions;

import Action.ActionState;

class Debug extends Action {
    var text : String;

    public function new (text : String){
        this.text = text;
    }

    public override function update(dt : Float){
        trace(text);
        state = ActionState.Complete;
    }
}