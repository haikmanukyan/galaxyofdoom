package physics;

import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;

class CollisionHandler extends  B2ContactListener {
	public override function beginContact(contact : B2Contact) {
		var fa = contact.getFixtureA();
        var fb = contact.getFixtureB();
        
        var unitA : Unit = fa.getBody().getUserData();
        var unitB : Unit = fb.getBody().getUserData();
        
        if (unitA == null || unitB == null) return;

        if (unitA.reachedDestination()) {
            unitB.destination = unitB.position;
        }
        else if (unitB.reachedDestination()) {
            unitA.destination = unitA.position;
        }
	} 
}