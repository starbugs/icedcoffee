// Maddi

#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

uniform float u_roundness;
uniform vec2 u_size;

uniform float u_borderWidth;
uniform vec4 u_innerColor;
uniform vec4 u_innerColor2;

uniform vec4 u_borderColor;
uniform bool u_debug;


float distanceGenerator(vec2 texcoord, vec2 _u_size, float _u_roundness)
{
	vec2 aspect=normalize(_u_size);//u_aspect;
	aspect -= min(aspect.x, aspect.y);
	vec2 centroid = abs(texcoord-0.5)*2.0;
	
	centroid -= aspect;
	aspect *= vec2( 1.0/(_u_size.y/_u_size.x), 1.0/(_u_size.x/_u_size.y)); 
	centroid *= (1.0+(aspect));
	
	centroid = max(centroid, vec2(0,0));
    
	float dc = length(centroid-_u_roundness)+_u_roundness;
	float dr = max(centroid.x, centroid.y);
    
	float d = dc;
    
	float g = _u_roundness;
		
	bool bx = centroid.x < g;
	bool by = centroid.y < g;	
	
	if(bx || by)
		d = dr;
    
	return d;
}

vec3 colorFromDist(float d, float stop, float borderWidth)
{
    vec3 r = vec3(0.0, 0.0, 0.0);

#ifdef GL_ES
    float dd = 0.01;//fwidth(d)*0.5;
#else
    float dd = fwidth(d)*0.5;
#endif
    if(d > stop+dd)
        r.x = 1.0;
    else if(d < stop-dd)
    {
        if( d > stop-borderWidth + dd) 
            r.y = 1.0;
        else
            r.y = smoothstep(stop-borderWidth - dd, stop-borderWidth+dd, d);
    }
    else
    {
        r.x = smoothstep(stop-dd, stop+dd, d);
        r.y = smoothstep(stop+dd, stop-dd, d);
	}

    return r;
}


void main()
{
	float x = v_texCoord.x;
	float y = v_texCoord.y;
	
	float stop = 0.5;
	float borderWidth = u_borderWidth; //u_borderWidth;
    
    vec2 _u_size = u_size;
    float _u_roundness = u_roundness;
    vec4 _u_innerColor = mix(u_innerColor, u_innerColor2, y);
    
    vec4 _u_borderColor = u_borderColor;
    
	float s0 = 1.0-distanceGenerator(v_texCoord.xy, _u_size, _u_roundness);
        
        
        
	vec3 r0 = colorFromDist(s0, stop, borderWidth);
    
	gl_FragColor = _u_borderColor * r0.y;//min(r0.y,r0.z);
	gl_FragColor += _u_innerColor * r0.x;
//	if(u_debug)
//	{
//		gl_FragColor *= 0.25;
//		gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0)*(s0);
//	}

}
