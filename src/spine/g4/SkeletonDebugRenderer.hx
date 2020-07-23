package spine.g4;

import spine.attachments.*;
import spine.utils.Color;

class SkeletonDebugRenderer {
	final boneLineColor = new Color(1, 0, 0, 1);
	// boneOriginColor = new Color(0, 1, 0, 1);
	final attachmentLineColor = new Color(0, 0, 1, 0.5);
	final triangleLineColor = new Color(1, 0.64, 0, 0.5);
	// pathColor = new Color().setFromString("FF7F00");
	// clipColor = new Color(0.8, 0, 0, 2);
	final aabbColor = new Color(0, 1, 0, 0.5);

	public var drawBones = true;
	public var drawRegionAttachments = true;
	public var drawBoundingBoxes = true;
	public var drawMeshHull = true;
	public var drawMeshTriangles = true;
	public var drawPaths = true;
	public var drawSkeletonXY = false;
	public var drawClipping = true;

	// var premultipliedAlpha = true;

	public var scale = 1.0;
	public var boneWidth = 2;

	var vertices: Array<Float> = null;

	final bounds = new SkeletonBounds();
	// private temp = new Array<number>();
	// private vertices = Utils.newFloatArray(2 * 1024);
	// private static LIGHT_GRAY = new Color(192 / 255, 192 / 255, 192 / 255, 1);
	// private static GREEN = new Color(0, 1, 0, 1);

	public function new() {
		final vertexSize = 2 + 4;
		vertices = [for (i in 0...vertexSize * 1024) 0];//new Float32Array(vertexSize * 1024);
	}

	public function draw( shapes: ShapeRenderer, skeleton: Skeleton, ignoredBones: Array<String> = null ) {
		final skeletonX = skeleton.x;
		final skeletonY = skeleton.y;
	// 	let srcFunc = this.premultipliedAlpha ? gl.ONE : gl.SRC_ALPHA;
	// 	shapes.setBlendMode(srcFunc, gl.ONE_MINUS_SRC_ALPHA);

		final bones = skeleton.bones;

		if (drawBones) {
			shapes.setColor(boneLineColor);

			for (i in 0...bones.length) {
				final bone = bones[i];

				if (ignoredBones != null && ignoredBones.indexOf(bone.data.name) > -1) {
					continue;
				}

				if (bone.parent == null) {
					continue;
				}

				final x = skeletonX + bone.data.length * bone.a + bone.worldX;
				final y = skeletonY + bone.data.length * bone.c + bone.worldY;
				shapes.rectLine(true, skeletonX + bone.worldX, skeletonY + bone.worldY, x, y, boneWidth * scale);
			}

			if (drawSkeletonXY) {
				shapes.x(skeletonX, skeletonY, 4 * scale);
			}
		}

		if (drawRegionAttachments) {
			shapes.setColor(attachmentLineColor);
			final slots = skeleton.slots;

			for (i in 0...slots.length) {
				final slot = slots[i];
				final attachment = slot.getAttachment();

				if (Std.is(attachment, RegionAttachment)) {
					final regionAttachment: RegionAttachment = cast attachment;
					regionAttachment.computeWorldVertices(slot.bone, vertices, 0, 2);
					shapes.rectLine(true, vertices[0], vertices[1], vertices[2], vertices[3], 1);
					shapes.rectLine(true, vertices[2], vertices[3], vertices[4], vertices[5], 1);
					shapes.rectLine(true, vertices[4], vertices[5], vertices[6], vertices[7], 1);
					shapes.rectLine(true, vertices[6], vertices[7], vertices[0], vertices[1], 1);
				}
			}
		}

		if (drawMeshHull || drawMeshTriangles) {
			final slots = skeleton.slots;

			for (i in 0...slots.length) {
				final slot = slots[i];
				if (!slot.bone.active) continue;
				final attachment = slot.getAttachment();
				if (!(Std.is(attachment, MeshAttachment))) continue;
				final mesh: MeshAttachment = cast attachment;
				mesh.computeWorldVertices(slot, 0, mesh.worldVerticesLength, vertices, 0, 2);
				final triangles = mesh.triangles;
				var hullLength = mesh.hullLength;

				if (drawMeshTriangles) {
					shapes.setColor(triangleLineColor);
					var ii = 0;
					var nn = triangles.length;

					while (ii < nn) {
						final v1 = triangles[ii] * 2;
						final v2 = triangles[ii + 1] * 2;
						final v3 = triangles[ii + 2] * 2;
						shapes.triangle(false,
							vertices[v1], vertices[v1 + 1],
							vertices[v2], vertices[v2 + 1],
							vertices[v3], vertices[v3 + 1]
						);

						ii += 3;
					}
				}

				if (drawMeshHull && hullLength > 0) {
					shapes.setColor(attachmentLineColor);
					hullLength = (hullLength >> 1) * 2;
					var lastX = vertices[hullLength - 2];
					var lastY = vertices[hullLength - 1];

					var ii = 0;
					var nn = hullLength;

					while (ii < nn) {
						final x = vertices[ii];
						final y = vertices[ii + 1];
						shapes.rectLine(true, x, y, lastX, lastY, 2);
						lastX = x;
						lastY = y;
						ii += 2;
					}
				}
			}
		}

		if (drawBoundingBoxes) {
			bounds.update(skeleton, true);
			shapes.setColor(aabbColor);
			shapes.rect(false, bounds.minX, bounds.minY, bounds.getWidth(), bounds.getHeight());
			final polygons = bounds.polygons;
			final boxes = bounds.boundingBoxes;

			for (i in 0...polygons.length) {
				final polygon = polygons[i];
				shapes.setColor(boxes[i].color);
				shapes.polygon(polygon, 0, polygon.length);
			}
		}

	// 	if (this.drawPaths) {
	// 		let slots = skeleton.slots;
	// 		for (let i = 0, n = slots.length; i < n; i++) {
	// 			let slot = slots[i];
	// 			if (!slot.bone.active) continue;
	// 			let attachment = slot.getAttachment();
	// 			if (!(attachment instanceof PathAttachment)) continue;
	// 			let path = <PathAttachment>attachment;
	// 			let nn = path.worldVerticesLength;
	// 			let world = this.temp = Utils.setArraySize(this.temp, nn, 0);
	// 			path.computeWorldVertices(slot, 0, nn, world, 0, 2);
	// 			let color = this.pathColor;
	// 			let x1 = world[2], y1 = world[3], x2 = 0, y2 = 0;
	// 			if (path.closed) {
	// 				shapes.setColor(color);
	// 				let cx1 = world[0], cy1 = world[1], cx2 = world[nn - 2], cy2 = world[nn - 1];
	// 				x2 = world[nn - 4];
	// 				y2 = world[nn - 3];
	// 				shapes.curve(x1, y1, cx1, cy1, cx2, cy2, x2, y2, 32);
	// 				shapes.setColor(SkeletonDebugRenderer.LIGHT_GRAY);
	// 				shapes.line(x1, y1, cx1, cy1);
	// 				shapes.line(x2, y2, cx2, cy2);
	// 			}
	// 			nn -= 4;
	// 			for (let ii = 4; ii < nn; ii += 6) {
	// 				let cx1 = world[ii], cy1 = world[ii + 1], cx2 = world[ii + 2], cy2 = world[ii + 3];
	// 				x2 = world[ii + 4];
	// 				y2 = world[ii + 5];
	// 				shapes.setColor(color);
	// 				shapes.curve(x1, y1, cx1, cy1, cx2, cy2, x2, y2, 32);
	// 				shapes.setColor(SkeletonDebugRenderer.LIGHT_GRAY);
	// 				shapes.line(x1, y1, cx1, cy1);
	// 				shapes.line(x2, y2, cx2, cy2);
	// 				x1 = x2;
	// 				y1 = y2;
	// 			}
	// 		}
	// 	}

	// 	if (this.drawBones) {
	// 		shapes.setColor(this.boneOriginColor);
	// 		for (let i = 0, n = bones.length; i < n; i++) {
	// 			let bone = bones[i];
	// 			if (ignoredBones && ignoredBones.indexOf(bone.data.name) > -1) continue;
	// 			shapes.circle(true, skeletonX + bone.worldX, skeletonY + bone.worldY, 3 * this.scale, SkeletonDebugRenderer.GREEN, 8);
	// 		}
	// 	}

	// 	if (this.drawClipping) {
	// 		let slots = skeleton.slots;
	// 		shapes.setColor(this.clipColor)
	// 		for (let i = 0, n = slots.length; i < n; i++) {
	// 			let slot = slots[i];
	// 			if (!slot.bone.active) continue;
	// 			let attachment = slot.getAttachment();
	// 			if (!(attachment instanceof ClippingAttachment)) continue;
	// 			let clip = <ClippingAttachment>attachment;
	// 			let nn = clip.worldVerticesLength;
	// 			let world = this.temp = Utils.setArraySize(this.temp, nn, 0);
	// 			clip.computeWorldVertices(slot, 0, nn, world, 0, 2);
	// 			for (let i = 0, n = world.length; i < n; i+=2) {
	// 				let x = world[i];
	// 				let y = world[i + 1];
	// 				let x2 = world[(i + 2) % world.length];
	// 				let y2 = world[(i + 3) % world.length];
	// 				shapes.line(x, y, x2, y2);
	// 			}
	// 		}
	// 	}
	}
}
