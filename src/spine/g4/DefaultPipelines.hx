package spine.g4;

import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;

typedef ColoredPipelineOpts = {
	final pos: {
		final name: String;
		final data: VertexData;
	}

	final color: {
		final name: String;
		final data: VertexData;
	}
}

typedef TexturedPipelineOpts = ColoredPipelineOpts & {
	final texcoord: {
		final name: String;
		final data: VertexData;
	}
}

typedef TwoColorTexturedPipelineOpts = TexturedPipelineOpts & {
	final color2: {
		final name: String;
		final data: VertexData;
	}
}

class DefaultPipelines {
	public static inline final POSITION = "a_position";
	public static inline final COLOR = "a_color";
	public static inline final COLOR2 = "a_color2";
	public static inline final TEXCOORDS = "a_texCoords";
	public static inline final MVP_MATRIX = "u_projTrans";
	public static inline final SAMPLER = "u_texture";

	public static final DefaultColoredOpts: ColoredPipelineOpts = {
		pos: { name: POSITION, data: Float2 },
		color: { name: COLOR, data: Float4 },
	}

	public static final DefaultTexturedOpts: TexturedPipelineOpts = {
		pos: { name: POSITION, data: Float2 },
		color: { name: COLOR, data: Float4 },
		texcoord: { name: TEXCOORDS, data: Float2 },
	}

	public static final DefaultTwoColorTexturedOpts: TwoColorTexturedPipelineOpts = {
		pos: { name: POSITION, data: Float2 },
		color: { name: COLOR, data: Float4 },
		texcoord: { name: TEXCOORDS, data: Float2 },
		color2: { name: COLOR2, data: Float4 },
	}

	public static function createColoredVertexStructure( ?opts: ColoredPipelineOpts ) : VertexStructure {
		opts = opts != null ? opts : DefaultColoredOpts;

		final structure = new VertexStructure();
		structure.add(opts.pos.name, opts.pos.data);
		structure.add(opts.color.name, opts.color.data);
		return structure;
	}

	public static function createColoredPipeline( structure, ?vs, ?fs ) : PipelineState {
		vs = vs != null ? vs : kha.Shaders.hxspine_colored_vert;
		fs = fs != null ? fs : kha.Shaders.hxspine_colored_frag;

		final p = new PipelineState();
		p.inputLayout = [structure];
		p.vertexShader = vs;
		p.fragmentShader = fs;
		p.blendSource = BlendOne;
		p.blendDestination = InverseSourceAlpha;
		p.alphaBlendSource = BlendOne;
		p.alphaBlendDestination = InverseSourceAlpha;
		p.cullMode = None;
		p.compile();
		return p;
	}

	public static function createTexturedVertexStructure( ?opts: TexturedPipelineOpts ) : VertexStructure {
		opts = opts != null ? opts : DefaultTexturedOpts;

		final structure = new VertexStructure();
		structure.add(opts.pos.name, opts.pos.data);
		structure.add(opts.color.name, opts.color.data);
		structure.add(opts.texcoord.name, opts.texcoord.data);
		return structure;
	}

	public static function createTexturedPipeline( structure, ?vs, ?fs ) : PipelineState {
		vs = vs != null ? vs : kha.Shaders.hxspine_textured_vert;
		fs = fs != null ? fs : kha.Shaders.hxspine_textured_frag;

		final p = new PipelineState();
		p.inputLayout = [structure];
		p.vertexShader = vs;
		p.fragmentShader = fs;
		p.blendSource = BlendOne;
		p.blendDestination = InverseSourceAlpha;
		p.alphaBlendSource = BlendOne;
		p.alphaBlendDestination = InverseSourceAlpha;
		p.cullMode = None;
		p.compile();
		return p;
	}

	public static function createTwoColorTexturedVertexStructure( ?opts: TwoColorTexturedPipelineOpts ) : VertexStructure {
		opts = opts != null ? opts : DefaultTwoColorTexturedOpts;

		final structure = new VertexStructure();
		structure.add(opts.pos.name, opts.pos.data);
		structure.add(opts.color.name, opts.color.data);
		structure.add(opts.texcoord.name, opts.texcoord.data);
		structure.add(opts.color2.name, opts.color2.data);
		return structure;
	}

	public static function createTwoColorTexturedPipeline( structure, ?vs, ?fs ) : PipelineState {
		vs = vs != null ? vs : kha.Shaders.hxspine_twocolor_textured_vert;
		fs = fs != null ? fs : kha.Shaders.hxspine_twocolor_textured_frag;

		final p = new PipelineState();
		p.inputLayout = [structure];
		p.vertexShader = vs;
		p.fragmentShader = fs;
		p.blendSource = BlendOne;
		p.blendDestination = InverseSourceAlpha;
		p.alphaBlendSource = BlendOne;
		p.alphaBlendDestination = InverseSourceAlpha;
		p.cullMode = None;
		p.compile();
		return p;
	}
}
