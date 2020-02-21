package controllers;

import Globals.ControlNode;

class GroupController extends Controller {
    var root : Array<ControlNode>;
    var controlTree : Array<ControlNode>;
    
    public var pendingTask : Dynamic;
    public var smartTask : Dynamic;


    public var selection : Selection;

    public override function SetTree (controlTree : Array<ControlNode>) {
        return function() {
            this.controlTree = controlTree;
        }
    }
    public override function SetPending (task : Dynamic, queue = false, preview = null) {
        return function () {
            pendingTask = task;
            queueTask = queue;
        }
    }
    public override function Start(task : Dynamic, queue = false) {
        return function () {
            selection.StartTask(task, queue);
        }
    }
    public function new (game : Game, player : Player) {
        super(game, player);        
    }

    public function selectUnits(units : Array<Unit>) {
        selection.select(units);
        updateSelection();
    }

    public override function updateSelection() {
        if (selection.isControllable) {
            root = selection.getTree();
            controlTree = selection.getTree();
            smartTask = selection.getSmartTask();
        }
        else {
            root = null;
            controlTree = null;
            smartTask = null;
        }
    }

    public override function reset() {
        controlTree = root;
        pendingTask = null;
    }

    public override function update (dt : Float) {
        // Override further
    }
}