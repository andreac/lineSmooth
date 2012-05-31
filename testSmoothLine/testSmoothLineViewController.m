//
//  testSmoothLineViewController.m
//  testSmoothLine
//
//  Created by Andrea Cappellotto on 31/05/12.
//  Copyright 2012 università di Trento. All rights reserved.
//

#import "testSmoothLineViewController.h"

@implementation testSmoothLineViewController


-(id)init
{
    self = [super init];
    if (self) {
        
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        
        //creo l'imageview la alloco con il frame
        imageV = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        //setto il colore a binaco
        imageV.backgroundColor = [UIColor whiteColor];
        //aggiungo l'imageview alla view
        [self.view addSubview:imageV];
        
        //alloco e inizializzo con i'imageview la classe lineSmooth
        lineSm = [[lineSmooth alloc] initwithImage:imageV];
        //imposto spessore linea
        [lineSm setSize:1.4];
        //imposto colore linea (lo posso fare quante volte voglio) ??gestione memoria??
        [lineSm setColor:[UIColor redColor]];
        //rilascio l'imageview (c'è il retain non ti preoccupare)
        [imageV release];
    }
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/


#pragma mark - Touch handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //richiamo i metodi per migliorare la linea
    [lineSm touchesBeganInView:touches withEvent:event withView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //richiamo i metodi per migliorare la linea
    [lineSm touchesMovedInView:touches withEvent:event withView:self.view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //richiamo i metodi per migliorare la linea
    [lineSm touchesEndedInView:touches withEvent:event withView:self.view];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
