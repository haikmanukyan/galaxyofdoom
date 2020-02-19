enum StatesEnum {
    Passive;
    Idle;
    Aggro;
}


class States {  
    static var Passive : State = new State("passive", [],[]);
    static var Aggro : State = new State("aggro", [Tasks.Attack],
    [
        {
            condition: function (unit: Unit, controller : Controller) {
                return !unit.ai.hasTarget();
            },
            trueState: StatesEnum.Idle
        }
    ]);
    static var Idle : State = new State("idle", [],
    [
        {
            condition : function (unit: Unit, controller : Controller) {
                return Utils.getEnemiesInRange(unit, unit.ai) != null;
            },
            trueState : StatesEnum.Aggro
        }
    ]);     

    public static function getState(state : StatesEnum){
        switch (state) {
            case Passive:
                return Passive;
            case Idle:
                return Idle;
            case Aggro:
                return Aggro;
            case _:
                return Passive;
        }
    }
}