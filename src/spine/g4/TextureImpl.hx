package spine.g4;

import kha.Image;

class TextureImpl implements Texture {
	public final image: Image;

	public function new( image ) {
		this.image = image;
	}

	public function getWidth()
		return image.width;

	public function getHeight()
		return image.height;

	public function setFilters( minFilter: spine.Texture.TextureFilter, magFilter: spine.Texture.TextureFilter ) {
	}

	public function setWraps( uWrap: spine.Texture.TextureWrap, vWrap: spine.Texture.TextureWrap ) {
	}

	public function dispose() {
		image.unload();
	}
}
