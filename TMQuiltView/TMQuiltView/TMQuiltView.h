//
//  TMQuiltView.h
//  TMQuiltView
//
//  Created by Bruno Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories

//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO 
//  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@class TMQuiltViewCell;
@class TMQuiltView;

typedef enum {
    TMQuiltViewCellMarginTop,
    TMQuiltViewCellMarginLeft,
    TMQuiltViewCellMarginRight,
    TMQuiltViewCellMarginBottom,
    TMQuiltViewCellMarginColumns,
    TMQuiltViewCellMarginRows
} TMQuiltViewMarginType;

@protocol TMQuiltViewDataSource <NSObject>

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView;
- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol TMQuiltViewDelegate <UIScrollViewDelegate>

@optional

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

// Must return a number of column greater than 0. Otherwise a default value is used.
- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView;

// Must return margins for all the possible values of TMQuiltViewMarginType. Otherwise a default value is used.
- (CGFloat)quiltViewMargin:(TMQuiltView *)quilView marginType:(TMQuiltViewMarginType)marginType;

// Must return the height of the requested cell
- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TMQuiltView : UIScrollView

@property (nonatomic, assign) id<TMQuiltViewDataSource> dataSource;
@property (nonatomic, assign) id<TMQuiltViewDelegate> delegate;

// Returns the cell if it's visible and indexPath is valid. Returns nil otherwise
- (TMQuiltViewCell *)cellAtIndexPath:(NSIndexPath*)indexPath;

// Returns a cell from the reuse pool associated to reuseIdentifier. Return nil if the pool doesn't
// contain any cell.
- (TMQuiltViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier;

// Returns an array with the visible cells
- (NSArray *)visibleCells;

// Reloads all the cells. You need to call this if the number of columns changes.
- (void)reloadData;

// Currently calling beginUpdates and endUpdates before and after row insertions and removals is required.
- (void)beginUpdates;
- (void)endUpdates;
- (void)insertCellAtIndexPath:(NSIndexPath *)indexPaths;
- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPaths;
- (void)moveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

// Returns the height of a cell
- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath;

// Returns the width of a cell
- (CGFloat)cellWidth;

// Returns the number of cells in the quilt
- (NSInteger)numberOfCells;

// Returns the number of columns in the quilt
- (NSInteger)numberOfColumns;

// Returns the number of cells in the specified column
- (NSInteger)numberOfCellsInColumn:(NSInteger)column;

@end

#import "TMQuiltViewCell.h"
#import "TMQuiltViewController.h"
