//
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
//  http://icedcoffee-framework.org
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "AppDelegate.h"

NSString *coolBackgroundShaderFSH = IC_SHADER_STRING(
#ifdef GL_ES
                                                     precision mediump float;
#endif
                                                     
                                                     uniform float time;
varying vec2 v_texCoord;
                                                     
                                                     void main( void )
{
    vec2 uPos = v_texCoord;
    //suPos -= vec2((resolution.x/resolution.y)/2.0, 0.0);//shift origin to center
    
    uPos.x -= 0.5;
    uPos.y -= 0.5;
    
    float vertColor = 0.0;
    //for( float i = 0.0; i < 10.0; ++i )
    {
        float t = time * ( 0.5 );
        
        uPos.x += sin( uPos.y * 1.0 + t ) * 0.5;
        uPos.y += cos( uPos.x * 1.0 + t ) * 0.5;
        
        float fTemp = abs(1.0 / uPos.x/uPos.y / 50.0);
        vertColor += fTemp;
    }
    
    vec4 color = vec4( vertColor * 2.5, vertColor * 0.5, 0.2+ vertColor * 2.0, 1.0 );
    gl_FragColor = color;
}
);

@implementation AppDelegate

@synthesize shaderViewController = _shaderViewController;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.shaderViewController = [ShaderPlaygroundViewController hostViewController];
    self.shaderViewController.frameUpdateMode = ICFrameUpdateModeSynchronized;
    [self.shaderViewController setAcceptsMouseMovedEvents:YES];
    [self.shaderViewController setUpdatesMouseEnterExitEventsContinuously:YES];
    self.sourceViewController.shaderViewController = self.shaderViewController;
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.icedcoffeeWindow.frame
                                          shareContext:nil
                                    hostViewController:self.shaderViewController];
    
    self.icedcoffeeWindow.contentView = glView;
    [self.icedcoffeeWindow orderFront:nil];
    [self.sourceWindow makeKeyAndOrderFront:self];
    
    [self.sourceViewController.textField setStringValue:coolBackgroundShaderFSH];
}

@end
