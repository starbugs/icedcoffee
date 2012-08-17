//  
//  Copyright (C) 2012 Tobias Lensing, Marcus Tillmanns
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
//  NOTE: Parts of this project have been inspired by or may contain merged and
//  possibly modified code from the cocos2d-iphone.org project and the cocos3d
//  (see http://brenwill.com/cocos3d/). The concerned files include the original
//  copyright notice as required by the respective project license.
//
//  ===================
//
//  Import this file in modules using IcedCoffee

#import "icMacros.h"
#import "ICCamera.h"
#import "ICUICamera.h"
#import "ICConfiguration.h"
#import "icDefaults.h"
#import "ICHostViewController.h"
#import "ICTestHostViewController.h"
#import "ICNode.h"
#import "ICNodeVisitorDrawing.h"
#import "ICButton.h"
#import "ICLabel.h"
#import "ICScene.h"
#import "ICUIScene.h"
#import "ICShaderCache.h"
#import "ICShaderProgram.h"
#import "ICShaderValue.h"
#import "ICSprite.h"
#import "ICScale9Sprite.h"
#import "ICRenderTexture.h"
#import "ICScheduler.h"
#import "ICTableView.h"
#import "ICTableViewCell.h"
#import "ICTexture2D.h"
#import "ICTextureCache.h"
#import "ICTextureLoader.h"
#import "ICView.h"
#import "ICScrollView.h"
#import "icTypes.h"

#ifdef __IC_PLATFORM_MAC
#import "Platforms/Mac/ICGLView.h"
#import "Platforms/Mac/ICHostViewControllerMac.h"
#import "ICMouseEvent.h"
#elif defined(__IC_PLATFORM_IOS)
#import "Platforms/iOS/ICHostViewControllerIOS.h"
#import "Platforms/iOS/ICGLView.h"
#import "ICTouchEvent.h"
#import "ICTouch.h"
#endif




// General Documentation

/**
 @mainpage IcedCoffee Framework Documentation (v0.6.5)

 <h2>Abstract</h2>
 
 IcedCoffee is a lightweight framework for building stunning, accelerated user interfaces based on
 OpenGL ES 2. It is written in Objective-C and runs on iOS and Mac OS X. IcedCoffee is designed to
 be clean, minimalistic, consistent and reusable for different purposes. Its main focus is on user
 interfaces in the context of games, but of course you may use it for all kinds of rich and dynamic
 application frontends. IcedCoffee is open source and free for both non-commercial and
 commercial use (MIT license.)

 <h2>Status of the Framework</h2>
 
 The framework is currently in an early pre-release phase. Parts of the API may change in future
 versions and the framework has not been tested extensively yet. You are welcome to contribute
 by testing and reporting bugs or extending and fixing the framework's source.
 
 Please <a href="https://github.com/starbugs/icedcoffee/issues">report issues via GitHub</a>.
 If you'd like to contribute to the framework, please
 <a href="https://github.com/starbugs/icedcoffee">fork IcedCoffee on GitHub</a> and send me
 an email to @htmlonly<script type="text/javascript">document.write("<a href='");
 document.write("ma");document.write("il");document.write("to");document.write(":");
 document.write("ma");document.write("il");document.write("@");document.write("tl");
 document.write("e");document.write("n");document.write("si");document.write("ng");
 document.write(".");document.write("o");document.write("rg");document.write("'>");
 document.write("ma");document.write("il");document.write("@");document.write("tl");
 document.write("e");document.write("n");document.write("si");document.write("ng");
 document.write(".");document.write("o");document.write("rg");document.write("</a>");
 </script>.@endhtmlonly
 
 <h2>Status of This Documentation</h2>
 
 This documentation is preliminary, incomplete and parts of it are subject to change as the
 framework evolves. I am doing my best to keep this documentation up to date with the framework
 sources and to fill the gaps over time.
 
 <h2>Getting the Source</h2>
 
 The <a href="http://github.com/starbugs/icedcoffee">IcedCoffee source</a> is hosted on GitHub.
 You may either <a href="https://github.com/starbugs/icedcoffee/zipball/master">download a zipball
 of the current IcedCoffee master</a> or checkout the current master by opening a terminal and
 typing:
 
 @code
 $ git clone git://github.com/starbugs/icedcoffee.git
 @endcode
 
 <h2>Building</h2>
 
 IcedCoffee comes with a convenient Xcode workspace and a number of Xcode projects. Once you have
 downloaded the source, open <code>icedcoffee.xcworkspace</code> using Apple's Xcode 4.2 or newer,
 select a test application from the available schemes and hit Cmd+R to build and run the test.

 <h2>Getting Started</h2>
 
 While I am writing up a guide that covers the basics of IcedCoffee by walking through a sample
 application, you may want to have a look at one of the tests shipping with the framework source.
 
 The following tests may be interesting for you to get started:
 <ul>
    <li>The <b>PickingTest</b> illustrates how a view hierarchy backed by ICRenderTexture
    and ICView may be built up using IcedCoffee. It also demonstrates how to handle mouse and
    touch events within such a view hierarchy.</li>
    <li>The <b>DepthBufferTest</b> demonstrates picking and simple animation with depth buffers.
    </li>
    <li>The <b>Scale9SpriteTest</b> provides a resizable sprite with a scale9 grid implemented
    by the ICScale9Sprite class.</li>
 </ul>
 
 <h2>Feedback</h2>
 
 Please provide criticism, praise, requests or questions via email to
 @htmlonly<script type="text/javascript">document.write("<a href='");
 document.write("ma");document.write("il");document.write("to");document.write(":");
 document.write("ma");document.write("il");document.write("@");document.write("tl");
 document.write("e");document.write("n");document.write("si");document.write("ng");
 document.write(".");document.write("o");document.write("rg");document.write("'>");
 document.write("ma");document.write("il");document.write("@");document.write("tl");
 document.write("e");document.write("n");document.write("si");document.write("ng");
 document.write(".");document.write("o");document.write("rg");document.write("</a>");
 </script>.@endhtmlonly
 
 <h2>License</h2>
 
 IcedCoffee is distributed under an MIT license. See
 the <a href="https://github.com/starbugs/icedcoffee/blob/master/LICENSE_icedcoffee.txt">license
 details</a>.
 
 IcedCoffee has borrowed ideas and source from <a href="http://cocos2d-iphone.org">cocos2d</a>
 and several other great frameworks. See the
 <a href="https://github.com/starbugs/icedcoffee/blob/master/README.md">README</a> for details.
 
 <h2>Imprint</h2>
 
 German law requires me to put this here:
 
 Responsible for the contents of this web site: Tobias Lensing, Grenzstr. 50, 28217 Bremen,
 Tel: +49 421 3979999, @htmlonly<script type="text/javascript">document.write("<a href='");
 document.write("ma");document.write("il");document.write("to");document.write(":");
 document.write("ma");document.write("il");document.write("@");document.write("tl");
 document.write("e");document.write("n");document.write("si");document.write("ng");
 document.write(".");document.write("o");document.write("rg");document.write("'>");
 document.write("ma");document.write("il");document.write("@");document.write("tl");
 document.write("e");document.write("n");document.write("si");document.write("ng");
 document.write(".");document.write("o");document.write("rg");document.write("</a>");
 </script>.@endhtmlonly
 
 */

