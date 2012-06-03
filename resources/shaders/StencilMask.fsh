// IcedCoffee Stencil Mask Shader

#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

void main()
{
	vec4 tex = texture2D(u_texture, v_texCoord);
	if (tex.a < 0.9) {
		discard;
	}
	gl_FragColor = v_fragmentColor * tex;
}
