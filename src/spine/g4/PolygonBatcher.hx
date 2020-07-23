package spine.g4;

import kha.graphics4.BlendingFactor;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.TextureUnit;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class PolygonBatcher {
	#if hxspine_kha_profiler public var drawCalls(default, null) = 0; #end

	final textureUnit: TextureUnit;

	final verticesBuffer: VertexBuffer;
	var numFloats = 0;
	var numVertices = 0;
	var vbd: kha.arrays.Float32Array;

	final indicesBuffer: IndexBuffer;
	var ibd: kha.arrays.Uint32Array;
	var indicesLength = 0;

	var lastTexture: TextureImpl = null;
	var isDrawing = false;

	// private srcBlend: number;
	// private dstBlend: number;
	var _g4: Graphics;

	public function new( structure: VertexStructure, textureUnit: TextureUnit, ?maxVertices = 10920 ) {
		if (maxVertices > 10920) {
			throw 'Can\'t have more than 10920 triangles per batch: $maxVertices';
		}

		this.textureUnit = textureUnit;

		// final attributes = twoColorTint
		// 	? [new Position2Attribute(), new ColorAttribute(), new TexCoordAttribute(), new Color2Attribute()]
		// 	: [new Position2Attribute(), new ColorAttribute(), new TexCoordAttribute()];

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

		// this.srcBlend = this.context.gl.SRC_ALPHA;
		// this.dstBlend = this.context.gl.ONE_MINUS_SRC_ALPHA;
	}

	public function begin( g4: Graphics ) {
		// trace('begin');

		if (isDrawing) {
			throw 'PolygonBatch is already drawing. Call PolygonBatch.end() before calling PolygonBatch.begin()';
		}

		#if hxspine_kha_profiler drawCalls = 0; #end

		this._g4 = g4;
		lastTexture = null;
		isDrawing = true;

		vbd = verticesBuffer.lock();
		ibd = indicesBuffer.lock();

	// 	gl.enable(gl.BLEND);
	// 	gl.blendFunc(this.srcBlend, this.dstBlend);
	}

	public function end() {
		// trace('end');
		if (!isDrawing) {
			throw 'PolygonBatch is not drawing. Call PolygonBatch.begin() before calling PolygonBatch.end()';
		}

		if (numFloats > 0 || indicesLength > 0) {
			flush();
		}

		// _g4.setTexture(shader.texUnit, null);
		// _g4.setVertexBuffer(null);
		// _g4.setIndexBuffer(null);

		// shader = null;
		lastTexture = null;
		isDrawing = false;

		// gl.disable(gl.BLEND);
	}

	public function setBlendMode( src: BlendingFactor, dst: BlendingFactor ) {
	// 	let gl = this.context.gl;
	// 	this.srcBlend = srcBlend;
	// 	this.dstBlend = dstBlend;
	// 	if (this.isDrawing) {
	// 		this.flush();
	// 		gl.blendFunc(this.srcBlend, this.dstBlend);
	// 	}
	}

	public function draw( texture: TextureImpl, vertices: Array<Float>, numFloats: Int, numVertices: Int, indices: Array<Int> ) {
		// trace('draw: numFloats=$numFloats indices=${indices.length} $indices');

		if (texture != lastTexture) {
			flush();
			lastTexture = texture;
		} else if (this.numFloats + numFloats > verticesBuffer.count() || indicesLength + indices.length > indicesBuffer.count()) {
			flush();
		}

		final indexStart = this.numVertices;
		this.numVertices += numVertices;

		for (vi in 0...numFloats) {
			vbd.set(this.numFloats++, vertices[vi]);
		}

		for (ii in 0...indices.length) {
			ibd.set(indicesLength++, indexStart + indices[ii]);
		}
	}

	function flush() {
		if (numFloats == 0) {
			return;
		}

		verticesBuffer.unlock(numVertices);//numFloats);
		indicesBuffer.unlock(indicesLength);

		_g4.setTexture(textureUnit, lastTexture.image);
		_g4.setVertexBuffer(verticesBuffer);
		_g4.setIndexBuffer(indicesBuffer);
		_g4.drawIndexedVertices(0, indicesLength);//offset * 2, count);

		numFloats = 0;
		indicesLength = 0;
		numVertices = 0;

		vbd = verticesBuffer.lock();
		ibd = indicesBuffer.lock();

		#if hxspine_kha_profiler drawCalls += 1; #end
	}
}
