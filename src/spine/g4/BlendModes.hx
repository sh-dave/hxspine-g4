package spine.g4;

import kha.graphics4.BlendingFactor;

class BlendModes {
	public static inline function getDestination( blendMode: BlendMode ) : BlendingFactor {
		return switch blendMode {
			case Additive: BlendOne;
			case Normal, Multiply, Screen: InverseSourceAlpha;
		}
	}

	public static inline function getSource( blendMode: BlendMode, premultipliedAlpha: Bool ) : BlendingFactor {
		return switch blendMode {
			case Normal, Additive: premultipliedAlpha ? BlendOne : SourceAlpha;
			case Multiply: DestinationColor;
			case Screen: BlendOne;
		}
	}
}
