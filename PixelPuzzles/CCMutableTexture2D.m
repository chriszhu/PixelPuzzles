///
//	All info located in header.
///
#import <OpenGLES/ES1/glext.h>
#import "CCMutableTexture2D.h"
#import "AsyncObject.h"
#import "EAGLView.h"
#import "CCConfiguration.h"
#import "ccMacros.h"
#import "CCDirector.h"

///
//	Fast find for powers of 2
///
bool IsPow2(uint v)
{
	return (v > 1) && ((v & (v - 1)) == 0);
}

///
//	Fast round to nearest power of 2 for 32-bit int's.
///
uint RoundToNearestPow2(uint v)
{
	//if(v < 32) return 32;
	if(v <= 1)return 2;
	v--;
	v |= v >> 1;
	v |= v >> 2;
	v |= v >> 4;
	v |= v >> 8;
	v |= v >> 16;
	v++;
	return v;
}

@implementation CCMutableTexture2D
static EAGLContext *mutableTextureAuxEAGLcontext = nil;
+ (int) maxTextureSize 
{
	return 1024;
}
- (id) initWithData:(const void*)data pixelFormat:(CCTexture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	if((self = [super initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:size])) {
		data_ = NULL;
		dirty_ = false;
	}					
	return self;
}

- (void) dealloc
{
	if(data_){
		free(data_);
		data_ = NULL;
	}
	
	[contextLock_ release];
	
	[super dealloc];
}

@end

@implementation CCMutableTexture2D(Image)
+ (id) textureWithImage:(UIImage*) image
{
	return [[[self alloc]initWithImage:image]autorelease];
}

- (id) initWithImage:(UIImage *)uiImage
{
	NSUInteger				width,
	height,
	i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	CCTexture2DPixelFormat    pixelFormat;
	CGImageRef				image;
	BOOL					sizeToFit = NO;
	
	
	image = [uiImage CGImage];
	
	if(image == NULL) {
		[self release];
		NSLog(@"Image is Null");
		return nil;
	}
	
	
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	
	size_t bpp = CGImageGetBitsPerComponent(image);
	if(CGImageGetColorSpace(image)) {
		if(hasAlpha || bpp >= 8)
			pixelFormat = [CCTexture2D defaultAlphaPixelFormat];
		else
			pixelFormat = kTexture2DPixelFormat_RGB565;
	} else  //NOTE: No colorspace means a mask image
		pixelFormat = kTexture2DPixelFormat_A8;
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	
	width = imageSize.width;
	
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
			i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
			i *= 2;
		height = i;
	}
	
	
	unsigned maxTextureSize = [[CCConfiguration sharedConfiguration] maxTextureSize];
	if( width > maxTextureSize || height > maxTextureSize ) {
		CCLOG(@"cocos2d: WARNING: Image (%d x %d) is bigger than the supported %d x %d", width, height, maxTextureSize, maxTextureSize);
		return nil;
	}
	
	//	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
	//		width /= 2;
	//		height /= 2;
	//		transform = CGAffineTransformScale(transform, 0.5f, 0.5f);
	//		imageSize.width *= 0.5f;
	//		imageSize.height *= 0.5f;
	//	}
	
	// Create the bitmap graphics context
	
	switch(pixelFormat) {          
		case kTexture2DPixelFormat_RGBA8888:
		case kTexture2DPixelFormat_RGBA4444:
		case kTexture2DPixelFormat_RGB5A1:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast; 
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, info | kCGBitmapByteOrder32Big);				
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			info = kCGImageAlphaNoneSkipLast;
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, info | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_A8:
			data = malloc(height * width);
			info = kCGImageAlphaOnly; 
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, info);
			break;                    
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	// Repack the pixel data into the right format
	
	if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	else if (pixelFormat == kTexture2DPixelFormat_RGBA4444) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
		
		
		free(data);
		data = tempData;
		
	}
	else if (pixelFormat == kTexture2DPixelFormat_RGB5A1) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 7) << 0); // A
		
		
		free(data);
		data = tempData;
	}
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
	
	// should be after calling super init
	hasPremultipliedAlpha_ = (info == kCGImageAlphaPremultipliedLast || info == kCGImageAlphaPremultipliedFirst);
	
	CGContextRelease(context);
	
	//	This is the only change =/ but we want to keep the data for mutable methods
	data_ = data;
	contextLock_ = [[NSLock alloc] init];
	
	return self;
}
@end

@implementation CCMutableTexture2D(CCTexture2D)
///
//	Create a texture with a CCTexture2D
///
+ (id) textureWithTexture2D:(CCTexture2D*) tex
{
	return [[[self alloc]initWithTexture2D:tex]autorelease];
}
- (id) initWithTexture2D:(CCTexture2D*) tex
{	
	if((self = [super init])){
		contextLock_ = [[NSLock alloc] init];
	}
	return self;
}
@end

@implementation CCMutableTexture2D (MutableTexture)
+ (id) textureWithSize:(CGSize) size 
{
	return [[[self alloc] initWithSize:size pixelFormat:[[self class] defaultAlphaPixelFormat]] autorelease];
}
+ (id) textureWithSize:(CGSize) size pixelFormat:(CCTexture2DPixelFormat) pixelFormat 
{
	return [[[self alloc] initWithSize:size pixelFormat:pixelFormat] autorelease];
}
- (id) initWithSize:(CGSize) size pixelFormat:(CCTexture2DPixelFormat) pixelFormat 
{
	if((self = [super init])){
		format_ = pixelFormat;
		size_ = size;
		
		width_ = size.width;
		if(!IsPow2(width_))
			width_ = RoundToNearestPow2(width_);
		
		height_ = size.height;
		if(!IsPow2(height_))
			height_ = RoundToNearestPow2(height_);
		
		int dataSize = 0;
		switch (format_) {
			case kTexture2DPixelFormat_RGBA8888:
				dataSize = width_ * height_ * sizeof(int);
				break;
			case kTexture2DPixelFormat_RGBA4444:
			case kTexture2DPixelFormat_RGB5A1:
			case kTexture2DPixelFormat_RGB565:
				dataSize = width_ * height_ * sizeof(short);
				break;
			case kTexture2DPixelFormat_A8:
				dataSize = width_ * height_;
				break;
			default:
				break;
		}
		
		maxS_ = size_.width / (float)width_;
		maxT_ = size_.height / (float)height_;
		
		hasPremultipliedAlpha_ = NO;
		data_ = calloc(dataSize, 1);
		NSAssert(data_, @"Low Memory, could not allocate Texture Data");
		
		glGenTextures(1, &name_);
		glBindTexture(GL_TEXTURE_2D, name_);
		
		[self setAntiAliasTexParameters];
		
		switch(format_)
		{
			case kTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_BYTE, data_);
				break;
			case kTexture2DPixelFormat_RGBA4444:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data_);
				break;
			case kTexture2DPixelFormat_RGB5A1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data_);
				break;
			case kTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width_, height_, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data_);
				break;
			case kTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width_, height_, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data_);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
				
		}
		contextLock_ = [[NSLock alloc] init];
	}
	return self;
}

- (ccColor4B) pixelAt:(CGPoint) pt 
{
	ccColor4B c = {0, 0, 0, 0};
	if(!data_) return c;
	if(pt.x < 0 || pt.y < 0) return c;
	if(pt.x >= size_.width || pt.y >= size_.height) return c;
	
	uint x = pt.x, y = pt.y;
	
	if(format_ == kTexture2DPixelFormat_RGBA8888){
		uint *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.r = *pixel & 0xff;
		c.g = (*pixel >> 8) & 0xff;
		c.b = (*pixel >> 16) & 0xff;
		c.a = (*pixel >> 24) & 0xff;
	} else if(format_ == kTexture2DPixelFormat_RGBA4444){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.a = ((*pixel & 0xf) << 4) | (*pixel & 0xf);
		c.b = (((*pixel >> 4) & 0xf) << 4) | ((*pixel >> 4) & 0xf);
		c.g = (((*pixel >> 8) & 0xf) << 4) | ((*pixel >> 8) & 0xf);
		c.r = (((*pixel >> 12) & 0xf) << 4) | ((*pixel >> 12) & 0xf);
	} else if(format_ == kTexture2DPixelFormat_RGB5A1){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.r = ((*pixel >> 11) & 0x1f)<<3;
		c.g = ((*pixel >> 6) & 0x1f)<<3;
		c.b = ((*pixel >> 1) & 0x1f)<<3;
		c.a = (*pixel & 0x1)*255;
	} else if(format_ == kTexture2DPixelFormat_RGB565){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.b = (*pixel & 0x1f)<<3;
		c.g = ((*pixel >> 5) & 0x3f)<<2;
		c.r = ((*pixel >> 11) & 0x1f)<<3;
		c.a = 255;
	} else if(format_ == kTexture2DPixelFormat_A8){
		GLubyte *pixel = data_;
		c.a = pixel[(y * width_) + x];
		// Default white
		c.r = 255;
		c.g = 255;
		c.b = 255;
	}
	
	return c;
}

- (BOOL) setPixelAt:(CGPoint) pt rgba:(ccColor4B) c 
{
	if(!data_)return NO;
	if(pt.x < 0 || pt.y < 0) return NO;
	if(pt.x >= size_.width || pt.y >= size_.height) return NO;
	uint x = pt.x, y = pt.y;
	
	dirty_ = true;
	
	//	Shifted bit placement based on little-endian, let's make this more
	//	portable =/
	
	if(format_ == kTexture2DPixelFormat_RGBA8888){
		uint *pixel = data_;
		pixel[(y * width_) + x] = (c.a << 24) | (c.b << 16) | (c.g << 8) | c.r;
	} else if(format_ == kTexture2DPixelFormat_RGBA4444){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		*pixel = ((c.r >> 4) << 12) | ((c.g >> 4) << 8) | ((c.b >> 4) << 4) | (c.a >> 4);
	} else if(format_ == kTexture2DPixelFormat_RGB5A1){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		*pixel = ((c.r >> 3) << 11) | ((c.g >> 3) << 6) | ((c.b >> 3) << 1) | (c.a > 0);
	} else if(format_ == kTexture2DPixelFormat_RGB565){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		*pixel = ((c.r >> 3) << 11) | ((c.g >> 2) << 5) | (c.b >> 3);
	} else if(format_ == kTexture2DPixelFormat_A8){
		GLubyte *pixel = data_;
		pixel[(y * width_) + x] = c.a;
	} else {
		dirty_ = false;
		return NO;
	}
	return YES;
}

- (void) fill:(ccColor4B) p 
{
	for(int r = 0; r < size_.height;++r){
		for(int c = 0; c < size_.width; ++c){
			[self setPixelAt:CGPointMake(c, r) rgba:p];
		}
	}
}


- (void) copy:(CCMutableTexture2D*) textureToCopy offset:(CGPoint) offset 
{
	for(int r = 0; r < size_.height;++r){
		for(int c = 0; c < size_.width; ++c){
			[self setPixelAt:CGPointMake(c + offset.x, r + offset.y) rgba:[textureToCopy pixelAt:CGPointMake(c, r)]];
		}
	}
}


- (void) apply 
{
	if(!dirty_) return;
	if(!data_) return;
	
	
	
	glBindTexture(GL_TEXTURE_2D, name_);
	
	switch(format_)
	{
		case kTexture2DPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_BYTE, data_);
			break;
		case kTexture2DPixelFormat_RGBA4444:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data_);
			break;
		case kTexture2DPixelFormat_RGB5A1:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data_);
			break;
		case kTexture2DPixelFormat_RGB565:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width_, height_, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data_);
			break;
		case kTexture2DPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width_, height_, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data_);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@""];
	}
	dirty_ = false;
}

- (void) applyWithAsyncObject:(AsyncObject*)async
{	
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	[contextLock_ lock];
	if( mutableTextureAuxEAGLcontext == nil ) {
		mutableTextureAuxEAGLcontext = [[EAGLContext alloc]
							  initWithAPI:kEAGLRenderingAPIOpenGLES1
							  sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]];
		
		if( ! mutableTextureAuxEAGLcontext )
			CCLOG(@"cocos2d: TextureCache: Could not create EAGL context");
	}
	
	if( [EAGLContext setCurrentContext:mutableTextureAuxEAGLcontext] ) {
		[self apply];
		// The callback will be executed on the main thread
		[async.target performSelectorOnMainThread:async.selector withObject:nil waitUntilDone:NO];	
		[EAGLContext setCurrentContext:nil];
	} else {
		CCLOG(@"cocos2d: TextureCache: EAGLContext error");
	}
	[contextLock_ unlock];
	[autoreleasepool release];
}

- (void) applyAsyncWithCallback:(id) target selector:(SEL) callbackSel
{
	
	AsyncObject *asyncObject = [[AsyncObject alloc] init];
	asyncObject.selector = callbackSel;
	asyncObject.target = target;
	[NSThread detachNewThreadSelector:@selector(applyWithAsyncObject:) toTarget:self withObject:asyncObject];
	[asyncObject release];
}

- (void) drawAtPoint:(CGPoint)point 
{
	[contextLock_ lock];
	[super drawAtPoint:point];
	[contextLock_ unlock];
}


- (void) drawInRect:(CGRect)rect
{
	[contextLock_ lock];
	[super drawInRect:rect];
	[contextLock_ unlock];
}

@end
