import States.StatesEnum;
import Globals.ControlNode;
import Globals.Resource;
import h3d.scene.Interactive;
import h2d.Graphics;
import box2D.dynamics.B2BodyType;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Body;
import h3d.mat.Pass;
import h3d.pass.Outline;
import Task.TaskState;
import h3d.Vector;
import h3d.anim.Animation;
import h3d.prim.ModelCache;
import h3d.scene.Object;
import h3d.scene.Scene;

enum HighlightMode {
    Hover;
    Select;
    None;
}

class Unit extends Interactable
{
    public static inline var PIXELS_IN_METER:Int = 100;

    // References
    public var game : Game;
    public var player : Player;
    public var ai : Controller;
    public var controller : Controller;
    
    // Actions
    public var task : Task;
    public var state : State;
    public var taskQueue : Array<Dynamic>;
    public var taskLMB : Dynamic;
    public var taskRMB : Dynamic;
    public var controlTree : Array<ControlNode>;
    public var destination : Vector;
    public var stoppingDistance : Float = 1;
    
    // Graphics
    public var model : Object;
    public var moveAnimation : Animation;
    public var resourceModel : Object;
    
    // Other stats
    public var isAlive : Bool;
    public var stats : UnitStats;
    public var carries : Resource;
    
    // Physics
    public var body : B2Body;
    public var size : Float;
    public var bodyType : B2BodyType;

    // UI
    public var g : Graphics;
    public var selectionGraphic : Graphics;
    public var uiX : Float;
    public var uiY : Float;
    public var highlightMode : HighlightMode;
    public var interactive : Interactive;

    @:isVar public var position(get, set) : Vector;

    function initPhysics(bodyType : B2BodyType = DYNAMIC_BODY) {
        var bodyDef = new B2BodyDef ();
		bodyDef.position.set(64, 64);
		bodyDef.type = bodyType;

		var circle = new B2CircleShape(size);
        var fixture = new B2FixtureDef();
		fixture.shape = circle;
        fixture.density = 1;
        fixture.friction = 1;
        fixture.restitution = 1;

		body = game.world.createBody (bodyDef);
        body.createFixture (fixture);
        body.setUserData(this);
    }

    function initUI() {
        g = new Graphics(game.s2d);
        selectionGraphic = new Graphics(game.s2d);
    }

    function get_position() {
        if (isAlive && body != null) {
            var p = body.getPosition();
            return new Vector(p.x, p.y, model.z);
        }
        else
            return new Vector(model.x, model.y, model.z);
    }

    function set_position(newPosition : Vector) {
        body.setPosition(new B2Vec2(newPosition.x, newPosition.y));
        destination = newPosition;
        model.z = 0;
        return position = newPosition;
    }

    public function setDestination (destination : Vector) {
        this.destination = destination;
    }

    public function setCarries(carries : Resource) {
        this.carries = carries;
        if (carries.minerals > 0) {
            resourceModel = game.cache.loadModel(hxd.Res.Cube);
            model.addChild(resourceModel);
            resourceModel.x = -1;
            resourceModel.y = 0;
            resourceModel.scale(0.5);
            resourceModel.getMaterials()[0].color = new Vector(0,0.5,1);
        }
        else if (carries.gas > 0) {
            resourceModel = game.cache.loadModel(hxd.Res.Cube);
            model.addChild(resourceModel);
            resourceModel.x = -1;
            resourceModel.y = 0;
            resourceModel.scale(0.5);
            resourceModel.getMaterials()[0].color = new Vector(0,0.8,0.5);
        }
        else {
            model.removeChild(resourceModel);
        }
    }

    public function new (controller : Controller, model : Object, stats:UnitStats = null, state : StatesEnum = StatesEnum.Passive, bodyType : B2BodyType = DYNAMIC_BODY) {
        game = controller.game;
        player = controller.player;
        this.controller = controller;
        this.ai = new UnitController(this, game, player);
        
        this.bodyType = bodyType;
        this.stats = stats == null ? new UnitStats() : stats;
        this.size = this.stats.physicsSize;
        this.carries = {minerals: 0, gas: 0};
        this.model = model;
        
        destination = position;
        taskQueue = new Array<Task>();
        
        state = state == null ? StatesEnum.Passive : state;
        transitionToState(state);
    }

    public function addToScene() {
        game.s3d.addChild(model);
        initPhysics(bodyType);
        initUI();
        interactive = new h3d.scene.Interactive(model.getCollider(), game.s3d);

        game.registerUnit(this);
        isAlive = true;
    }

    public function highlight(mode : HighlightMode) {
        selectionGraphic.clear();

        switch (mode) {
            case Hover:
                highlightMode = mode;
                selectionGraphic.alpha = 0.3;
                selectionGraphic.lineStyle(3, 0xff0000);
                selectionGraphic.drawEllipse(0,0,40,20);
            case Select:
                highlightMode = mode;
                selectionGraphic.alpha = 0.2;
                selectionGraphic.lineStyle(3, 0x0000ff);
                selectionGraphic.drawEllipse(0,0,40,20);
            case None:
                highlightMode = mode;
                selectionGraphic.clear();
        }
    }

    public function kill() {
        isAlive = false;

        interactive.remove();
        game.world.destroyBody(body);
        game.units.remove(this);
        model.remove();
        g.remove();
        selectionGraphic.remove();
    }

    public function nextTask(controller : Controller = null) {
        if (taskQueue.length > 0) {
            controller = controller == null? this.controller : controller;
            task = taskQueue.pop()(this, controller);
            task.start(this, controller);
        }
    }

    public function queueTask(task : Task) {
        taskQueue.push(task);
    }

    public function startTask(task : Task) {
        if (taskQueue.length > 0) taskQueue = new Array<Task>();
        this.task = task;
        task.start(this, game.controller);
    }

    public function transitionToState(state : StatesEnum) {
        this.state = States.getState(state);
        taskQueue = this.state.tasks.copy();
        nextTask(ai);
    }

    function move(dt:Float) {
        if (!reachedDestination()) {
            var direction = destination.sub(position).getNormalized();
            direction.scale3(stats.movementSpeed);
            
            body.setAwake(true);
            body.setLinearVelocity(new B2Vec2(direction.x, direction.y));

            if (direction.length() > 0)
                model.setDirection(direction);
        }
        else {
            body.setLinearVelocity(new B2Vec2(0,0));
        }
    }

    public function reachedDestination() {
        return (position.distance(destination) < stoppingDistance);
    }

    function updateUI() {
        var projection = game.s3d.camera.project(position.x, position.y, position.z, hxd.Window.getInstance().width, hxd.Stage.getInstance().height);
        uiX = projection.x;
        uiY = projection.y;
        
        if (!stats.isResource) {
            g.clear();
            g.lineStyle(2);
            g.beginFill(0xff0000);
            g.drawRect(-40,-80,80,10);
            g.endFill();
    
            g.beginFill(0x00ff00);
            g.drawRect(-40,-80, 80 * stats.hitPoints / stats.maxHitPoints,10);
            g.endFill();
        }

        g.x = uiX;
        g.y = uiY;
        selectionGraphic.x = uiX;
        selectionGraphic.y = uiY;
    }

    public function update(dt:Float) {       
        if (!isAlive) return;

        if (stats.hitPoints <= 0) {
            kill();
            return;
        }

        move(dt);

        model.x = position.x;
        model.y = position.y;
        model.z = position.z;

        if (task != null) {
            switch  (task.state) {
                case InProgress:
                    task.update(dt);
                case Complete:
                    nextTask();
                case Failed:
                    nextTask();
            }
        }
    
        if (state != null) {
            for (transition in state.transitions){
                if (transition.condition(this, controller)){
                    transitionToState(transition.trueState);
                }
            }
        }

        updateUI();
    }
}