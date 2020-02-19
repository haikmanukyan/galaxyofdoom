import h3d.scene.Object;
import h3d.scene.CameraController;

class CustomCamera extends  CameraController {
    override function onEvent( e : hxd.Event ) {

		switch( e.kind ) {
		case EWheel:
			if( hxd.Key.isDown(hxd.Key.CTRL) )
				fov(e.wheelDelta * fovZoomAmount * 2);
			else
				zoom(e.wheelDelta);
		case EPush:
			@:privateAccess scene.events.startDrag(onEvent, function() pushing = -1, e);
			pushing = e.button;
			pushX = e.relX;
			pushY = e.relY;
		case ERelease, EReleaseOutside:
			if( pushing == e.button ) {
				pushing = -1;
				@:privateAccess scene.events.stopDrag();
			}
		case EMove:
			switch( pushing ) {
			case 0:
				if( hxd.Key.isDown(hxd.Key.ALT) )
					zoom(-((e.relX - pushX) +  (e.relY - pushY)) * 0.03);
				else
					rot(e.relX - pushX, e.relY - pushY);
				pushX = e.relX;
				pushY = e.relY;
			case 1:
				var m = 0.001 * curPos.x * panSpeed / 25;
				pan(-(e.relX - pushX) * m, (e.relY - pushY) * m);
				pushX = e.relX;
				pushY = e.relY;
			case 2:
				rot(e.relX - pushX, e.relY - pushY);
				pushX = e.relX;
				pushY = e.relY;
			default:
			}
		default:
		}
	}
}