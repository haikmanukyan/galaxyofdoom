import Globals.Transition;

class State {
    public var name : String;
    public var tasks : Array<Dynamic>;
    public var transitions : Array<Transition>;

    public function new(name : String = null, tasks: Array<Dynamic> = null, transitions : Array<Transition> = null) {
        this.name = name;
        this.tasks = tasks == null ? new Array<Dynamic>() : tasks;
        this.transitions = transitions == null ? new Array<Transition>() : transitions;
    }
}