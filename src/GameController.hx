import Globals;
import Unit.HighlightMode;
import h3d.col.Point;
import h3d.col.Collider;
import h3d.col.Ray;
import hxd.Event;
import h3d.Vector;
import h3d.scene.Object;
import haxe.Constraints.Function;
import hxd.Key in K;

class GameController extends Controller {
    var clickedLMB : Bool;
    public var taskLMB : Dynamic;
    public var defaultTaskLMB : Dynamic;

    var clickedRMB : Bool;
    public var taskRMB : Dynamic;
    
    public var pendingTask : Dynamic;

    var root : Array<ControlNode>;
    var currentTree : Array<ControlNode>;

    // Part of GroupController
    public var selection : Selection;
    
    // UI
    var mDown : Bool;
    var mDownTime :Float;
    var selectionBox : {x:Float,y:Float,w:Float,h:Float};
    var selectionBoxGraphics : h2d.Graphics;
    public var cameraPanSpeed : Float = 20;
    public var cameraZoomSpeed : Float = 20;
    public var preview : Object;

    public function new (game : Game, player : Player) {
        super(game, player);
        
        selectionBox = {x:0,y:0,w:0,h:0};
        selectionBoxGraphics = new h2d.Graphics(game.s2d);
    }

    public function onEvent(e : Event) {
        // trace("Global", e.relX, e.relY, e.relZ);

        switch (e.kind) {
            case EPush:
                if (e.button == 0) {
                    mDown = true;
                    mDownTime = 0;
                    selectionBox.x = e.relX;
                    selectionBox.y = e.relY;
                }
                if (e.button == 1) {

                }
            case ERelease:
                if (e.button == 0) {
                    mDown = false;
                    clickedLMB = true;
                    selectionBoxGraphics.clear();
                }
                if (e.button == 1) {
                    clickedRMB = true;
                }
            case EWheel:
                var dist = game.s3d.camera.pos.sub(game.s3d.camera.target);
                dist.scale3(1 + e.wheelDelta / cameraZoomSpeed);
                game.s3d.camera.pos = game.s3d.camera.target.add(dist);
            case EMove:
                var ray = game.s3d.camera.rayFromScreen(e.relX, e.relY);
                var terrain : Collider = game.ground.getCollider();
                var dist = terrain.rayIntersection(ray, true);
                var p = ray.getPoint(dist);
                position = new Vector(p.x, p.y, p.z);

                if (mDown) {
                    if (mDownTime > 0.05) {
                        selectionBox.w = e.relX - selectionBox.x;
                        selectionBox.h = e.relY - selectionBox.y;
                        drawBox();
                        selectUnits(getUnits());
                    }
                }
            case _:
        }
    }

    function getUnits() {
        var selectedUnits : Array<Unit> = new Array<Unit>();
        for (unit in game.units) {
           
            if (selectionBoxGraphics.getBounds().contains(new h2d.col.Point(unit.uiX, unit.uiY))) {
                unit.highlight(Hover);
                selectedUnits.push(unit);
            }
        }
        return selectedUnits;
    }

    function drawBox() {
        selectionBoxGraphics.clear();
        selectionBoxGraphics.alpha = 0.2;

        selectionBoxGraphics.beginFill(0xff0000);

        selectionBoxGraphics.drawRect(selectionBox.x, selectionBox.y, selectionBox.w, selectionBox.h);
        selectionBoxGraphics.endFill();
    }

    public function initInteract( i : h3d.scene.Interactive, unit : Unit) {
        i.onOver = function (e : Event) {
            if (unit.highlightMode != HighlightMode.Select)
                unit.highlight(Hover);    
        }

        i.onOut = function (e :Event) {
            if (unit.highlightMode != HighlightMode.Select)
                unit.highlight(None);
        }

        i.onClick = function (e : Event) {
            if (pendingTask == null) {
                if (K.isDown(K.SHIFT) && selection != null) {
                    if (unit.highlightMode == Select) {
                        selection.removeUnit(unit);
                    }
                    else {
                        selection.addUnit(unit);
                    }
                }
                else if (K.isDown(K.CTRL) && selection != null) {
                    selection.removeUnit(unit);
                }
                else {
                    selectUnits([unit]);
                }
            }
            else {
                target = unit;
            }
        }
    }

    public function selectUnits(units : Array<Unit>) {
        if (units.length == 0 && selection != null) {
            selection.deselect();
            selection = null;
        }
        else {
            setSelection(units);
        }
    }

    function setSelection(units : Array<Unit>) {
        if (this.selection != null)
            this.selection.deselect();
        
        this.selection = new Selection(units, this);

        if (this.selection.isControllable) {
            root = selection.getTree();
            currentTree = selection.getTree();
            taskRMB = selection.getRMB();
            taskLMB = selection.getLMB();    
        }
        else {
            root = null;
            currentTree = null;
            taskLMB = null;
            taskRMB = null;
        }
    }

    public function setRoot(controlTree) {
        root = controlTree;
    }

    public override function reset() {
        currentTree = root;
        pendingTask = null;
        preview.remove();
    }

    public override function SetTree (controlTree : Array<ControlNode>) {
        return function() {
            currentTree = controlTree;
        }
    }

    public override function SetPending (task : Dynamic, queue = false, preview = null) {
        return function () {
            pendingTask = task;
            queueTask = queue;
            if (preview != null) {
                this.preview = preview;
                game.s3d.addChild(preview);
            }
        }
    }

    public override function Start(task : Dynamic, queue = false) {
        return function () {
            selection.StartTask(task, queue);
        }
    }
    
    public override function update (dt : Float) {
        // Camera movement
        updateCamera(dt);
        
        // Escape behaviour
        if (K.isDown(K.ESCAPE)) {
            if (pendingTask == null) selection = null;
            reset();
            clickedLMB = false;
            clickedRMB = false;
            return;
        }

        if (preview != null) {
            preview.setPosition(position.x, position.y, position.z);
        }

        // Mouse Controls
        if (clickedLMB) {
            if (pendingTask != null && selection != null) {
                selection.StartTask(pendingTask);
                if (!K.isDown(K.SHIFT))
                    reset();
            }
            else {
                // controlledUnit = null;
            }
        }
        if (clickedRMB) {
            if (pendingTask != null) {
                reset();
            }
            else if (taskRMB != null && selection != null)
                selection.StartTask(taskRMB);
        }

        // Other Keys
        if (currentTree != null) {
            for (control in currentTree) {
                if (K.isPressed(control.key)) {
                    control.action();
                }
            }
        }

        clickedLMB = false;
        clickedRMB = false;
        target = null;
        if (mDown) mDownTime += dt;
    }

    function updateCamera(dt : Float) {
        if (K.isDown(K.UP)) {
            game.s3d.camera.pos.y += - dt * cameraPanSpeed;
            game.s3d.camera.target.y += - dt * cameraPanSpeed;
        }
        else if (K.isDown(K.LEFT)) {
            game.s3d.camera.pos.x += - dt * cameraPanSpeed;
            game.s3d.camera.target.x += - dt * cameraPanSpeed;
        }
        else if (K.isDown(K.DOWN)) {
            game.s3d.camera.pos.y += dt * cameraPanSpeed;
            game.s3d.camera.target.y += dt * cameraPanSpeed;
        }
        else if (K.isDown(K.RIGHT)) {
            game.s3d.camera.pos.x += dt * cameraPanSpeed;
            game.s3d.camera.target.x += dt * cameraPanSpeed;
        }
    }
}