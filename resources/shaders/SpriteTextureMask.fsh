// http://www.cocos2d-iphone.org

#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;
uniform sampler2D u_texture2;

void main()
{
	vec4 tex1 = texture2D(u_texture, v_texCoord);
	vec4 tex2 = texture2D(u_texture2, v_texCoord);
	tex1.a *= tex2.a;
	gl_FragColor = v_fragmentColor * tex1;
}
