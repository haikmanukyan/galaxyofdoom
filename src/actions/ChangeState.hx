package actions;

import Action.ActionState;

class ChangeState extends Action {
    public function new (unit : Unit, state : State) {
        unit.transitionToState(state);
        this.state = ActionState.Complete;
    }
}