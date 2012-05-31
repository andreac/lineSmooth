//
//  lineSmooth.m
//  LineSmoothing
//
//  Created by Andrea Cappellotto on 31/05/12.
//  Copyright 2012 università di Trento. All rights reserved.
//

#import "lineSmooth.h"

@implementation lineSmooth
@synthesize imageView = imageView_;

- (id)initwithImage:(UIImageView*)image
{
    self = [super init];
    if (self) {
        imageView_ = [image retain];
        // Initialization code here.
        color = [UIColor blueColor];
        size = 1.0;
    }
    
    return self;
}

-(void)setColor:(UIColor*)colorL
{
    color = [colorL retain];
}

-(void)setSize:(float)sizeL
{
    size = sizeL;
}


- (UIImage *)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint image:(UIImage *)image inView:(UIView*)viewLine
{
    CGFloat red, green, blue;
    
    const float* colors = CGColorGetComponents( color.CGColor );
    red = colors[0];
    green = colors[1];
    blue = colors[2];
    
    CGSize screenSize = viewLine.frame.size;
    UIGraphicsBeginImageContext(screenSize);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    CGContextSetLineCap(currentContext, kCGLineCapRound);
	CGContextSetLineWidth(currentContext, size);
    CGContextSetRGBStrokeColor(currentContext, red, green, blue, 1);
	CGContextBeginPath(currentContext);
	CGContextMoveToPoint(currentContext, fromPoint.x, fromPoint.y);
	CGContextAddLineToPoint(currentContext, toPoint.x, toPoint.y);
	CGContextStrokePath(currentContext);
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return ret;
}

- (UIImage *)drawPathWithPoints:(NSArray *)points image:(UIImage *)image inView:(UIView*)viewLine
{ 
    
    CGFloat red, green, blue;
    
    const float* colors = CGColorGetComponents( color.CGColor );
    red = colors[0];
    green = colors[1];
    blue = colors[2];
    
    CGSize screenSize = viewLine.frame.size;
    UIGraphicsBeginImageContext(screenSize);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    CGContextSetLineCap(currentContext, kCGLineCapRound);
	CGContextSetLineWidth(currentContext, size);
    CGContextSetRGBStrokeColor(currentContext, red, green, blue, 1);
	CGContextBeginPath(currentContext);
    
    int count = [points count];
    CGPoint point = [[points objectAtIndex:0] CGPointValue];
	CGContextMoveToPoint(currentContext, point.x, point.y);
    for(int i = 1; i < count; i++) {
        point = [[points objectAtIndex:i] CGPointValue];
        CGContextAddLineToPoint(currentContext, point.x, point.y);
    }
    CGContextStrokePath(currentContext);
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return ret;
}

- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon
{
    int count = [points count];
    if(count < 3) {
        return points;
    }
    
    //Find the point with the maximum distance
    float dmax = 0;
    int index = 0;
    for(int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self perpendicularDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    //If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) {
        NSArray *recResults1 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];
        
        NSArray *recResults2 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    } else {
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    }
    
    return resultList;
}

- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB
{
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}

- (NSArray *)catmullRomSpline:(NSArray *)points segments:(int)segments
{
    int count = [points count];
    if(count < 4) {
        return points;
    }
    
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (int i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        int i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]]; 
    
    return resultArray;
}

#pragma mark - Touch handlers

- (void)touchesBeganInView:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)viewLine
{
    // retrieve touch point
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:viewLine];
    
    // record touch points to use as input to our line smoothing algorithm
    drawnPoints = [[NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:currentPoint]] retain];
    
    previousPoint = currentPoint;
    
    // to be able to replace the jagged polylines with the smooth polylines, we
    // need to save the unmodified image
    cleanImage = [imageView_.image retain];
}

- (void)touchesMovedInView:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)viewLine
{
    // retrieve touch point
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:viewLine];
    
    // record touch points to use as input to our line smoothing algorithm
    [drawnPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
    
    // draw line from the current point to the previous point
    imageView_.image = [self drawLineFromPoint:previousPoint toPoint:currentPoint image:imageView_.image inView:viewLine];
    
    previousPoint = currentPoint;
}

- (void)touchesEndedInView:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)viewLine
{
    NSArray *generalizedPoints = [self douglasPeucker:drawnPoints epsilon:2];
    
    NSArray *splinePoints = [self catmullRomSpline:generalizedPoints segments:4];
    
    imageView_.image = [self drawPathWithPoints:splinePoints image:cleanImage inView:viewLine];
    
    [drawnPoints release];
    [cleanImage release];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)dealloc
{
    [imageView_ release];
    [drawnPoints release];
    [color release];
    [super dealloc];
}


@end
