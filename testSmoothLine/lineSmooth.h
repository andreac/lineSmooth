//
//  lineSmooth.h
//  LineSmoothing
//
//  Created by Andrea Cappellotto on 31/05/12.
//  Copyright 2012 università di Trento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lineSmooth : NSObject
{
    CGPoint previousPoint;
    NSMutableArray *drawnPoints;
    UIImage *cleanImage;
    UIColor * color;
    float size;
}

@property (nonatomic, readwrite, retain) IBOutlet UIImageView *imageView;



- (id)initwithImage:(UIImageView*)image;

-(void)setColor:(UIColor*)colorL;

-(void)setSize:(float)sizeL;


/** Draws a line to an image and returns the resulting image */
- (UIImage *)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint image:(UIImage *)image inView:(UIView*)viewLine;

/** Draws a path to an image and returns the resulting image */
- (UIImage *)drawPathWithPoints:(NSArray *)points image:(UIImage *)image inView:(UIView*)viewLine;

/** Ramer–Douglas–Peucker algorithm */
- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon;

/** Returns the perpendicular distance from a point to a line */
- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB;

/** Returns an array of vertices that include interpolated positions. */
- (NSArray *)catmullRomSpline:(NSArray *)points segments:(int)segments;


- (void)touchesBeganInView:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)viewLine;

- (void)touchesMovedInView:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)viewLine;

- (void)touchesEndedInView:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)viewLine;
@end
