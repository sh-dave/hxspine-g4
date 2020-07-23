package spine.g4;

import spine.attachments.*;
import spine.TextureAtlas;
import spine.utils.Color;
import spine.utils.Vector2;

class SkeletonRenderer {
	static final QUAD_TRIANGLES = [0, 1, 2, 2, 3, 0];
	// static final QUAD_TRIANGLES = [0, 1, 2, 0, 2, 3];

	var premultipliedAlpha = true;//false;
	public var vertexEffect: VertexEffect = null;
	final tempColor = new Color();
	final tempColor2 = new Color();
	final vertexSize: Int;
	final twoColorTint: Bool;
	final clipper = new SkeletonClipping();
	final temp = new Vector2();
	final temp2 = new Vector2();
	final temp3 = new Color();
	final temp4 = new Color();

	var vertices: Array<Float> = null;

	public function new( twoColorTint = true ) {
		this.twoColorTint = twoColorTint;
		this.vertexSize = twoColorTint ? 2 + 2 + 4 + 4 : 2 + 2 + 4;
		this.vertices = [for (i in 0...vertexSize * 2048) 0];//new Float32Array(vertexSize * 1024);
	}

	public function draw( batcher: PolygonBatcher, skeleton: Skeleton, slotRangeStart = -1, slotRangeEnd = -1 ) {
		var blendMode: BlendMode = null;

		final tempPos = temp;
		final tempUv = temp2;
		final tempLight = temp3;
		final tempDark = temp4;
		final drawOrder = skeleton.drawOrder;
		final skeletonColor = skeleton.color;

		var uvs: Array<Float>;
		var triangles: Array<Int>;
		var attachmentColor: Color = null;
		var inRange = false;
		var numVertices = 0;
		var numFloats = 0;

		if (slotRangeStart == -1) {
			inRange = true;
		}

		for (i in 0...drawOrder.length) {
			final clippedVertexSize = clipper.isClipping() ? 2 : vertexSize;
			final slot = drawOrder[i];

			if (!slot.bone.active) {
				clipper.clipEndWithSlot(slot);
				continue;
			}

			if (slotRangeStart >= 0 && slotRangeStart == slot.data.index) {
				inRange = true;
			}

			if (!inRange) {
				clipper.clipEndWithSlot(slot);
				continue;
			}

			if (slotRangeEnd >= 0 && slotRangeEnd == slot.data.index) {
				inRange = false;
			}

			final attachment = slot.getAttachment();
			var texture: TextureImpl = null;

			if (Std.is(attachment, RegionAttachment)) {
				final region: RegionAttachment = cast attachment;
				numVertices = 4;
				numFloats = clippedVertexSize << 2;
				region.computeWorldVertices(slot.bone, vertices, 0, clippedVertexSize);
				triangles = QUAD_TRIANGLES;
				uvs = region.uvs;
				final tar = cast(region.region, TextureAtlasRegion);
				texture = cast tar.texture;
				attachmentColor = region.color;
			} else if (Std.is(attachment, MeshAttachment)) {
				final mesh: MeshAttachment = cast attachment;
				numVertices = mesh.worldVerticesLength >> 1;
				numFloats = numVertices * clippedVertexSize;

				if (numFloats > vertices.length) {
					vertices = spine.utils.Utils.newFloatArray(numFloats);
				}

				mesh.computeWorldVertices(slot, 0, mesh.worldVerticesLength, vertices, 0, clippedVertexSize);
				triangles = mesh.triangles;
				final tar = cast(mesh.region, TextureAtlasRegion);
				texture = cast tar.texture;
				uvs = mesh.uvs;
				attachmentColor = mesh.color;
			} else if (Std.is(attachment, ClippingAttachment)) {
				final clip: ClippingAttachment = cast attachment;
				clipper.clipStart(slot, clip);
				continue;
			} else {
				clipper.clipEndWithSlot(slot);
				continue;
			}

			if (texture != null) {
				final slotColor = slot.color;
				final finalColor = this.tempColor;
				finalColor.r = skeletonColor.r * slotColor.r * attachmentColor.r;
				finalColor.g = skeletonColor.g * slotColor.g * attachmentColor.g;
				finalColor.b = skeletonColor.b * slotColor.b * attachmentColor.b;
				finalColor.a = skeletonColor.a * slotColor.a * attachmentColor.a;

				if (premultipliedAlpha) {
					finalColor.r *= finalColor.a;
					finalColor.g *= finalColor.a;
					finalColor.b *= finalColor.a;
				}

				final darkColor = this.tempColor2;

				if (slot.darkColor == null) {
					darkColor.set(0, 0, 0, 1.0);
				} else {
					if (premultipliedAlpha) {
						darkColor.r = slot.darkColor.r * finalColor.a;
						darkColor.g = slot.darkColor.g * finalColor.a;
						darkColor.b = slot.darkColor.b * finalColor.a;
					} else {
						darkColor.setFromColor(slot.darkColor);
					}

					darkColor.a = premultipliedAlpha ? 1.0 : 0.0;
				}

				final slotBlendMode = slot.data.blendMode;

				if (slotBlendMode != blendMode) {
					blendMode = slotBlendMode;
					batcher.setBlendMode(BlendModes.getSource(blendMode, premultipliedAlpha), BlendModes.getDestination(blendMode));
				}

				if (clipper.isClipping()) {
					clipper.clipTriangles(vertices, numFloats, triangles, triangles.length, uvs, finalColor, darkColor, twoColorTint);
					final clippedVertices = clipper.clippedVertices;//Float32Array.fromArray(clipper.clippedVertices);
					final clippedTriangles = clipper.clippedTriangles;

					if (vertexEffect != null) {
						final verts = clippedVertices;

						if (!twoColorTint) {
							var v = 0;
							final n = clippedVertices.length;

							while (v < n) {
								tempPos.x = verts[v];
								tempPos.y = verts[v + 1];
								tempLight.set(verts[v + 2], verts[v + 3], verts[v + 4], verts[v + 5]);
								tempUv.x = verts[v + 6];
								tempUv.y = verts[v + 7];
								tempDark.set(0, 0, 0, 0);
								vertexEffect.transform(tempPos, tempUv, tempLight, tempDark);
								verts[v] = tempPos.x;
								verts[v + 1] = tempPos.y;
								verts[v + 2] = tempLight.r;
								verts[v + 3] = tempLight.g;
								verts[v + 4] = tempLight.b;
								verts[v + 5] = tempLight.a;
								verts[v + 6] = tempUv.x;
								verts[v + 7] = tempUv.y;
								v += vertexSize;
							}
						} else {
							var v = 0;
							final n = clippedVertices.length;

							while (v < n) {
								tempPos.x = verts[v];
								tempPos.y = verts[v + 1];
								tempLight.set(verts[v + 2], verts[v + 3], verts[v + 4], verts[v + 5]);
								tempUv.x = verts[v + 6];
								tempUv.y = verts[v + 7];
								tempDark.set(verts[v + 8], verts[v + 9], verts[v + 10], verts[v + 11]);
								vertexEffect.transform(tempPos, tempUv, tempLight, tempDark);
								verts[v] = tempPos.x;
								verts[v + 1] = tempPos.y;
								verts[v + 2] = tempLight.r;
								verts[v + 3] = tempLight.g;
								verts[v + 4] = tempLight.b;
								verts[v + 5] = tempLight.a;
								verts[v + 6] = tempUv.x;
								verts[v + 7] = tempUv.y;
								verts[v + 8] = tempDark.r;
								verts[v + 9] = tempDark.g;
								verts[v + 10] = tempDark.b;
								verts[v + 11] = tempDark.a;
								v += vertexSize;
							}
						}
					}

					final numTris = Std.int(clippedVertices.length / vertexSize);
					batcher.draw(texture, clippedVertices, clippedVertices.length, numTris, clippedTriangles);
				} else {
					if (vertexEffect != null) {
						if (!twoColorTint) {
							var v = 0;
							var u = 0;

							while (v < numFloats) {
								tempPos.x = vertices[v];
								tempPos.y = vertices[v + 1];
								tempUv.x = uvs[u];
								tempUv.y = uvs[u + 1];
								tempLight.setFromColor(finalColor);
								tempDark.set(0, 0, 0, 0);
								vertexEffect.transform(tempPos, tempUv, tempLight, tempDark);
								vertices[v] = tempPos.x;
								vertices[v + 1] = tempPos.y;
								vertices[v + 2] = tempLight.r;
								vertices[v + 3] = tempLight.g;
								vertices[v + 4] = tempLight.b;
								vertices[v + 5] = tempLight.a;
								vertices[v + 6] = tempUv.x;
								vertices[v + 7] = tempUv.y;
								v += vertexSize;
								u += 2;
							}
						} else {
							var v = 0;
							var u = 0;

							while (v < numFloats) {
								tempPos.x = vertices[v];
								tempPos.y = vertices[v + 1];
								tempUv.x = uvs[u];
								tempUv.y = uvs[u + 1];
								tempLight.setFromColor(finalColor);
								tempDark.setFromColor(darkColor);
								vertexEffect.transform(tempPos, tempUv, tempLight, tempDark);
								vertices[v] = tempPos.x;
								vertices[v + 1] = tempPos.y;
								vertices[v + 2] = tempLight.r;
								vertices[v + 3] = tempLight.g;
								vertices[v + 4] = tempLight.b;
								vertices[v + 5] = tempLight.a;
								vertices[v + 6] = tempUv.x;
								vertices[v + 7] = tempUv.y;
								vertices[v + 8] = tempDark.r;
								vertices[v + 9] = tempDark.g;
								vertices[v + 10] = tempDark.b;
								vertices[v + 11] = tempDark.a;
								v += vertexSize;
								u += 2;
							}
						}
					} else {
						if (!twoColorTint) {
							var v = 2;
							var u = 0;

							while (v < numFloats) {
								vertices[v] = finalColor.r;
								vertices[v + 1] = finalColor.g;
								vertices[v + 2] = finalColor.b;
								vertices[v + 3] = finalColor.a;
								vertices[v + 4] = uvs[u];
								vertices[v + 5] = uvs[u + 1];
								v += vertexSize;
								u += 2;
							}
						} else {
							var v = 2;
							var u = 0;

							while (v < numFloats) {
								vertices[v] = finalColor.r;
								vertices[v + 1] = finalColor.g;
								vertices[v + 2] = finalColor.b;
								vertices[v + 3] = finalColor.a;
								vertices[v + 4] = uvs[u];
								vertices[v + 5] = uvs[u + 1];
								vertices[v + 6] = darkColor.r;
								vertices[v + 7] = darkColor.g;
								vertices[v + 8] = darkColor.b;
								vertices[v + 9] = darkColor.a;
								v += vertexSize;
								u += 2;
							}
						}
					}

					batcher.draw(texture, vertices, numFloats, numVertices, triangles);
				}
			}

			clipper.clipEndWithSlot(slot);
		}

		clipper.clipEnd();
	}
}
