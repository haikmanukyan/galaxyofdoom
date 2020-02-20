package controllers;

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
    var ui = {
        
    }
    var debugSprite : Graphics;
    var debugDraw : B2DebugDraw;
    var mDown : Bool;
    var wDown : Bool;
    var wFixX : Float;
    var wFixY : Float;
    var mDownTime :Float;
    var selectionBox : {x:Float,y:Float,w:Float,h:Float};
    var selectionBoxGraphics : h2d.Graphics;
    public var cameraPanSpeed : Float = 20;
    public var cameraZoomSpeed : Float = 20;
    public var preview : Object;
    var window : Window;

    var g :Graphics;
    var font : h2d.Font = hxd.res.DefaultFont.get();
    var minimapMask : Mask;
    var mask : h2d.Object;
    var noFocus : Bool;

    public override function SetTree (controlTree : Array<ControlNode>) {
        return function() {
            currentTree = controlTree;
            drawSelection();
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
        selection = new Selection(this);

        initUI();
        window.addResizeEvent(onResize);
    }
    public function initUI() {
        if (mask != null) mask.remove();
        if (g != null) g.removeChildren();
        if (debugSprite == null){
            debugSprite = new Graphics(game.s2d);
    
            debugDraw = new B2DebugDraw();
            debugDraw.setFlags (B2DebugDraw.e_shapeBit);
            debugDraw.setDrawScale(4);
    
            game.world.setDebugDraw(debugDraw);
            debugDraw.setSprite(debugSprite);
        }

        var stageW = window.width;
        var stageH = window.height;

        
        debugSprite.y = stageH - 350;
        mask = new h2d.Object(game.s2d);
        mask.alpha = 0.1;

        var W = 300, H = 200, H2 = 180, H3 = 50;
        var r1 : Graphics = new Graphics();
        r1.beginFill(0x111100);
        r1.drawRect(stageW - W, stageH - H, W, H);
        r1.endFill();
        var r2 : Graphics = new Graphics();
        r2.beginFill(0x111100);
        r2.drawRect(0, stageH - H, W, H);
        r2.endFill();
        var r3 : Graphics = new Graphics();
        r3.beginFill(0x111100);
        r3.drawRect(0, stageH - H2, stageW, H2);
        r3.endFill();
        var r4 : Graphics = new Graphics();
        r4.beginFill(0x111100);
        r4.drawRect(0, 0, stageW, H3);
        r4.endFill();
        
        mask.addChild(r1);
        mask.addChild(r2);
        mask.addChild(r3);
        mask.addChild(r4);

        selectionBox = {x:0,y:0,w:0,h:0};
        selectionBoxGraphics = new h2d.Graphics(game.s2d);
        g = new Graphics(game.s2d);

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
    public function selectUnits(units : Array<Unit>) {
        selection.select(units);
        
        updateSelection();
    }
    public override function updateSelection() {
        if (selection.isControllable) {
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

        drawSelection();
    }
    public function setRoot(controlTree) {
        root = controlTree;
    }
    public override function reset() {
        currentTree = root;
        pendingTask = null;
        preview.remove();
        drawSelection();
    }
    public override function update (dt : Float) {
        // Camera movement
        updateCamera(dt);
        
        // Escape behaviour
        if (K.isDown(K.ESCAPE)) {
            if (pendingTask == null) selectUnits([]);
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
        // target = null;
        if (mDown) mDownTime += dt;
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
    function updateUI (dt :Float) {
        // var s:Image = new Image();
        // x.setSprite(s);
    }
    function drawButton(task : ControlNode, x, y, size : Int) {
        var button = new Graphics(g);
        var bitmap : Bitmap;
        var tile : h2d.Tile;
        if (task.icon != null) {
            tile = task.icon.toTile();
            tile.setSize(size, size);
            bitmap = new h2d.Bitmap(tile, g);
        }
        else {
            bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0xff0000,size,size), g);
        }
        bitmap.x = -size / 2;
        bitmap.y = -size / 2;
        button.addChild(bitmap);
        button.x = x;
        button.y = y;

        var tf = new h2d.Text(font);
        tf.maxWidth = size;
		tf.text = task.name;
        tf.textAlign = Align.Center;
        tf.x = -size / 2;
        tf.y = -tf.font.size / 2;
		button.addChild(tf);
        
        var i = new h2d.Interactive(size, size, bitmap);
        i.onOver = function (e : Event) {
            button.scaleX = 1.1;
            button.scaleY = 1.1;
        }

        i.onOut = function (e : Event) {
            button.scaleX = 1;
            button.scaleY = 1;
        }

        i.onClick = function (e : Event) {
            trace(task);
            task.action();
        }
    }
    function drawIcon(unit : Unit, x, y, size : Int, active : Bool = false) {
        var button = new Graphics(g);
        var bitmap : Bitmap;
        var tile : h2d.Tile;
        if (unit.icon != null) {
            tile = unit.icon.toTile();
            tile.setSize(size, size);
            bitmap = new h2d.Bitmap(tile, g);
        }
        else {
            bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0xff0000,size,size), g);
        }
        bitmap.x = -size / 2;
        bitmap.y = -size / 2;
        button.addChild(bitmap);
        button.x = x;
        button.y = y;

        var tf = new h2d.Text(font);
        tf.maxWidth = size;
		tf.text = unit.stats.name;
        tf.textAlign = Align.Center;
        tf.x = -size / 2;
        tf.y = -tf.font.size / 2;
        button.addChild(tf);
        
        if (active) {
            button.setScale(1.1);
        }

        var i = new h2d.Interactive(size, size, bitmap);
        i.onOver = function (e : Event) {
            button.setScale(1.1);
        }

        i.onOut = function (e : Event) {
            if (!active) {
                button.setScale(1);
            }
        }

        i.onClick = function (e : Event) {
            if (selection != null)
                selection.setActive(unit);
        }
    }  
    public function drawSelection () {
        var bSize = 64;
        var W = 4, H = 3;
        var idx:Int = 0, i:Int, j:Int;

        var x = window.width - 250;
        var y = window.height - 150;
        g.removeChildren();

        if (currentTree != null) {
            for (task in currentTree) {
                i = int(idx / W);
                j = idx % W;
                idx += 1;
    
                drawButton(task, x + bSize * j, y + bSize * i, bSize - 8);    
            }
        }

        idx = 0; i = 0; j = 0;
        if (selection != null) {
            for (unit in selection.units) {
                i = int(idx / W);
                j = idx % W;
                idx += 1;

                drawIcon(unit, 350 + 50 * j, window.height - 150 + 50 * i, 50, unit == selection.activeUnit);
            }
        }

    }
    function drawBox() {
        selectionBoxGraphics.clear();
        selectionBoxGraphics.alpha = 0.2;

        selectionBoxGraphics.beginFill(0xff0000);

        selectionBoxGraphics.drawRect(selectionBox.x, selectionBox.y, selectionBox.w, selectionBox.h);
        selectionBoxGraphics.endFill();
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
    public function checkDeadzone(x:Float, y:Float) {
        for (child in mask) {
            if (child.getBounds().contains(new h2d.col.Point(x,y)))
                return true;
        }

        return false;
    }
    function onResize () {
        initUI();
    }
    public function onEvent(e : Event) {
        var clickedUI = checkDeadzone(e.relX, e.relY);
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
                    selectionBoxGraphics.clear();
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
                        drawBox();
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