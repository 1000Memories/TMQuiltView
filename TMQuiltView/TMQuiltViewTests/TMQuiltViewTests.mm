using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#import "TMQuiltView.h"

@interface TMMockQuiltViewDataSource : NSObject <TMQuiltViewDataSource>

@property (nonatomic, assign) NSInteger numberOfCells;

@end

@implementation TMMockQuiltViewDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return self.numberOfCells;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.numberOfCells) {
        return [[[TMQuiltViewCell alloc] initWithReuseIdentifier:nil] autorelease];
    } else {
        NSLog(@"Data source doesn't have row %d", indexPath.row);
        @throw @"Error";
    }
}

@end

SPEC_BEGIN(QuiltViewSpec)

describe(@"A TMQuiltView", ^{
    
    __block TMQuiltView *quiltView;
    __block TMMockQuiltViewDataSource *mockDataSource;
    __block id<CedarDouble> mockDelegate;
    
    beforeEach(^{
        quiltView = [[TMQuiltView alloc] init];
        mockDataSource = [[TMMockQuiltViewDataSource alloc] init];
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
            mockDataSource.numberOfCells = 1;
            
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
            
            it(@"should have the content size be proportional to the number of cells", ^(void) {
                mockDataSource.numberOfCells = 1;
                [quiltView reloadData];
                [quiltView contentSize].height should equal(kMargin + kCellHeight + kMargin);
            });

        });
        
        describe(@"when its data source has one cell", ^{

            beforeEach(^(void) {
                mockDataSource.numberOfCells = 1;
                [quiltView reloadData];
            });
            
            it(@"should have one visible cell in the first column", ^(void) {
                [quiltView layoutSubviews];

                [[quiltView visibleCells] count] should equal(1);
                [quiltView numberOfCellsInColumn:0] should equal(1);
                [quiltView numberOfCellsInColumn:1] should equal(0);
            });
          
            it(@"shouldn't add additional cells to the same index path", ^{
                
                mockDataSource.numberOfCells = 2;
                [quiltView beginUpdates];
                [quiltView insertCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [quiltView insertCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [quiltView endUpdates];
                
                [quiltView layoutSubviews];
                
                [[quiltView visibleCells] count] should equal(2);
            });
            
        });
        
        describe(@"when its datasource has three cells", ^{
            
            beforeEach(^(void) {
                mockDataSource.numberOfCells = 3;
                [quiltView reloadData];
                [quiltView layoutSubviews];
            });
            
            it(@"should have three visible cells in the right columns", ^(void) {
                [[quiltView visibleCells] count] should equal(3);
                [quiltView numberOfCellsInColumn:0] should equal(2);
                [quiltView numberOfCellsInColumn:1] should equal(1);
            });
        });
        
        describe(@"when the delegate changes the number of cells and when reloadData is called", ^{
           
            it(@"should update the quilt view to contain the new number of cells", ^{
                mockDataSource.numberOfCells = 3;
                [quiltView reloadData];
                [quiltView layoutSubviews];
                mockDataSource.numberOfCells = 2;
                [quiltView reloadData];
                [quiltView layoutSubviews];
                
            });
            
        });

    });

});

SPEC_END