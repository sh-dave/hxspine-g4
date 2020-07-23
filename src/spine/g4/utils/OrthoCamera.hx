package spine.g4.utils;

import kha.math.*;

class OrthoCamera {
	public final position = new FastVector3(0, 0, 1);
	public var zoom = 5.0;
	public var viewportWidth: Int;
	public var viewportHeight: Int;

	public final projectionView = FastMatrix4.identity();

	final direction = new FastVector3(0, 0, -1);
	final up = new FastVector3(0, 1, 0);
	final near = 0.1;
	final far = 100.0;
	final inverseProjectionView = FastMatrix4.identity();
	final projection = FastMatrix4.identity();
	final view = FastMatrix4.identity();
	final tmp = new FastVector3();

	public function new( viewportWidth: Int, viewportHeight: Int ) {
		this.viewportWidth = viewportWidth;
		this.viewportHeight = viewportHeight;
		update();
	}

	public function update() {
		projection.setFrom(
			FastMatrix4.orthogonalProjection(
				zoom * (-viewportWidth / 2),
				zoom * (viewportWidth / 2),
				zoom * (viewportHeight / 2),
				zoom * (-viewportHeight / 2),
				near, far
		));

		view.setFrom(FastMatrix4.lookAt(position, direction, up));
		projectionView.setFrom(projection.multmat(view));
		// inverseProjectionView.setFrom(projectionView.inverse());
	}

	// screenToWorld (screenCoords: Vector3, screenWidth: number, screenHeight: number) {
	// 	let x = screenCoords.x, y = screenHeight - screenCoords.y - 1;
	// 	let tmp = this.tmp;
	// 	tmp.x = (2 * x) / screenWidth - 1;
	// 	tmp.y = (2 * y) / screenHeight - 1;
	// 	tmp.z = (2 * screenCoords.z) - 1;
	// 	tmp.project(this.inverseProjectionView);
	// 	screenCoords.set(tmp.x, tmp.y, tmp.z);
	// 	return screenCoords;
	// }

	// setViewport(viewportWidth: number, viewportHeight: number) {
	// 	this.viewportWidth = viewportWidth;
	// 	this.viewportHeight = viewportHeight;
	// }
}
