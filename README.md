TMQuiltView
=======

We developed a quilt view for our [Shoebox app](http://itunes.apple.com/us/app/shoebox-by-1000memories/id472126139?mt=8)

[![](http://s3.amazonaws.com/fromus/blog_posts/quilt-camera-ipad-small.png)](http://s3.amazonaws.com/fromus/blog_posts/quilt-camera-ipad.png)

Features
=======
- Interface similar to the UITableView
- Fully compatible with NSFetchedResultsController
- Multiple columns
- Customization of the margins
- Number of column can depend on orientation
- Handling of datasource changes (row insertion/removal)

Installation
=======

- Drag the TMQuiltView subfolder into your project
- Import "TMQuiltView.h" wherever you need it
- Subclass TMQuiltViewController.

Usage
=======

Below is the excerpt from the demo view controller which shows how easy it is to setup a TMQuiltView. 
You can also directly open the TMQuiltViewDemo in XCode and build the project.

``` objective-c

@interface TMDemoQuiltViewController ()

@property (nonatomic, retain) NSArray *images;

@end

@implementation TMDemoQuiltViewController

@synthesize images = _images;

- (void)dealloc {
    [_images release], _images = nil;
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.quiltView.backgroundColor = [UIColor blackColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - QuiltViewControllerDataSource

- (NSArray *)images {
    if (!_images) {
        NSMutableArray *imageNames = [NSMutableArray array];
        for(int i = 0; i < kNumberOfCells; i++) {
            [imageNames addObject:[NSString stringWithFormat:@"%d.jpeg", i % 10 + 1]];
        }
        _images = [imageNames retain];
    }
    return _images;
}

- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath {
    return [UIImage imageNamed:[self.images objectAtIndex:indexPath.row]];
}

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [self.images count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"] autorelease];
    }
    
    cell.photoView.image = [self imageAtIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {

    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft 
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self imageAtIndexPath:indexPath].size.height / [self quiltViewNumberOfColumns:quiltView];
}

@end

```

TODOs
=======

- ARC
- Handle NSIndexPath sections
- Interface is still limited compared to UITableView's
- Better animations

License
=======
TMQuiltView

Copyright (c) 2012 1000memories

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.

Contact
=======

Feel free to reach to us at developers@1000memories.com.
