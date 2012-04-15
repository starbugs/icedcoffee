// IcedCoffee Color-based picking

#ifdef GL_ES
precision highp float;
#endif

uniform vec4 u_pickColor;

void main()
{
	gl_FragColor = u_pickColor;
}
