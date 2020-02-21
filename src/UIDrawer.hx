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

class UIDrawer {
    // UI
    var game : Game;
    var debugDraw : B2DebugDraw;
    var mDown : Bool;
    var wDown : Bool;
    var font : h2d.Font = hxd.res.DefaultFont.get();
    var wFixX : Float;
    var wFixY : Float;
    var mDownTime :Float;
    public var cameraPanSpeed : Float = 20;
    public var cameraZoomSpeed : Float = 20;
    public var preview : Object;
    var window : Window;
    
    var minimapMask : Mask;
    var minimapDisplay : Graphics;
    
    public var selectionBoxGraphics : h2d.Graphics;
    var controlTreeDisplay : Graphics;
    var selectionDisplay : Graphics;
    
    var uiMask : h2d.Object;
    var noFocus : Bool;

    public function new (game : Game) {
        this.game = game;
        window = Window.getInstance();
        
        init();
        window.addResizeEvent(onResize);
    }

    public function init() {
        if (uiMask != null) uiMask.remove();
        if (controlTreeDisplay != null) controlTreeDisplay.removeChildren();
        if (selectionDisplay != null) selectionDisplay.removeChildren();

        uiMask = new h2d.Object(game.s2d);

        if (minimapDisplay == null){
            minimapDisplay = new Graphics(game.s2d);
    
            debugDraw = new B2DebugDraw();
            debugDraw.setFlags (B2DebugDraw.e_shapeBit);
            debugDraw.setDrawScale(2);
    
            game.world.setDebugDraw(debugDraw);
            debugDraw.setSprite(minimapDisplay);
        }
        
        var stageW = window.width;
        var stageH = window.height;
        
        minimapDisplay.y = stageH - 200;
        uiMask.alpha = 0.5;
        var W = 300, H = 200, H2 = 180, H3 = 50;
        var r1 : Graphics = new Graphics(uiMask);
        var r2 : Graphics = new Graphics(uiMask);
        var r3 : Graphics = new Graphics(uiMask);
        var r4 : Graphics = new Graphics(uiMask);
        
        r1.beginFill(0x111100);
        r1.drawRect(stageW - W, stageH - H, W, H);
        r1.endFill();
        r2.beginFill(0x111100);
        r2.drawRect(0, stageH - H, W, H);
        r2.endFill();
        r3.beginFill(0x111100);
        r3.drawRect(0, stageH - H2, stageW, H2);
        r3.endFill();
        r4.beginFill(0x111100);
        r4.drawRect(0, 0, stageW, H3);
        r4.endFill();

        selectionDisplay = new Graphics(game.s2d);
        selectionBoxGraphics = new Graphics(game.s2d);
        controlTreeDisplay = new Graphics(game.s2d);
    }

    public function draw (selection : Selection, controlTree : Array<ControlNode>) {
        drawSelection(selection);
        drawControlTree(controlTree);
    }

    function drawButton(x : Float, y : Float, size : Int, icon : Image, text : String) {
        var button = new Graphics();
        
        var tile : h2d.Tile;
        var bitmap : Bitmap;
        if (icon != null) {
            tile = icon.toTile();
            tile.setSize(size, size);
            bitmap = new h2d.Bitmap(tile, button);
        }
        else {
            bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0xff0000,size,size), button);
        }
        bitmap.x = -size / 2;
        bitmap.y = -size / 2;
        
        var tf = new h2d.Text(font,button);
        tf.maxWidth = size;
		tf.text = text;
        tf.textAlign = Align.Center;
        tf.x = -size / 2;
        tf.y = -tf.font.size / 2;
        
        return [button,bitmap];
    }

    function drawControlButton(task : ControlNode, x : Float, y : Float, size : Int) {
        var button = drawButton(x, y, size, task.icon, task.name);
        controlTreeDisplay.addChild(button[0]);
        button[0].x = x;
        button[0].y = y;
        
        var i = new h2d.Interactive(size, size, button[1]);
        i.onOver = function (e : Event) {
            button[0].scaleX = 1.1;
            button[0].scaleY = 1.1;
        }

        i.onOut = function (e : Event) {
            button[0].scaleX = 1;
            button[0].scaleY = 1;
        }

        i.onClick = function (e : Event) {
            task.action();
        }
    }

    function drawUnitButton(unit : Unit, selection : Selection, x, y, size : Int, active : Bool = false) {
        var button = drawButton(x, y, size, unit.icon, unit.stats.name);
        selectionDisplay.addChild(button[0]);
        button[0].x = x;
        button[0].y = y;
        
        var i = new h2d.Interactive(size, size, button[1]);
        if (active) {
            button[0].setScale(1.1);
        }        
        i.onOver = function (e : Event) {
            button[0].setScale(1.1);
        }
        i.onOut = function (e : Event) {
            if (!active) {
                button[0].setScale(1);
            }
        }
        i.onClick = function (e : Event) {
            if (selection != null)
                selection.setActive(unit);
        }
    } 

    public function drawSelection (selection : Selection) {
        var idx = 0, i = 0, j = 0;
        var W = 4, H = 3;
        var size = 50;
        selectionDisplay.removeChildren();

        if (selection != null) {
            for (unit in selection.units) {
                i = int(idx / W);
                j = idx % W;
                idx += 1;

                drawUnitButton(unit, selection, 350 + size * j, window.height - 150 + size * i, size, unit == selection.activeUnit);
            }
        }
    }

    public function drawControlTree (controlTree : Array<ControlNode>) {
        var size = 64;
        var W = 4, H = 3;
        var idx:Int = 0, i:Int, j:Int;

        var x = window.width - 250;
        var y = window.height - 150;
        controlTreeDisplay.removeChildren();

        if (controlTree != null) {
            for (task in controlTree) {
                i = int(idx / W);
                j = idx % W;
                idx += 1;
    
                drawControlButton(task, x + size * j, y + size * i, size - 8);    
            }
        }
    }

    public function drawSelectionBox(selectionBox : {x:Float,y:Float,w:Float,h:Float}) {
        selectionBoxGraphics.clear();
        selectionBoxGraphics.alpha = 0.2;

        selectionBoxGraphics.beginFill(0xff0000);

        selectionBoxGraphics.drawRect(selectionBox.x, selectionBox.y, selectionBox.w, selectionBox.h);
        selectionBoxGraphics.endFill();
    }
    
    public function checkDeadzone(x:Float, y:Float) {
        for (child in uiMask) {
            if (child.getBounds().contains(new h2d.col.Point(x,y)))
                return true;
        }

        return false;
    }

    function onResize () {
        init();
    }
}