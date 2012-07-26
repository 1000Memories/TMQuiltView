using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#import "TMQuiltView.h"

SPEC_BEGIN(QuiltViewSpec)

describe(@"A TMQuiltView", ^{
    
    __block TMQuiltView *quiltView;
    __block id<CedarDouble> mockDataSource;
    __block id<CedarDouble> mockDelegate;
    
    beforeEach(^{
        quiltView = [[TMQuiltView alloc] init];
        mockDataSource = nice_fake_for(@protocol(TMQuiltViewDataSource));
        mockDelegate = nice_fake_for(@protocol(TMQuiltViewDelegate));
    });
    
    describe(@"when created", ^{
    
        it(@"should be in a clean state", ^{
            quiltView.dataSource should be_nil;
            quiltView.delegate should be_nil;
            [quiltView numberOfCells] should equal(0);
        });
        
        it(@"should have an empty frame", ^(void) {
            quiltView.frame.origin.x should equal(0);
            quiltView.frame.origin.y should equal(0);
            quiltView.frame.size.width should equal(0);
            quiltView.frame.size.height should equal(0);
        });
        
    });
    
    describe(@"with a data source, without delegate and with an CGRectZero frame", ^{
        
        beforeEach(^{
            mockDataSource stub_method(@selector(quiltViewNumberOfCells:)).and_return(1);
            
            quiltView.dataSource = (id<TMQuiltViewDataSource>)mockDataSource;
        });
        
        it(@"should return the same number of rows as the datasource", ^{
            [quiltView numberOfCells] should equal(1);
        });
        
        describe(@"cellForRowAtIndexPath:", ^{
            
            it(@"should return nil if the index path is out of range", ^{
                
                [quiltView  cellAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should be_nil;
                
            });
            
        });
        
        it(@"shouldn't have any visible cell", ^{
            mockDataSource stub_method(@selector(quiltView:cellAtIndexPath:)).and_return([[[TMQuiltViewCell alloc] initWithReuseIdentifier:nil] autorelease]);
            
            [quiltView beginUpdates];
            [quiltView insertCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [quiltView endUpdates];
            
            // We need to force the layout
            [quiltView layoutSubviews];
            
            [[quiltView visibleCells] count] should equal(0);
        });
    });
    
    describe(@"with a data source and a delegate and a frame set", ^{
        
        const CGFloat kMargin = 10.0f;
        const CGFloat kFrameSize = 1000.0f;
        const CGFloat kCellHeight = 50.0f;
        
        beforeEach(^{
            
            quiltView.delegate = (id<TMQuiltViewDelegate>)mockDelegate;
            quiltView.dataSource = (id<TMQuiltViewDataSource>)mockDataSource;
            quiltView.frame = CGRectMake(0, 0, kFrameSize, kFrameSize);

            mockDelegate stub_method(@selector(quiltViewMargin:marginType:)).and_return(kMargin);
            mockDelegate stub_method(@selector(quiltViewNumberOfColumns:)).and_return(2);
            mockDelegate stub_method(@selector(quiltView:heightForCellAtIndexPath:)).and_return(kCellHeight);
        });
        
        describe(@"its layout", ^(void) {
            
            it(@"should have the cellwidth be a fraction of the columns and take in account the margins", ^(void) {
                [quiltView cellWidth] should equal((kFrameSize - (kMargin + ([quiltView numberOfColumns] - 1) * kMargin + kMargin))/[quiltView numberOfColumns]);
            });
            
        });
        
        describe(@"when its data source has one cell", ^{

            beforeEach(^(void) {
                mockDataSource stub_method(@selector(quiltViewNumberOfCells:)).and_return(1);
                mockDataSource stub_method(@selector(quiltView:cellAtIndexPath:)).and_return([[[TMQuiltViewCell alloc] initWithReuseIdentifier:nil] autorelease]);
                [quiltView reloadData];
            });
            
            it(@"should have one visible cell in the first column", ^(void) {
                [quiltView layoutSubviews];

                [[quiltView visibleCells] count] should equal(1);
                [quiltView numberOfCellsInColumn:0] should equal(1);
                [quiltView numberOfCellsInColumn:1] should equal(0);
            });
          
            it(@"shouldn't add additional cells to the same index path", ^{
                
                [quiltView beginUpdates];
                [quiltView insertCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [quiltView insertCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [quiltView endUpdates];
                
                [quiltView layoutSubviews];
                
                [[quiltView visibleCells] count] should equal(1);
            });
            
        });
        
        describe(@"when its datasource has three cells", ^{
            
            beforeEach(^(void) {
                mockDataSource stub_method(@selector(quiltViewNumberOfCells:)).and_return(3);
                mockDataSource stub_method(@selector(quiltView:cellAtIndexPath:)).and_return([[[TMQuiltViewCell alloc] initWithReuseIdentifier:nil] autorelease]);
                [quiltView reloadData];
                [quiltView layoutSubviews];
            });
            
            it(@"should have three visible cells in the right columns", ^(void) {
                [[quiltView visibleCells] count] should equal(3);
                [quiltView numberOfCellsInColumn:0] should equal(2);
                [quiltView numberOfCellsInColumn:1] should equal(1);
            });
        });

    });

});

SPEC_END