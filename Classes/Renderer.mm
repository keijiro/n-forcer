#import "Renderer.h"

@implementation Renderer

- (id)init {
  if ((self = [super init])) {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if (!context || ![EAGLContext setCurrentContext:context]) {
      [self release];
      return nil;
    }
    
    glGenFramebuffersOES(1, &framebuffer);
    glGenRenderbuffersOES(1, &renderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES,
                                 GL_RENDERBUFFER_OES, renderbuffer);
    
    clearColor[0] = clearColor[1] = clearColor[2] = 0;
    frameCount = 0;
  }
  return self;
}

- (void)render {
  GLfloat intensity = 0.33f * (clearColor[0] + clearColor[1] + clearColor[2]);
  GLfloat fading = 0.1f + 0.1f * sinf(0.03f * frameCount);
  GLfloat noise = (intensity > 0.2f) ? 0.1f / RAND_MAX * rand() : .0f;

  GLfloat cl_r = clearColor[0] + fading + noise;
  GLfloat cl_g = clearColor[1] + fading + noise;
  GLfloat cl_b = clearColor[2] + fading + noise;

  glViewport(0, 0, screenWidth, screenHeight);
  glClearColor(cl_r, cl_g, cl_b, 1);
  glClear(GL_COLOR_BUFFER_BIT);

  glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
  [context presentRenderbuffer:GL_RENDERBUFFER_OES];

  frameCount++;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {	
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
  [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                  GL_RENDERBUFFER_WIDTH_OES, &screenWidth);
  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                  GL_RENDERBUFFER_HEIGHT_OES, &screenHeight);
  if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
    NSLog(@"Failed to make complete framebuffer object %x",
          glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    return NO;
  }
  return YES;
}

- (void)setClearColorRed:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue {
  clearColor[0] = red;
  clearColor[1] = green;
  clearColor[2] = blue;
}

- (void)dealloc {
  if (framebuffer) {
    glDeleteFramebuffersOES(1, &framebuffer);
    framebuffer = 0;
  }

  if (renderbuffer) {
    glDeleteRenderbuffersOES(1, &renderbuffer);
    renderbuffer = 0;
  }

  if ([EAGLContext currentContext] == context) {
      [EAGLContext setCurrentContext:nil];
  }

  [context release];
  context = nil;

  [super dealloc];
}

@end
