import haxe.Timer;
import controllers.Controller;
import hxd.Key;
import gamedata.Units;
import hxd.Window;
import h3d.scene.Interactive;
import h3d.prim.Cube;
import h3d.scene.Mesh;
import h3d.Vector;
import h3d.scene.Object;
import h3d.prim.ModelCache;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

import controllers.GameController;
import controllers.GhostController;
import gamedata.ResourceNodes.RecourceNodes;


class Game extends hxd.App 
{
	public var gameReady: Bool = false;
	public var cache : ModelCache;
	var scene : h3d.scene.World;
	var shadow :h3d.pass.DefaultShadowMap;
	var s :Object;
	public var ground : Object;

	public var units : Array<Unit>;
	
	public var window : Window;

	// Physics
	public var world : B2World;
	
	// Testing with Player
	public var player : Player;
	public var controller : GameController;
	public var passiveController : Controller;

	public var aiPlayer : Player;
	public var aiController : GhostController;
	public var network:Network;

	// UI
	var tf : h2d.Text;

	function initScene() {
		scene = new h3d.scene.World(64, 128, s3d);
		
		var groundPrim = new h3d.prim.Cube();
		groundPrim.addNormals();
		groundPrim.addUVs();
		ground = new Mesh(groundPrim, s3d);
		// ground = cache.loadModel(hxd.Res.Cube);
		ground.getMaterials()[0].color = new Vector(0.4,1,0);
		ground.scaleX = 128;
		ground.scaleY = 128;
		ground.z = -1.01;
		
		// ground = cache.loadModel(hxd.Res.Terrain);
		
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

	function initMap() {
		passiveController = new Controller(this, null);

		var minerals = [
			new Vector(18,52),
			new Vector(16,64),
			new Vector(18,76),
			new Vector(110,52),
			new Vector(112,64),
			new Vector(110,76),
		];
		var gas = [
			new Vector(24,36),
			new Vector(24,92),
			new Vector(104,36),
			new Vector(104,92),
		];

		for (pos in minerals) {
			var patch = RecourceNodes.MineralPatch(passiveController);
			patch.addToScene(pos);
		}
		for (pos in gas) {
			var patch = RecourceNodes.GasGeyser(passiveController);
			patch.addToScene(pos);
		}
	}

	function initEvents() {
		Window.getInstance().addEventTarget(controller.onEvent);
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
		network = Network.getInstance();
		network.join();
	}

	function startGame() {
		initScene();
		initPhysics();
		initNetwork();
		
		initGameController();
		initMap();
		initUI();

		initEvents();	
		
		gameReady = true;
	}

	var players : Array<Player>;
	var controllers : Array<Controller>;

	function initNetwork() {
		players = new Array<Player>();
		controllers = new Array<Controller>();

		network.room.onMessage += onMessage;
		network.room.send({
			"type":"getPlayers"
		});
	}

	function initNetworkPlayer(playerId : String, playerColor : Int) {
		var ghostPlayer : Player = new Player();
		ghostPlayer.color = Vector.fromColor(playerColor);
		var ghost : GhostController = new GhostController(this, ghostPlayer, playerId);
		controllers.push(ghost);
	}

	function initNetworkPlayers(playerIds : Array<String>, playerColors : Array<Int>) {		
		for (i in 0 ... playerIds.length) {
			if (playerIds[i] != network.room.sessionId) {
				initNetworkPlayer(playerIds[i], playerColors[i]);
			}
		}
	}

	function onNewPlayer(uid : String, color : Int) {
		var timer : Timer = new Timer(100);
		timer.run = function () { initNetworkPlayer(uid, color); timer.stop();}		
	}

	public function getUnitById(uid : String) {
		for (unit in units) 
			if (unit.uid == uid)
				return unit;
		return null;
	}

	function initGameController() {
		// Human Player
		player = new Player();
		player.resources.minerals = 200;
		controller = new GameController(this, player);
		controller.reset();
	
		players.push(player);
		controllers.push(controller);
	}

	function onMessage(message : Dynamic) {
		switch (message.type) {
			case "playerList":
				trace(message.players);
				initNetworkPlayers(message.players, message.colors);
			case "newPlayer":
				onNewPlayer(message.uid, message.color);
		}
	}

	function updateUI(dt : Float) {
		tf.text = 'Minerals: ${player.resources.minerals} Gas: ${player.resources.gas}';
	}

	public function registerUnit(unit : Unit) {
		controller.initInteract(unit.interactive, unit);
		units.push(unit);
	}

	override function update(dt:Float) {
		if (network.room == null) return;
		if (!gameReady) {
			trace("CONNECTION ESTABLISHED!");
			startGame();
			gameReady = true;
		}

		for (controller in controllers) {
			controller.update(dt);
		}
		
		for (unit in units) {
			unit.update(dt);
		}
		
		world.step(dt, 2, 10);
		world.drawDebugData();

		if (Key.isPressed(Key.N)) {
			network.join();
		}

		updateUI(dt);
	}
	
	static function main() 
	{
		hxd.Res.initEmbed();
        new Game();
    }
}