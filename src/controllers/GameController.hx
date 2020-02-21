package controllers;

import gamedata.Units;
import hxd.res.Image;
import box2D.dynamics.B2DebugDraw;
import h2d.Mask;
import h2d.Text.Align;
import h2d.Bitmap;
import hxd.Window;
import h2d.Graphics;
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
import Std.int;

class GameController extends GroupController {
    var clickedLMB : Bool;
    var clickedRMB : Bool;
    
    // UI
    var ui : UIDrawer;
    var mDown : Bool;
    var wDown : Bool;
    var wFixX : Float;
    var wFixY : Float;
    var mDownTime :Float;
    var selectionBox : {x:Float,y:Float,w:Float,h:Float};
    public var cameraPanSpeed : Float = 20;
    public var cameraZoomSpeed : Float = 20;
    public var preview : Object;
    var window : Window;
    var noFocus : Bool;

    public override function SetTree (controlTree : Array<ControlNode>) {
        return function() {
            this.controlTree = controlTree;
            ui.drawControlTree(controlTree);
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
    public function new (game : Game, player : Player) {
        super(game, player);
        window = Window.getInstance();

        selectionBox = {x:0,y:0,w:0,h:0};
        selection = new Selection(this);
        
        ui = new UIDrawer(game);
        initNetwork();
    }

    function initNetwork() {
        Network.getInstance().room.onMessage += onMessage;
        Network.getInstance().room.send({ type:"getColor" });
    }

    public function onMessage (message : Dynamic) {
        if (message.type == "color") {
            trace(message.color);
            player.color = Vector.fromColor(message.color);
            initUnits();
        }
    }

    public function initUnits() {
        var unit = Units.Worker(this);
        unit.uid = game.network.room.sessionId + "_startingUnit";
        unit.addToScene(new Vector(64,64,0));
        unit.initNetwork();
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

        i.onPush = function (e : Event) {
            target = unit;
        }

        i.onClick = function (e : Event) {
            if (e.button == 0) {
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
            }
        }
    }

    public override function selectUnits(units : Array<Unit>) {
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

        ui.drawSelection(selection);
        ui.drawControlTree(controlTree);
    }

    public override function reset() {
        controlTree = root;
        pendingTask = null;
        preview.remove();
    }
    public override function update (dt : Float) {
        // Camera movement
        updateCamera(dt);
        updateControls(dt);
        
        if (preview != null) {
            preview.setPosition(position.x, position.y, position.z);
        }

        clickedLMB = false;
        clickedRMB = false;
        // target = null;
        if (mDown) mDownTime += dt;
    }

    function updateControls(dt : Float) {
        // Escape behaviour
        if (K.isDown(K.ESCAPE)) {
            if (pendingTask == null) selectUnits([]);
            reset();
            clickedLMB = false;
            clickedRMB = false;
            return;
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
            else if (smartTask != null && selection != null)
                selection.StartTask(smartTask);
        }

        // Other Keys
        if (controlTree != null) {
            for (control in controlTree) {
                if (K.isPressed(control.key)) {
                    control.action();
                }
            }
        }
    }

    function updateCamera(dt : Float) {
        if (K.isPressed(K.SPACE)) {
            // Reset Camera
        }
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
        var camSpeed = 2;
        var scrollArea = 100;
        if (noFocus) return;
        return;

        if (window.mouseX > window.width - scrollArea) {
            game.s3d.camera.pos.x += camSpeed * dt * (window.mouseX - window.width + scrollArea);
            game.s3d.camera.target.x += camSpeed * dt * (window.mouseX - window.width + scrollArea);
        }
        if (window.mouseX < scrollArea) {
            game.s3d.camera.pos.x += -camSpeed * dt * (scrollArea - window.mouseX);
            game.s3d.camera.target.x += -camSpeed * dt * (scrollArea - window.mouseX);
        }
        if (window.mouseY > window.height - scrollArea) {
            game.s3d.camera.pos.y += camSpeed * dt * (window.mouseY - window.height + scrollArea);
            game.s3d.camera.target.y += camSpeed * dt * (window.mouseY - window.height + scrollArea);
        }
        if (window.mouseY < scrollArea) {
            game.s3d.camera.pos.y += -camSpeed * dt * (scrollArea - window.mouseY);
            game.s3d.camera.target.y += -camSpeed * dt * (scrollArea - window.mouseY);
        }
    }
    function getUnits() {
        var selectedUnits : Array<Unit> = new Array<Unit>();
        for (unit in game.units) {
           
            if (ui.selectionBoxGraphics.getBounds().contains(new h2d.col.Point(unit.uiX, unit.uiY))) {
                unit.highlight(Hover);
                selectedUnits.push(unit);
            }
        }
        return selectedUnits;
    }
    public function onEvent(e : Event) {
        var clickedUI = ui.checkDeadzone(e.relX, e.relY);
        switch (e.kind) {
            case EFocusLost:
                wDown = false;
                noFocus = true;
            case EFocus:
                noFocus = false;
            case EPush:
                target = null;
                if (e.button == 0 && !clickedUI) {
                    mDown = true;
                    mDownTime = 0;
                    selectionBox.x = e.relX;
                    selectionBox.y = e.relY;
                }
                if (e.button == 1) {

                }
                if (e.button == 2) {
                    wDown = true;
                    wFixX = e.relX;
                    wFixY = e.relY;
                }
            case ERelease:
                if (e.button == 0) {
                    mDown = false;
                    clickedLMB = !clickedUI;
                    ui.selectionBoxGraphics.clear();
                }
                if (e.button == 1) {
                    clickedRMB = !clickedUI;
                }
                if (e.button == 2) {
                    wDown = false;
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
                        ui.drawSelectionBox(selectionBox);
                        selectUnits(getUnits());
                    }
                }
                if (wDown) {
                    game.s3d.camera.pos.x += - 0.1 * (e.relX - wFixX);
                    game.s3d.camera.target.x += - 0.1 * (e.relX - wFixX);

                    game.s3d.camera.pos.y += - 0.1 * (e.relY - wFixY);
                    game.s3d.camera.target.y += - 0.1 * (e.relY - wFixY);

                    wFixX = e.relX;
                    wFixY = e.relY;
                }
            case _:
        }
    }
}