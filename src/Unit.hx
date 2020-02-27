import h2d.Graphics;
import hxd.Window;
import h3d.Vector;
import hxd.res.Image;
import h3d.scene.Interactive;
import h3d.mat.Pass;
import h3d.pass.Outline;
import h3d.anim.Animation;
import h3d.prim.ModelCache;
import h3d.scene.Scene;
import h3d.scene.Object;

import box2D.dynamics.B2BodyType;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Body;

import gamedata.States;
import gamedata.States.StatesEnum;
import controllers.UnitController;
import controllers.Controller;
import Globals.ControlNode;
import Globals.Resource;
import Task.TaskState;
import gamedata.UnitStats;
import statemachine.State;
import network.Network;

enum HighlightMode {
    Hover;
    Select;
    None;
}

class Unit
{
    public static inline var PIXELS_IN_METER:Int = 100;

    // References
    public var game : Game;
    public var player : Player;
    public var ai : Controller;
    public var controller : Controller;
    
    // Shareable
    public var uid: String;
    public var isAlive : Bool;
    public var destination : Vector;
    public var task : Task;
    public var state : State;
    public var stats : UnitStats;
    public var carries : Resource;
    
    // PRivate
    public var taskQueue : Array<Dynamic>;
    public var smartTask : Dynamic;
    public var controlTree : Array<ControlNode>;
    public var stoppingDistance : Float = 1;
    
    // Graphics
    public var display: Object;
    public var model : Object;
    public var icon : Image;
    public var portrait : Image;
    public var resourceModel : Object;
    public var animations : Map<String, Animation>;
    public var currentAnimation : String;
    
    // Physics
    public var body : B2Body;
    public var size : Float;
    public var bodyType : B2BodyType;

    // UI
    public var g : Graphics;
    public var uiX : Float;
    public var uiY : Float;
    public var highlightMode : HighlightMode;
    public var interactive : Interactive;
    public var selectionGraphic : Object;

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
        
        selectionGraphic = game.cache.loadModel(hxd.Res.Selector);
        // selectionGraphic.scale(0.01);
        selectionGraphic.setScale(0.006 * stats.physicsSize);   }

    function get_position() {
        if (isAlive && body != null) {
            var p = body.getPosition();
            return new Vector(p.x, p.y, display.z);
        }
        else
            return new Vector(display.x, display.y, display.z);
    }

    function set_position(newPosition : Vector) {
        body.setPosition(new B2Vec2(newPosition.x, newPosition.y));
        destination = newPosition;
        display.z = 0;
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
        uid = Utils.uuid();
        animations = new Map<String, h3d.anim.Animation>();
        
        this.controller = controller;
        this.ai = new UnitController(this, game, player);
        
        this.bodyType = bodyType;
        this.stats = stats == null ? new UnitStats() : stats;
        this.size = this.stats.physicsSize;
        this.carries = {minerals: 0, gas: 0};
        this.model = model;
        display = new Object();
        display.addChild(model);
        
        destination = position;
        taskQueue = new Array<Task>();
        
        state = state == null ? StatesEnum.Passive : state;
        transitionToState(state);
    }

    public function initNetwork() {
        game.network.room.send({
            type:"newUnit",
            uid:uid,
            unitName:stats.name,
            position: [position.x, position.y, position.z]
        });
    }

    public function addToScene(position : Vector = null) {
        if (position == null) position = new Vector();

        game.s3d.addChild(display);
        initPhysics(bodyType);
        initUI();

        this.position = position;

        interactive = new h3d.scene.Interactive(model.getCollider(), game.s3d);
        interactive.enableRightButton = true;

        game.registerUnit(this);
        isAlive = true;
    }

    public function highlight(mode : HighlightMode) {
        display.removeChild(selectionGraphic);

        switch (mode) {
            case Hover:
                highlightMode = mode;
                display.addChild(selectionGraphic);
            case Select:
                highlightMode = mode;
                display.addChild(selectionGraphic);
            case None:
                highlightMode = mode;
                display.removeChild(selectionGraphic);
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
            startTask(taskQueue.pop()(this, controller));
        }
        else {
            task = null;
        }
    }

    public function queueTask(task : Task) {
        taskQueue.push(task);
    }

    public function startTask(task : Task) {
        this.task = task;
        task.start(this, game.controller);

        if (!ai.isGhost) {
            Network.SendUnitCommand(uid, task);
        }
    }

    public function transitionToState(state : StatesEnum) {
        this.state = States.getState(state);
        taskQueue = this.state.tasks.copy();
        nextTask(ai);
    }

    function updatePosition(dt:Float) {
        if (!reachedDestination()) {
            playAnimation("run");

            var direction = destination.sub(position).getNormalized();
            direction.scale3(stats.movementSpeed);
            
            body.setAwake(true);
            body.setLinearVelocity(new B2Vec2(direction.x, direction.y));

            if (direction.length() > 0)
                display.setDirection(direction);
        }
        else {
            body.setLinearVelocity(new B2Vec2(0,0));
            setDestination(position);
            if (currentAnimation == "run")
                playAnimation("idle");  
        }
    }

    public function playAnimation(animationName : String, forceRestart : Bool = false) {
        if (currentAnimation == animationName && !forceRestart) return;
        if (animations.exists(animationName)) {
            model.playAnimation(animations[animationName]);
        }
        currentAnimation = animationName;
    }

    public function reachedDestination(destination = null, stoppingDistance = null) {
        destination = destination == null ? this.destination : destination;
        stoppingDistance = stoppingDistance == null ? this.stoppingDistance : stoppingDistance;
        return (position.distance(destination) <= stoppingDistance);
    }

    function updateUI() {
        var projection = game.s3d.camera.project(position.x, position.y, position.z, Window.getInstance().width, Window.getInstance().height);
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
    }

    public function update(dt:Float) {       
        if (!isAlive) return;

        if (stats.hitPoints <= 0) {
            kill();
            return;
        }

        updatePosition(dt);

        display.x = position.x;
        display.y = position.y;
        display.z = position.z;

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

        ai.update(dt);
        updateUI();
    }
}