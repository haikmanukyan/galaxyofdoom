import h3d.scene.Interactive;
import ResourceNodes.RecourceNodes;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

import h3d.prim.Cube;
import h3d.scene.Mesh;
import h3d.Vector;
import h3d.scene.Object;
import h3d.prim.ModelCache;

class Game extends hxd.App 
{
	public var cache : ModelCache;
	var scene : h3d.scene.World;
	var shadow :h3d.pass.DefaultShadowMap;
	var s :Object;
	public var ground : Object;

	public var units : Array<Unit>;
	
	// Physics
	public var world : B2World;
	
	// Testing with Player
	public var player : Player;
	public var controller : GameController;

	public var aiPlayer : Player;
	public var aiController : GameController;

	// UI
	var tf : h2d.Text;

	function initScene() {
		scene = new h3d.scene.World(64, 128, s3d);
		var t = scene.loadModel(hxd.Res.tree);
		var r = scene.loadModel(hxd.Res.rock);
		
		// for( i in 0...100 )
			// world.add(Std.random(2) == 0 ? t : r, Math.random() * 128, Math.random() * 128, 0, 1.2 + hxd.Math.srand(0.4), hxd.Math.srand(Math.PI));
		scene.done();

		var groundPrim = new h3d.prim.Cube();
		groundPrim.addNormals();
		groundPrim.addUVs();
		
		ground = new Mesh(groundPrim, s3d);
		ground.getMaterials()[0].color = new Vector(0.4,1,0);
		ground.scaleX = 128;
		ground.scaleY = 128;
		ground.z = -1.01;
		
		new h3d.scene.fwd.DirLight(new Vector( 0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x909090);

		s3d.camera.target.set(64, 64, 0);
		s3d.camera.pos.set(64, 128, 40);

		shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 200;
		shadow.blur.radius= 0;
		shadow.bias *= 0.1;
		shadow.color.set(0.7, 0.7, 0.7);
		
		s3d.camera.zNear = 1;
		s3d.camera.zFar = 1000;
		// new CustomCamera(s3d).loadFromCamera();
	}

	function initControllers() {
		// Human Player
		player = new Player();
		player.resources.minerals = 200;
		controller = new GameController(this, player);
		controller.reset();

		// AI Player
		aiPlayer = new Player();
		aiPlayer.color = new Vector(0,0,1);
		aiPlayer.resources.minerals = 200;

		aiController = new GameController(this, aiPlayer);
		aiController.reset();
	}

	function initUnits() {
		// Resources
		var patch = RecourceNodes.MineralPatch(controller);
		patch.addToScene();
		patch.position = new Vector(72,60,0);

		var patch = RecourceNodes.MineralPatch(controller);
		patch.addToScene();
		patch.position = new Vector(74,64,0);

		var patch = RecourceNodes.MineralPatch(controller);
		patch.addToScene();
		patch.position = new Vector(72,68,0);

		var patch = RecourceNodes.GasGeyser(controller);
		patch.addToScene();
		patch.position = new Vector(72,54,0);

		var patch = RecourceNodes.GasGeyser(controller);
		patch.addToScene();
		patch.position = new Vector(72,78,0);
		
		// Player
		var unit = Units.Worker(controller);
		unit.addToScene();
		unit.position = new Vector(64,64,0);

		// AI
		var unit = Units.Marine(aiController);
		unit.addToScene();
		unit.position = new Vector(32,64,0);

	}

	function initEvents() {
		hxd.Stage.getInstance().addEventTarget(controller.onEvent);
	}

	function initUI() {
		var font : h2d.Font = hxd.res.DefaultFont.get();
		tf = new h2d.Text(font);
		tf.text = "Hello World\nHeaps is great!";
		tf.textAlign = Center;
		tf.x = 150;

		// add to any parent, in this case we append to root
		s2d.addChild(tf);
	}

	function initPhysics() {
		world = new B2World (new B2Vec2 (0, 0), true);
		world.setContactListener(new CollisionHandler());
	}

	override function init() 
	{
		Utils.init(this);
		cache = new ModelCache();
		units = new Array<Unit>();

		initScene();
		initPhysics();
		
		initControllers();
		
		initUnits();
		initUI();

		initEvents();		
	}

	function updateUI(dt : Float) {
		tf.text = 'Minerals: ${player.resources.minerals} Gas: ${player.resources.gas}';
	}

	public function registerUnit(unit : Unit) {
		controller.initInteract(unit.interactive, unit);
		units.push(unit);
	}

	override function update(dt:Float) {
		controller.update(dt);
		aiController.update(dt);
		
		for (unit in units)
			unit.update(dt);
		
		world.step(dt, 2, 10);

		updateUI(dt);
	}
	
	static function main() 
	{
		hxd.Res.initEmbed();
        new Game();
    }
}