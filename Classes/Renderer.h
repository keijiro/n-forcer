#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface Renderer : NSObject {
@private
  EAGLContext *context;
  GLint screenWidth;
  GLint screenHeight;
  GLuint framebuffer;
  GLuint renderbuffer;
  GLfloat clearColor[3];
  NSInteger frameCount;
}

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)setClearColorRed:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue;

@end
