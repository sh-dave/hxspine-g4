package spine.g4;

import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.math.Vector2;
import spine.utils.Color;

class ShapeRenderer {
	var isDrawing = false;
	var shapeType = ShapeType.Filled;

	final verticesBuffer: VertexBuffer;
	var verticesLength = 0; // number of floats
	var numVertices = 0;
	var vbd: kha.arrays.Float32Array;
	final vertexSize = 6;

	final indicesBuffer: IndexBuffer;
	var ibd: kha.arrays.Uint32Array;
	var indicesLength = 0;

	var color = Color.WHITE;
	final tmp = new Vector2();

	// private srcBlend: number;
	// private dstBlend: number;

	public function new( structure: VertexStructure, maxVertices = 10920 ) {
		if (maxVertices > 10920) {
			throw 'Can\'t have more than 10920 triangles per batch: $maxVertices';
		}

		// final attributes = [new Position2Attribute(), new ColorAttribute()];
		// final structure = new VertexStructure();

		// for (a in attributes) {
		// 	structure.add(a.name, switch [a.type, a.numElements] {
		// 		case [Float, 2]: Float2;
		// 		case [Float, 3]: Float3;
		// 		case [Float, 4]: Float4;
		// 		case _: throw 'unhandled attribute ${a.name}';
		// 	});
		// }

		verticesBuffer = new VertexBuffer(maxVertices, structure, DynamicUsage);
		indicesBuffer = new IndexBuffer(maxVertices * 3, DynamicUsage);

	// 	this.srcBlend = this.context.gl.SRC_ALPHA;
	// 	this.dstBlend = this.context.gl.ONE_MINUS_SRC_ALPHA;
	}

	var _g4: Graphics;

	public function begin( g4: Graphics ) {
		if (isDrawing) {
			throw 'ShapeRenderer.begin() has already been called';
		}

		this._g4 = g4;
		// this.shader = shader;
		isDrawing = true;

		vbd = verticesBuffer.lock();
		ibd = indicesBuffer.lock();

	// 	gl.enable(gl.BLEND);
	// 	gl.blendFunc(this.srcBlend, this.dstBlend);
	}

	public function end() {
		if (!isDrawing) {
			throw 'ShapeRenderer.begin() has not been called';
		}

		if (verticesLength > 0 || indicesLength > 0) {
			flush();
		}

		// shader = null;
		isDrawing = false;
	}

	function flush() {
		if (verticesLength == 0) {
			return;
		}

		verticesBuffer.unlock(verticesLength);
		indicesBuffer.unlock(indicesLength);

		_g4.setVertexBuffer(verticesBuffer);
		_g4.setIndexBuffer(indicesBuffer);
		_g4.drawIndexedVertices(0, indicesLength);//offset * 2, count);

		verticesLength = 0;
		indicesLength = 0;
		numVertices = 0;

		vbd = verticesBuffer.lock();
		ibd = indicesBuffer.lock();
	}

	// setBlendMode (srcBlend: number, dstBlend: number) {
	// 	let gl = this.context.gl;
	// 	this.srcBlend = srcBlend;
	// 	this.dstBlend = dstBlend;
	// 	if (this.isDrawing) {
	// 		this.flush();
	// 		gl.blendFunc(this.srcBlend, this.dstBlend);
	// 	}
	// }

	public function setColor( color: Color ) {
		this.color = color;
	}

	// setColorWith (r: number, g: number, b: number, a: number) {
	// 	this.color.set(r, g, b, a);
	// }

	// point (x: number, y: number, color: Color = null) {
	// 	this.check(ShapeType.Point, 1);
	// 	if (color === null) color = this.color;
	// 	this.vertex(x, y, color);
	// }

	// public function line( x: Float, y: Float, x2: Float, y2: Float, color: Color = null ) {
	// 	check(Line, 2 * vertexSize, 2);

	// 	if (color == null) {
	// 		color = this.color;
	// 	}

	// 	vertex(x, y, color);
	// 	vertex(x2, y2, color);
	// }

	public function triangle( filled: Bool, x: Float, y: Float, x2: Float, y2: Float, x3: Float, y3: Float, color: Color = null, color2: Color = null, color3: Color = null ) {
		check(filled ? Filled : Line, filled ? 3 * vertexSize : 6 * vertexSize, filled ? 3 : 6); // TODO (DK) fix me

		if (color == null) color = this.color;
		if (color2 == null) color2 = this.color;
		if (color3 == null) color3 = this.color;

		if (filled) {
			vertex(x, y, color);
			vertex(x2, y2, color2);
			vertex(x3, y3, color3);
		} else {
			rectLine(true, x, y, x2, y2, 2);
			rectLine(true, x2, y2, x3, y3, 2);
			rectLine(true, x3, y3, x, y, 2);
		}
	}

	public function quad( filled: Bool, x: Float, y: Float, x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float, color: Color = null, color2: Color = null, color3: Color = null, color4: Color = null ) {
		check(filled ? Filled : Line, 3 * vertexSize, 3); // TODO (DK) fix me

		if (color == null) color = this.color;
		if (color2 == null) color2 = this.color;
		if (color3 == null) color3 = this.color;
		if (color4 == null) color4 = this.color;

		if (filled) {
			vertex(x, y, color);
			vertex(x2, y2, color2);
			vertex(x3, y3, color3);

			vertex(x3, y3, color3);
			vertex(x4, y4, color4);
			vertex(x, y, color);
		} else {
			rectLine(true, x, y, x2, y2, 2, color);
			rectLine(true, x2, y2, x3, y3, 2, color2);
			rectLine(true, x3, y3, x4, y4, 2, color3);
			rectLine(true, x4, y4, x, y, 2, color4);
		}
	}

	public function rect( filled: Bool, x: Float, y: Float, width: Float, height: Float, color: Color = null ) {
		quad(filled, x, y, x + width, y, x + width, y + height, x, y + height, color, color, color, color);
	}

	final _t = new Vector2();

	public function rectLine( filled: Bool, x1: Float, y1: Float, x2: Float, y2: Float, width: Float, color: Color = null ) {
		check(filled ? Filled : Line, filled ? 6 * vertexSize : 8 * vertexSize, filled ? 6 : 8); // TODO (DK) fix me?

		if (color == null) {
			color = this.color;
		}

		_t.setFrom(new Vector2(y2 - y1, x1 - x2).normalized());

		width *= 0.5;
		final tx = _t.x * width;
		final ty = _t.y * width;

		if (filled) {
			vertex(x1 + tx, y1 + ty, color);
			vertex(x1 - tx, y1 - ty, color);
			vertex(x2 + tx, y2 + ty, color);

			vertex(x2 - tx, y2 - ty, color);
			vertex(x2 + tx, y2 + ty, color);
			vertex(x1 - tx, y1 - ty, color);
		} else {
			vertex(x1 + tx, y1 + ty, color);
			vertex(x1 - tx, y1 - ty, color);

			vertex(x2 + tx, y2 + ty, color);
			vertex(x2 - tx, y2 - ty, color);

			vertex(x2 + tx, y2 + ty, color);
			vertex(x1 + tx, y1 + ty, color);

			vertex(x2 - tx, y2 - ty, color);
			vertex(x1 - tx, y1 - ty, color);
		}
	}

	public function x( x: Float, y: Float, size: Float ) {
		rectLine(true, x - size, y - size, x + size, y + size, size);
		rectLine(true, x - size, y + size, x + size, y - size, size);
	}

	public function polygon( polygonVertices: Array<Float>, offset: Int, count: Int, color: Color = null ) {
		if (count < 3) {
			throw 'Polygon must contain at least 3 vertices';
		}

		check(Line, count * 2, count);
		if (color == null) color = this.color;

		offset <<= 1;
		count <<= 1;

		final firstX = polygonVertices[offset];
		final firstY = polygonVertices[offset + 1];
		final last = offset + count;

		var i = offset;
		final n = offset + count;

		while (i < n) {
			final x1 = polygonVertices[i];
			final y1 = polygonVertices[i+1];

			var x2 = 0.0;
			var y2 = 0.0;

			if (i + 2 >= last) {
				x2 = firstX;
				y2 = firstY;
			} else {
				x2 = polygonVertices[i + 2];
				y2 = polygonVertices[i + 3];
			}

			rectLine(true, x1, y1, x2, y2, 2, color);
			// this.vertex(x1, y1, color);
			// this.vertex(x2, y2, color);

			i += 2;
		}
	}

	// circle (filled: boolean, x: number, y: number, radius: number, color: Color = null, segments: number = 0) {
	// 	if (segments === 0) segments = Math.max(1, (6 * MathUtils.cbrt(radius)) | 0);
	// 	if (segments <= 0) throw new Error("segments must be > 0.");
	// 	if (color === null) color = this.color;
	// 	let angle = 2 * MathUtils.PI / segments;
	// 	let cos = Math.cos(angle);
	// 	let sin = Math.sin(angle);
	// 	let cx = radius, cy = 0;
	// 	if (!filled) {
	// 		this.check(ShapeType.Line, segments * 2 + 2);
	// 		for (let i = 0; i < segments; i++) {
	// 			this.vertex(x + cx, y + cy, color);
	// 			let temp = cx;
	// 			cx = cos * cx - sin * cy;
	// 			cy = sin * temp + cos * cy;
	// 			this.vertex(x + cx, y + cy, color);
	// 		}
	// 		// Ensure the last segment is identical to the first.
	// 		this.vertex(x + cx, y + cy, color);
	// 	} else {
	// 		this.check(ShapeType.Filled, segments * 3 + 3);
	// 		segments--;
	// 		for (let i = 0; i < segments; i++) {
	// 			this.vertex(x, y, color);
	// 			this.vertex(x + cx, y + cy, color);
	// 			let temp = cx;
	// 			cx = cos * cx - sin * cy;
	// 			cy = sin * temp + cos * cy;
	// 			this.vertex(x + cx, y + cy, color);
	// 		}
	// 		// Ensure the last segment is identical to the first.
	// 		this.vertex(x, y, color);
	// 		this.vertex(x + cx, y + cy, color);
	// 	}

	// 	let temp = cx;
	// 	cx = radius;
	// 	cy = 0;
	// 	this.vertex(x + cx, y + cy, color);
	// }

	// curve (x1: number, y1: number, cx1: number, cy1: number, cx2: number, cy2: number, x2: number, y2: number, segments: number, color: Color = null) {
	// 	this.check(ShapeType.Line, segments * 2 + 2);
	// 	if (color === null) color = this.color;

	// 	// Algorithm from: http://www.antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION
	// 	let subdiv_step = 1 / segments;
	// 	let subdiv_step2 = subdiv_step * subdiv_step;
	// 	let subdiv_step3 = subdiv_step * subdiv_step * subdiv_step;

	// 	let pre1 = 3 * subdiv_step;
	// 	let pre2 = 3 * subdiv_step2;
	// 	let pre4 = 6 * subdiv_step2;
	// 	let pre5 = 6 * subdiv_step3;

	// 	let tmp1x = x1 - cx1 * 2 + cx2;
	// 	let tmp1y = y1 - cy1 * 2 + cy2;

	// 	let tmp2x = (cx1 - cx2) * 3 - x1 + x2;
	// 	let tmp2y = (cy1 - cy2) * 3 - y1 + y2;

	// 	let fx = x1;
	// 	let fy = y1;

	// 	let dfx = (cx1 - x1) * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
	// 	let dfy = (cy1 - y1) * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;

	// 	let ddfx = tmp1x * pre4 + tmp2x * pre5;
	// 	let ddfy = tmp1y * pre4 + tmp2y * pre5;

	// 	let dddfx = tmp2x * pre5;
	// 	let dddfy = tmp2y * pre5;

	// 	while (segments-- > 0) {
	// 		this.vertex(fx, fy, color);
	// 		fx += dfx;
	// 		fy += dfy;
	// 		dfx += ddfx;
	// 		dfy += ddfy;
	// 		ddfx += dddfx;
	// 		ddfy += dddfy;
	// 		this.vertex(fx, fy, color);
	// 	}
	// 	this.vertex(fx, fy, color);
	// 	this.vertex(x2, y2, color);
	// }

	function vertex( x: Float, y: Float, color: Color ) {
		vbd[verticesLength++] = x;
		vbd[verticesLength++] = y;
		vbd[verticesLength++] = color.r;
		vbd[verticesLength++] = color.g;
		vbd[verticesLength++] = color.b;
		vbd[verticesLength++] = color.a;

		ibd[indicesLength++] = numVertices;

		numVertices += 1;
	}


	function check( shapeType: ShapeType, numVertices: Int, numIndices: Int ) {
		if (!isDrawing) {
			throw 'ShapeRenderer.begin() has not been called';
		}

		if (verticesLength + numVertices > verticesBuffer.count() || indicesLength + numIndices > indicesBuffer.count()) {
			flush();
		}

		// if (this.shapeType == shapeType) {
		// 	if (mesh.maxVertices() - mesh.numVertices() < numVertices) {
		// 		flush();
		// 	} else {
		// 		return;
		// 	}
		// } else {
		// 	flush();
		// 	this.shapeType = shapeType;
		// }
	}
}
