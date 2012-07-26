using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#import "TMQuiltView.h"

SPEC_BEGIN(QuiltViewSpec)

describe(@"Initializing a QuiltView", ^{
    
    __block TMQuiltView *quiltView;
    __block id<CedarDouble> mockDataSource;
    __block id<CedarDouble> mockDelegate;
    
    beforeEach(^{
        quiltView = [[TMQuiltView alloc] init];
        mockDataSource = nice_fake_for(@protocol(TMQuiltViewDataSource));
        mockDelegate = nice_fake_for(@protocol(TMQuiltViewDelegate));
    });
    
    it(@"should start in a clean state", ^{
        quiltView.dataSource should be_nil;
        quiltView.delegate should be_nil;
        [quiltView numberOfCells] should equal(0);
    });
    
    describe(@"with a data source", ^{
        
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
        
    });
    
    describe(@"with a data source and a delegate", ^{
        
        beforeEach(^{
            
            quiltView.delegate = (id<TMQuiltViewDelegate>)mockDelegate;
            quiltView.dataSource = (id<TMQuiltViewDataSource>)mockDataSource;
            
        });
        
        describe(@"when inserting a rows", ^{
            
            it(@"shouldn't add two times the same index path", ^{
                
                mockDataSource stub_method(@selector(quiltViewNumberOfCells:)).and_return(1);
                mockDataSource stub_method(@selector(quiltView:cellAtIndexPath:)).and_return([[[TMQuiltViewCell alloc] initWithReuseIdentifier:nil] autorelease]);
                
                [quiltView beginUpdates];
                [quiltView insertRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [quiltView insertRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [quiltView endUpdates];
                
                // We need to force the layout
                [quiltView layoutSubviews];
                
                [[quiltView visibleCells] count] should equal(1);
            });
            
        });
        
    });
});

SPEC_END