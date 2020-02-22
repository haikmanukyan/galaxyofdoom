import h3d.Vector;
import controllers.Controller;

class Utils {
    static var game : Game;

    public static function arr2vec(arr) : Vector {
        return new Vector(arr[0],arr[1],arr[2]);
    }

    public static function uuid() {
        // Based on https://gist.github.com/LeverOne/1308368
        var uid = new StringBuf(), a = 8;
        uid.add(StringTools.hex(Std.int(Date.now().getTime()), 8));
        while((a++) < 36) {
            uid.add(a*51 & 52 != 0
                ? StringTools.hex(a^15 != 0 ? 8^Std.int(Math.random() * (a^20 != 0 ? 16 : 4)) : 4)
                : "-"
            );
        }
        return uid.toString().toLowerCase();
    }

    public static function init (game : Game) {
        Utils.game = game;
    }

    public static function dumpVec(vec : Vector) {
        return [vec.x, vec.y, vec.z];
    }

    public static function getNearestDropPoint(unit : Unit, controller : Controller) : Unit {
        for (unit1 in game.units) {
            if (unit1.stats.isDropPoint && unit.player == unit1.player) {
                return unit1;
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