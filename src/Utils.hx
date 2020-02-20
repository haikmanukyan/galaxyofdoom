import controllers.Controller;

class Utils {
    static var game : Game;

    public static function init (game : Game) {
        Utils.game = game;
    }

    public static function getNearestDropPoint(unit : Unit, controller : Controller) : Unit {
        for (unit in game.units) {
            if (unit.stats.isDropPoint) {
                return unit;
            }
        }
        return null;
    }

    public static function getEnemiesInRange(unit : Unit, controller : Controller) : Unit {
        for (other in game.units) {
            if (other.stats.isResource) continue;
            
            if (unit.player != other.player && unit.position.distance(other.position) < unit.stats.visionRange) {
                controller.target = other;
                controller.position = other.position;
                return other;
            }
        }
        return null;
    }
}