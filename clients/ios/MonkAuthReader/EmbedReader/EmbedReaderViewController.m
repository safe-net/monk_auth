//
//  EmbedReaderViewController.m
//  EmbedReader
//
//  Created by spadix on 5/2/11.
//

#import "EmbedReaderViewController.h"
#import "AuthenticationManager.h"
#import "RACSignal.h"

@interface EmbedReaderViewController()

@property AuthenticationManager *authenticationManager;
@end

@implementation EmbedReaderViewController


@synthesize readerView, resultText;

- (void) cleanup
{
    [cameraSim release];
    cameraSim = nil;
    readerView.readerDelegate = nil;
    [readerView release];
    readerView = nil;
    [resultText release];
    resultText = nil;
}

- (void) dealloc
{
    [self cleanup];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    // the delegate receives decode results
    readerView.readerDelegate = self;
    readerView.torchMode = 0;
    _authenticationManager = [[AuthenticationManager alloc] init];

    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        cameraSim = [[ZBarCameraSimulator alloc]
                        initWithViewController: self];
        cameraSim.readerView = readerView;
    }
}

- (void) viewDidUnload
{
    [self cleanup];
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient
{
    // auto-rotation is supported
    return(YES);
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) orient
                                 duration: (NSTimeInterval) duration
{
    // compensate for view rotation so camera preview is not rotated
    [readerView willRotateToInterfaceOrientation: orient
                                        duration: duration];
}

- (void) viewDidAppear: (BOOL) animated
{
    // run the reader when the view is visible
    //readerView.maxZoom = 3.0;
    [readerView start];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [readerView stop];
}

- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img
{
    // do something useful with results
    for(ZBarSymbol *sym in syms) {
        resultText.text = [NSString stringWithFormat:@"Authenticating to %@", sym.data];
        resultText.textColor = [UIColor orangeColor];
        [[self.authenticationManager processUrl:sym.data] subscribeNext:^(id x) {
            // ?
        } error:^(NSError *error) {
            // Show error message...
            resultText.text = @"Authentication Failed";
            resultText.textColor = [UIColor redColor];
        } completed:^{
            // Show success message...
            resultText.text = @"Success";
            resultText.textColor = [UIColor blackColor];
        }];
        break;
    }
}

@end
