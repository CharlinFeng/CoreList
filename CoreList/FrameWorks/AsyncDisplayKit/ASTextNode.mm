/* Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ASTextNode.h"

#import "_ASDisplayLayer.h"
#import "ASAssert.h"
#import "ASDisplayNode+Subclasses.h"
#import "ASDisplayNodeInternal.h"
#import "ASHighlightOverlayLayer.h"
#import "ASDisplayNodeExtras.h"

#import "ASTextKitCoreTextAdditions.h"
#import "ASTextKitHelpers.h"
#import "ASTextKitRenderer.h"
#import "ASTextKitRenderer+Positioning.h"
#import "ASTextKitShadower.h"

#import "ASInternalHelpers.h"
#import "ASEqualityHelpers.h"

static const NSTimeInterval ASTextNodeHighlightFadeOutDuration = 0.15;
static const NSTimeInterval ASTextNodeHighlightFadeInDuration = 0.1;
static const CGFloat ASTextNodeHighlightLightOpacity = 0.11;
static const CGFloat ASTextNodeHighlightDarkOpacity = 0.22;
static NSString *ASTextNodeTruncationTokenAttributeName = @"ASTextNodeTruncationAttribute";

@interface ASTextNodeDrawParameters : NSObject

- (instancetype)initWithRenderer:(ASTextKitRenderer *)renderer
                      textOrigin:(CGPoint)textOrigin
                 backgroundColor:(CGColorRef)backgroundColor;

@property (nonatomic, strong, readonly) ASTextKitRenderer *renderer;

@property (nonatomic, assign, readonly) CGPoint textOrigin;

@property (nonatomic, assign, readonly) CGColorRef backgroundColor;

@end

@implementation ASTextNodeDrawParameters

- (instancetype)initWithRenderer:(ASTextKitRenderer *)renderer
                      textOrigin:(CGPoint)textOrigin
                 backgroundColor:(CGColorRef)backgroundColor
{
  if (self = [super init]) {
    _renderer = renderer;
    _textOrigin = textOrigin;
    _backgroundColor = CGColorRetain(backgroundColor);
  }
  return self;
}

- (void)dealloc
{
  CGColorRelease(_backgroundColor);
}

@end

@interface ASTextNode () <UIGestureRecognizerDelegate>

@end

@implementation ASTextNode {
  CGSize _shadowOffset;
  CGColorRef _shadowColor;
  CGFloat _shadowOpacity;
  CGFloat _shadowRadius;

  NSArray *_exclusionPaths;

  NSAttributedString *_composedTruncationString;

  NSString *_highlightedLinkAttributeName;
  id _highlightedLinkAttributeValue;
  NSRange _highlightRange;
  ASHighlightOverlayLayer *_activeHighlightLayer;

  ASDN::Mutex _rendererLock;

  CGSize _constrainedSize;

  ASTextKitRenderer *_renderer;

  UILongPressGestureRecognizer *_longPressGestureRecognizer;
}
@dynamic placeholderEnabled;

#pragma mark - NSObject

- (instancetype)init
{
  if (self = [super init]) {
    // Load default values from superclass.
    _shadowOffset = [super shadowOffset];
    CGColorRef superColor = [super shadowColor];
    if (superColor != NULL) {
      _shadowColor = CGColorRetain(superColor);
    }
    _shadowOpacity = [super shadowOpacity];
    _shadowRadius = [super shadowRadius];

    // Disable user interaction for text node by default.
    self.userInteractionEnabled = NO;
    self.needsDisplayOnBoundsChange = YES;

    _truncationMode = NSLineBreakByWordWrapping;
    _composedTruncationString = DefaultTruncationAttributedString();

    // The common case is for a text node to be non-opaque and blended over some background.
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    self.linkAttributeNames = @[ NSLinkAttributeName ];

    // Accessibility
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitStaticText;

    _constrainedSize = CGSizeMake(-INFINITY, -INFINITY);

    // Placeholders
    // Disabled by default in ASDisplayNode, but add a few options for those who toggle
    // on the special placeholder behavior of ASTextNode.
    _placeholderColor = ASDisplayNodeDefaultPlaceholderColor();
    _placeholderInsets = UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0);
  }

  return self;
}

- (instancetype)initWithLayerBlock:(ASDisplayNodeLayerBlock)viewBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock
{
  ASDisplayNodeAssertNotSupported();
  return nil;
}

- (instancetype)initWithViewBlock:(ASDisplayNodeViewBlock)viewBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock
{
  ASDisplayNodeAssertNotSupported();
  return nil;
}

- (void)dealloc
{
  if (_shadowColor != NULL) {
    CGColorRelease(_shadowColor);
  }

  if (_longPressGestureRecognizer) {
    _longPressGestureRecognizer.delegate = nil;
    [_longPressGestureRecognizer removeTarget:nil action:NULL];
    [self.view removeGestureRecognizer:_longPressGestureRecognizer];
  }
}

- (NSString *)description
{
  NSString *plainString = [[_attributedString string] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  NSString *truncationString = [_composedTruncationString string];
  if (plainString.length > 50)
    plainString = [[plainString substringToIndex:50] stringByAppendingString:@"\u2026"];
  return [NSString stringWithFormat:@"<%@: %p; text = \"%@\"; truncation string = \"%@\"; frame = %@>", self.class, self, plainString, truncationString, self.nodeLoaded ? NSStringFromCGRect(self.layer.frame) : nil];
}

#pragma mark - ASDisplayNode

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
  ASDisplayNodeAssert(constrainedSize.width >= 0, @"Constrained width for text (%f) is too  narrow", constrainedSize.width);
  ASDisplayNodeAssert(constrainedSize.height >= 0, @"Constrained height for text (%f) is too short", constrainedSize.height);

  _constrainedSize = constrainedSize;
  [self _invalidateRenderer];
  ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
    [self setNeedsDisplay];
  });
  return [[self _renderer] size];
}

- (void)displayDidFinish
{
  [super displayDidFinish];

  // We invalidate our renderer here to clear the very high memory cost of
  // keeping this around.  _invalidateRenderer will dealloc this onto a bg
  // thread resulting in less stutters on the main thread than if it were
  // to be deallocated in dealloc.  This is also helpful in opportunistically
  // reducing memory consumption and reducing the overall footprint of the app.
  [self _invalidateRenderer];
}

- (void)clearContents
{
  // We discard the backing store and renderer to prevent the very large
  // memory overhead of maintaining these for all text nodes.  They can be
  // regenerated when layout is necessary.
  [super clearContents];      // ASDisplayNode will set layer.contents = nil
  [self _invalidateRenderer];
}

- (void)didLoad
{
  [super didLoad];

  // If we are view-backed, support gesture interaction.
  if (!self.isLayerBacked) {
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    _longPressGestureRecognizer.cancelsTouchesInView = self.longPressCancelsTouches;
    _longPressGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_longPressGestureRecognizer];
  }
}

- (void)setFrame:(CGRect)frame
{
  [super setFrame:frame];
  if (!CGSizeEqualToSize(frame.size, _constrainedSize)) {
    // Our bounds have changed to a size that is not identical to our constraining size,
    // so our previous layout information is invalid, and TextKit may draw at the
    // incorrect origin.
    _constrainedSize = CGSizeMake(-INFINITY, -INFINITY);
    [self _invalidateRenderer];
  }
}

- (void)setBounds:(CGRect)bounds
{
  [super setBounds:bounds];
  if (!CGSizeEqualToSize(bounds.size, _constrainedSize)) {
    // Our bounds have changed to a size that is not identical to our constraining size,
    // so our previous layout information is invalid, and TextKit may draw at the
    // incorrect origin.
    _constrainedSize = CGSizeMake(-INFINITY, -INFINITY);
    [self _invalidateRenderer];
  }
}

#pragma mark - Renderer Management

- (ASTextKitRenderer *)_renderer
{
  ASDN::MutexLocker l(_rendererLock);
  if (_renderer == nil) {
    CGSize constrainedSize = _constrainedSize.width != -INFINITY ? _constrainedSize : self.bounds.size;
    _renderer = [[ASTextKitRenderer alloc] initWithTextKitAttributes:[self _rendererAttributes]
                                                     constrainedSize:constrainedSize];
  }
  return _renderer;
}

- (ASTextKitAttributes)_rendererAttributes
{
  return {
    .attributedString = _attributedString,
    .truncationAttributedString = _composedTruncationString,
    .lineBreakMode = _truncationMode,
    .maximumNumberOfLines = _maximumNumberOfLines,
    .exclusionPaths = _exclusionPaths,
  };
}

- (void)_invalidateRenderer
{
  ASDN::MutexLocker l(_rendererLock);
  if (_renderer) {
    // Destruction of the layout managers/containers/text storage is quite
    // expensive, and can take some time, so we dispatch onto a bg queue to
    // actually dealloc.
    __block ASTextKitRenderer *renderer = _renderer;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      renderer = nil;
    });
  }
  _renderer = nil;
}

#pragma mark - Modifying User Text

- (void)setAttributedString:(NSAttributedString *)attributedString {
  if (ASObjectIsEqual(attributedString, _attributedString)) {
    return;
  }

  if (attributedString == nil) {
    attributedString = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
  }

  _attributedString = ASCleanseAttributedStringOfCoreTextAttributes(attributedString);

  // We need an entirely new renderer
  [self _invalidateRenderer];

  ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
    // Tell the display node superclasses that the cached layout is incorrect now
    [self invalidateCalculatedLayout];

    [self setNeedsDisplay];

    self.accessibilityLabel = _attributedString.string;

    if (_attributedString.length == 0) {
      // We're not an accessibility element by default if there is no string.
      self.isAccessibilityElement = NO;
    } else {
      self.isAccessibilityElement = YES;
    }
  });
  
  if (attributedString.length > 0) {
    CGFloat screenScale = ASScreenScale();
    self.ascender = round([[attributedString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL] ascender] * screenScale)/screenScale;
    self.descender = round([[attributedString attribute:NSFontAttributeName atIndex:attributedString.length - 1 effectiveRange:NULL] descender] * screenScale)/screenScale;
  }
}

#pragma mark - Text Layout

- (void)setExclusionPaths:(NSArray *)exclusionPaths
{
  if (ASObjectIsEqual(exclusionPaths, _exclusionPaths)) {
    return;
  }
  
  _exclusionPaths = [exclusionPaths copy];
  [self _invalidateRenderer];
  [self invalidateCalculatedLayout];
  ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
    [self setNeedsDisplay];
  });
}

- (NSArray *)exclusionPaths
{
  return _exclusionPaths;
}

#pragma mark - Drawing

+ (void)drawRect:(CGRect)bounds withParameters:(ASTextNodeDrawParameters *)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  ASDisplayNodeAssert(context, @"This is no good without a context.");

  CGContextSaveGState(context);

  // Fill background
  if (!isRasterizing) {
    CGColorRef backgroundColor = parameters.backgroundColor;
    if (backgroundColor) {
      CGContextSetFillColorWithColor(context, backgroundColor);
      CGContextSetBlendMode(context, kCGBlendModeCopy);
      // outset the background fill to cover fractional errors when drawing at a
      // small contentsScale.
      CGContextFillRect(context, CGRectInset(bounds, -2, -2));
      CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
  }

  // Draw shadow
  [[parameters.renderer shadower] setShadowInContext:context];

  // Draw text
  bounds.origin = parameters.textOrigin;
  [parameters.renderer drawInContext:context bounds:bounds];

  CGContextRestoreGState(context);
}

- (NSObject *)drawParametersForAsyncLayer:(_ASDisplayLayer *)layer
{
  // Offset the text origin by any shadow padding
  UIEdgeInsets shadowPadding = [self shadowPadding];
  CGPoint textOrigin = CGPointMake(self.bounds.origin.x - shadowPadding.left, self.bounds.origin.y - shadowPadding.top);
  return [[ASTextNodeDrawParameters alloc] initWithRenderer:[self _renderer]
                                                 textOrigin:textOrigin
                                            backgroundColor:self.backgroundColor.CGColor];
}

#pragma mark - Attributes

- (id)linkAttributeValueAtPoint:(CGPoint)point
                  attributeName:(out NSString **)attributeNameOut
                          range:(out NSRange *)rangeOut
{
  return [self _linkAttributeValueAtPoint:point
                            attributeName:attributeNameOut
                                    range:rangeOut
            inAdditionalTruncationMessage:NULL];
}

- (id)_linkAttributeValueAtPoint:(CGPoint)point
                   attributeName:(out NSString **)attributeNameOut
                           range:(out NSRange *)rangeOut
   inAdditionalTruncationMessage:(out BOOL *)inAdditionalTruncationMessageOut
{
  ASTextKitRenderer *renderer = [self _renderer];
  NSRange visibleRange = renderer.visibleRanges[0];
  NSAttributedString *attributedString = _attributedString;

  // Check in a 9-point region around the actual touch point so we make sure
  // we get the best attribute for the touch.
  __block CGFloat minimumGlyphDistance = CGFLOAT_MAX;

  // Final output vars
  __block id linkAttributeValue = nil;
  __block NSString *linkAttributeName = nil;
  __block BOOL inTruncationMessage = NO;

  [renderer enumerateTextIndexesAtPosition:point usingBlock:^(NSUInteger characterIndex, CGRect glyphBoundingRect, BOOL *stop) {
    CGPoint glyphLocation = CGPointMake(CGRectGetMidX(glyphBoundingRect), CGRectGetMidY(glyphBoundingRect));
    CGFloat currentDistance = sqrtf(powf(point.x - glyphLocation.x, 2.f) + powf(point.y - glyphLocation.y, 2.f));
    if (currentDistance >= minimumGlyphDistance) {
      // If the distance computed from the touch to the glyph location is
      // not the minimum among the located link attributes, we can just skip
      // to the next location.
      return;
    }

    // Check if it's outside the visible range, if so, then we mark this touch
    // as inside the truncation message, because in at least one of the touch
    // points it was.
    if (!(NSLocationInRange(characterIndex, visibleRange))) {
      inTruncationMessage = YES;
    }

    if (inAdditionalTruncationMessageOut != NULL) {
      *inAdditionalTruncationMessageOut = inTruncationMessage;
    }

    // Short circuit here if it's just in the truncation message.  Since the
    // truncation message may be beyond the scope of the actual input string,
    // we have to make sure that we don't start asking for attributes on it.
    if (inTruncationMessage) {
      return;
    }

    for (NSString *attributeName in _linkAttributeNames) {
      NSRange range;
      id value = [attributedString attribute:attributeName atIndex:characterIndex longestEffectiveRange:&range inRange:visibleRange];
      NSString *name = attributeName;

      if (value == nil || name == nil) {
        // Didn't find anything
        continue;
      }

      // Check if delegate implements optional method, if not assume NO.
      // Should the text be highlightable/touchable?
      if (![_delegate respondsToSelector:@selector(textNode:shouldHighlightLinkAttribute:value:atPoint:)] ||
          ![_delegate textNode:self shouldHighlightLinkAttribute:name value:value atPoint:point]) {
        value = nil;
        name = nil;
      }

      if (value != nil || name != nil) {
        // We found a minimum glyph distance link attribute, so set the min
        // distance, and the out params.
        minimumGlyphDistance = currentDistance;

        if (rangeOut != NULL && value != nil) {
          *rangeOut = range;
          // Limit to only the visible range, because the attributed string will
          // return values outside the visible range.
          if (NSMaxRange(*rangeOut) > NSMaxRange(visibleRange)) {
            (*rangeOut).length = MAX(NSMaxRange(visibleRange) - (*rangeOut).location, 0);
          }
        }

        if (attributeNameOut != NULL) {
          *attributeNameOut = name;
        }

        // Set the values for the next iteration
        linkAttributeValue = value;
        linkAttributeName = name;

        break;
      }
    }
  }];

  return linkAttributeValue;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if (gestureRecognizer == _longPressGestureRecognizer) {
    // Don't allow long press on truncation message
    if ([self _pendingTruncationTap]) {
      return NO;
    }

    // Ask our delegate if a long-press on an attribute is relevant
    if ([self.delegate respondsToSelector:@selector(textNode:shouldLongPressLinkAttribute:value:atPoint:)]) {
      return [self.delegate textNode:self
        shouldLongPressLinkAttribute:_highlightedLinkAttributeName
                               value:_highlightedLinkAttributeValue
                             atPoint:[gestureRecognizer locationInView:self.view]];
    }

    // Otherwise we are good to go.
    return YES;
  }

  if (([self _pendingLinkTap] || [self _pendingTruncationTap])
      && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]
      && CGRectContainsPoint(self.view.bounds, [gestureRecognizer locationInView:self.view])) {
    return NO;
  }

  return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - Highlighting

- (NSRange)highlightRange
{
  return _highlightRange;
}

- (void)setHighlightRange:(NSRange)highlightRange
{
  [self setHighlightRange:highlightRange animated:NO];
}

- (void)setHighlightRange:(NSRange)highlightRange animated:(BOOL)animated
{
  [self _setHighlightRange:highlightRange forAttributeName:nil value:nil animated:animated];
}

- (void)_setHighlightRange:(NSRange)highlightRange forAttributeName:(NSString *)highlightedAttributeName value:(id)highlightedAttributeValue animated:(BOOL)animated
{
  ASDisplayNodeAssertMainThread();

  _highlightedLinkAttributeName = highlightedAttributeName;
  _highlightedLinkAttributeValue = highlightedAttributeValue;

  if (!NSEqualRanges(highlightRange, _highlightRange) && ((0 != highlightRange.length) || (0 != _highlightRange.length))) {

    _highlightRange = highlightRange;

    if (_activeHighlightLayer) {
      if (animated) {
        __unsafe_unretained CALayer *weakHighlightLayer = _activeHighlightLayer;
        _activeHighlightLayer = nil;

        weakHighlightLayer.opacity = 0.0;

        CFTimeInterval beginTime = CACurrentMediaTime();
        CABasicAnimation *possibleFadeIn = (CABasicAnimation *)[weakHighlightLayer animationForKey:@"opacity"];
        if (possibleFadeIn) {
          // Calculate when we should begin fading out based on the end of the fade in animation,
          // Also check to make sure that the new begin time hasn't already passed
          CGFloat newBeginTime = (possibleFadeIn.beginTime + possibleFadeIn.duration);
          if (newBeginTime > beginTime) {
            beginTime = newBeginTime;
          }
        }
        
        CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        fadeOut.fromValue = possibleFadeIn.toValue ?: @(((CALayer *)weakHighlightLayer.presentationLayer).opacity);
        fadeOut.toValue = @0.0;
        fadeOut.fillMode = kCAFillModeBoth;
        fadeOut.duration = ASTextNodeHighlightFadeOutDuration;
        fadeOut.beginTime = beginTime;

        dispatch_block_t prev = [CATransaction completionBlock];
        [CATransaction setCompletionBlock:^{
          [weakHighlightLayer removeFromSuperlayer];
        }];

        [weakHighlightLayer addAnimation:fadeOut forKey:fadeOut.keyPath];

        [CATransaction setCompletionBlock:prev];

      } else {
        [_activeHighlightLayer removeFromSuperlayer];
        _activeHighlightLayer = nil;
      }
    }
    if (0 != highlightRange.length) {
      // Find layer in hierarchy that allows us to draw highlighting on.
      CALayer *highlightTargetLayer = self.layer;
      while (highlightTargetLayer != nil) {
        if (highlightTargetLayer.as_allowsHighlightDrawing) {
          break;
        }
        highlightTargetLayer = highlightTargetLayer.superlayer;
      }

      if (highlightTargetLayer != nil) {
        NSArray *highlightRects = [[self _renderer] rectsForTextRange:highlightRange measureOption:ASTextKitRendererMeasureOptionBlock];
        NSMutableArray *converted = [NSMutableArray arrayWithCapacity:highlightRects.count];
        for (NSValue *rectValue in highlightRects) {
          UIEdgeInsets shadowPadding = _renderer.shadower.shadowPadding;
          CGRect rendererRect = [[self class] _adjustRendererRect:rectValue.CGRectValue forShadowPadding:shadowPadding];
          CGRect highlightedRect = [self.layer convertRect:rendererRect toLayer:highlightTargetLayer];

          // We set our overlay layer's frame to the bounds of the highlight target layer.
          // Offset highlight rects to avoid double-counting target layer's bounds.origin.
          highlightedRect.origin.x -= highlightTargetLayer.bounds.origin.x;
          highlightedRect.origin.y -= highlightTargetLayer.bounds.origin.y;
          [converted addObject:[NSValue valueWithCGRect:highlightedRect]];
        }

        ASHighlightOverlayLayer *overlayLayer = [[ASHighlightOverlayLayer alloc] initWithRects:converted];
        overlayLayer.highlightColor = [[self class] _highlightColorForStyle:self.highlightStyle];
        overlayLayer.frame = highlightTargetLayer.bounds;
        overlayLayer.masksToBounds = NO;
        overlayLayer.opacity = [[self class] _highlightOpacityForStyle:self.highlightStyle];
        [highlightTargetLayer addSublayer:overlayLayer];

        if (animated) {
          CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
          fadeIn.fromValue = @0.0;
          fadeIn.toValue = @(overlayLayer.opacity);
          fadeIn.duration = ASTextNodeHighlightFadeInDuration;
          fadeIn.beginTime = CACurrentMediaTime();

          [overlayLayer addAnimation:fadeIn forKey:fadeIn.keyPath];
        }

        [overlayLayer setNeedsDisplay];

        _activeHighlightLayer = overlayLayer;
      }
    }
  }
}

- (void)_clearHighlightIfNecessary
{
  if ([self _pendingLinkTap] || [self _pendingTruncationTap]) {
    [self setHighlightRange:NSMakeRange(0, 0) animated:YES];
  }
}

+ (CGColorRef)_highlightColorForStyle:(ASTextNodeHighlightStyle)style
{
  return [UIColor colorWithWhite:(style == ASTextNodeHighlightStyleLight ? 0.0 : 1.0) alpha:1.0].CGColor;
}

+ (CGFloat)_highlightOpacityForStyle:(ASTextNodeHighlightStyle)style
{
  return (style == ASTextNodeHighlightStyleLight) ? ASTextNodeHighlightLightOpacity : ASTextNodeHighlightDarkOpacity;
}

#pragma mark - Text rects

+ (CGRect)_adjustRendererRect:(CGRect)rendererRect forShadowPadding:(UIEdgeInsets)shadowPadding
{
  rendererRect.origin.x -= shadowPadding.left;
  rendererRect.origin.y -= shadowPadding.top;
  return rendererRect;
}

- (NSArray *)_rectsForTextRange:(NSRange)textRange measureOption:(ASTextKitRendererMeasureOption)measureOption
{
  NSArray *rects = [[self _renderer] rectsForTextRange:textRange measureOption:measureOption];
  NSMutableArray *adjustedRects = [NSMutableArray array];

  for (NSValue *rectValue in rects) {
    CGRect rect = [rectValue CGRectValue];
    rect = [self.class _adjustRendererRect:rect forShadowPadding:self.shadowPadding];

    NSValue *adjustedRectValue = [NSValue valueWithCGRect:rect];
    [adjustedRects addObject:adjustedRectValue];
  }

  return adjustedRects;
}

- (NSArray *)rectsForTextRange:(NSRange)textRange
{
  return [self _rectsForTextRange:textRange measureOption:ASTextKitRendererMeasureOptionCapHeight];
}

- (NSArray *)highlightRectsForTextRange:(NSRange)textRange
{
  return [self _rectsForTextRange:textRange measureOption:ASTextKitRendererMeasureOptionBlock];
}

- (CGRect)trailingRect
{
  CGRect rect = [[self _renderer] trailingRect];
  return [self.class _adjustRendererRect:rect forShadowPadding:self.shadowPadding];
}

- (CGRect)frameForTextRange:(NSRange)textRange
{
  CGRect frame = [[self _renderer] frameForTextRange:textRange];
  return [self.class _adjustRendererRect:frame forShadowPadding:self.shadowPadding];
}

#pragma mark - Placeholders

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
  _placeholderColor = placeholderColor;

  // prevent placeholders if we don't have a color
  self.placeholderEnabled = placeholderColor != nil;
}

- (UIImage *)placeholderImage
{
  // FIXME: Replace this implementation with reusable CALayers that have .backgroundColor set.
  // This would completely eliminate the memory and performance cost of the backing store.
  CGSize size = self.calculatedSize;
  UIGraphicsBeginImageContext(size);
  [self.placeholderColor setFill];

  ASTextKitRenderer *renderer = [self _renderer];
  NSRange textRange = renderer.visibleRanges[0];

  // cap height is both faster and creates less subpixel blending
  NSArray *lineRects = [self _rectsForTextRange:textRange measureOption:ASTextKitRendererMeasureOptionLineHeight];

  // fill each line with the placeholder color
  for (NSValue *rectValue in lineRects) {
    CGRect lineRect = [rectValue CGRectValue];
    CGRect fillBounds = CGRectIntegral(UIEdgeInsetsInsetRect(lineRect, self.placeholderInsets));

    if (fillBounds.size.width > 0.0 && fillBounds.size.height > 0.0) {
      UIRectFill(fillBounds);
    }
  }

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

#pragma mark - Touch Handling

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  if (!_passthroughNonlinkTouches) {
    return [super pointInside:point withEvent:event];
  }

  NSRange range = NSMakeRange(0, 0);
  NSString *linkAttributeName = nil;
  BOOL inAdditionalTruncationMessage = NO;

  id linkAttributeValue = [self _linkAttributeValueAtPoint:point
                                             attributeName:&linkAttributeName
                                                     range:&range
                             inAdditionalTruncationMessage:&inAdditionalTruncationMessage];

  NSUInteger lastCharIndex = NSIntegerMax;
  BOOL linkCrossesVisibleRange = (lastCharIndex > range.location) && (lastCharIndex < NSMaxRange(range) - 1);

  if (inAdditionalTruncationMessage) {
    return YES;
  } else if (range.length && !linkCrossesVisibleRange && linkAttributeValue != nil && linkAttributeName != nil) {
    return YES;
  } else {
    return NO;
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];

  ASDisplayNodeAssertMainThread();

  UITouch *touch = [touches anyObject];

  UIView *view = touch.view;
  CGPoint point = [touch locationInView:view];
  point = [self.view convertPoint:point fromView:view];

  NSRange range = NSMakeRange(0, 0);
  NSString *linkAttributeName = nil;
  BOOL inAdditionalTruncationMessage = NO;

  id linkAttributeValue = [self _linkAttributeValueAtPoint:point
                                             attributeName:&linkAttributeName
                                                     range:&range
                             inAdditionalTruncationMessage:&inAdditionalTruncationMessage];

  NSUInteger lastCharIndex = NSIntegerMax;
  BOOL linkCrossesVisibleRange = (lastCharIndex > range.location) && (lastCharIndex < NSMaxRange(range) - 1);

  if (inAdditionalTruncationMessage) {
    NSRange visibleRange = [self _renderer].visibleRanges[0];
    NSRange truncationMessageRange = [self _additionalTruncationMessageRangeWithVisibleRange:visibleRange];
    [self _setHighlightRange:truncationMessageRange forAttributeName:ASTextNodeTruncationTokenAttributeName value:nil animated:YES];
  } else if (range.length && !linkCrossesVisibleRange && linkAttributeValue != nil && linkAttributeName != nil) {
    [self _setHighlightRange:range forAttributeName:linkAttributeName value:linkAttributeValue animated:YES];
  }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];

  [self _clearHighlightIfNecessary];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];

  if ([self _pendingLinkTap] && [_delegate respondsToSelector:@selector(textNode:tappedLinkAttribute:value:atPoint:textRange:)]) {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [_delegate textNode:self tappedLinkAttribute:_highlightedLinkAttributeName value:_highlightedLinkAttributeValue atPoint:point textRange:_highlightRange];
  }

  if ([self _pendingTruncationTap]) {
    if ([_delegate respondsToSelector:@selector(textNodeTappedTruncationToken:)]) {
      [_delegate textNodeTappedTruncationToken:self];
    }
  }

  [self _clearHighlightIfNecessary];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];

  [self _clearHighlightIfNecessary];
}

- (void)_handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer
{
  // Respond to long-press when it begins, not when it ends.
  if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
    if ([self.delegate respondsToSelector:@selector(textNode:longPressedLinkAttribute:value:atPoint:textRange:)]) {
      CGPoint touchPoint = [_longPressGestureRecognizer locationInView:self.view];
      [self.delegate textNode:self longPressedLinkAttribute:_highlightedLinkAttributeName value:_highlightedLinkAttributeValue atPoint:touchPoint textRange:_highlightRange];
    }
  }
}

- (BOOL)_pendingLinkTap
{
  return (_highlightedLinkAttributeValue != nil && ![self _pendingTruncationTap]) && _delegate != nil;
}

- (BOOL)_pendingTruncationTap
{
  return [_highlightedLinkAttributeName isEqualToString:ASTextNodeTruncationTokenAttributeName];
}

#pragma mark - Shadow Properties

- (CGColorRef)shadowColor
{
  return _shadowColor;
}

- (void)setShadowColor:(CGColorRef)shadowColor
{
  if (_shadowColor != shadowColor) {
    if (shadowColor != NULL) {
      CGColorRetain(shadowColor);
    }
    _shadowColor = shadowColor;
    [self _invalidateRenderer];
    ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
      [self setNeedsDisplay];
    });
  }
}

- (CGSize)shadowOffset
{
  return _shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
  if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
    _shadowOffset = shadowOffset;
    [self _invalidateRenderer];
    ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
      [self setNeedsDisplay];
    });
  }
}

- (CGFloat)shadowOpacity
{
  return _shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
  if (_shadowOpacity != shadowOpacity) {
    _shadowOpacity = shadowOpacity;
    [self _invalidateRenderer];
    ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
      [self setNeedsDisplay];
    });
  }
}

- (CGFloat)shadowRadius
{
  return _shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
  if (_shadowRadius != shadowRadius) {
    _shadowRadius = shadowRadius;
    [self _invalidateRenderer];
    ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
      [self setNeedsDisplay];
    });
  }
}

- (UIEdgeInsets)shadowPadding
{
  return [self _renderer].shadower.shadowPadding;
}

#pragma mark - Truncation Message

static NSAttributedString *DefaultTruncationAttributedString()
{
  static NSAttributedString *defaultTruncationAttributedString;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    defaultTruncationAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\u2026", @"Default truncation string")];
  });
  return defaultTruncationAttributedString;
}

- (void)setTruncationAttributedString:(NSAttributedString *)truncationAttributedString
{
  if (ASObjectIsEqual(_truncationAttributedString, truncationAttributedString)) {
    return;
  }

  _truncationAttributedString = [truncationAttributedString copy];
  [self _invalidateTruncationString];
}

- (void)setAdditionalTruncationMessage:(NSAttributedString *)additionalTruncationMessage
{
  if (ASObjectIsEqual(_additionalTruncationMessage, additionalTruncationMessage)) {
    return;
  }

  _additionalTruncationMessage = [additionalTruncationMessage copy];
  [self _invalidateTruncationString];
}

- (void)setTruncationMode:(NSLineBreakMode)truncationMode
{
  if (_truncationMode != truncationMode) {
    _truncationMode = truncationMode;
    [self _invalidateRenderer];
    ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
      [self setNeedsDisplay];
    });
  }
}

- (BOOL)isTruncated
{
  NSRange visibleRange = [self _renderer].visibleRanges[0];
  return visibleRange.length < _attributedString.length;
}

- (void)setMaximumNumberOfLines:(NSUInteger)maximumNumberOfLines
{
    if (_maximumNumberOfLines != maximumNumberOfLines) {
        _maximumNumberOfLines = maximumNumberOfLines;
      [self _invalidateRenderer];
      ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
        [self setNeedsDisplay];
      });
    }
}

- (NSUInteger)lineCount
{
  return [[self _renderer] lineCount];
}

#pragma mark - Truncation Message

- (void)_invalidateTruncationString
{
  _composedTruncationString = [self _prepareTruncationStringForDrawing:[self _composedTruncationString]];
  [self _invalidateRenderer];
  ASDisplayNodeRespectThreadAffinityOfNode(self, ^{
    [self setNeedsDisplay];
  });
}

/**
 * @return the additional truncation message range within the as-rendered text.
 * Must be called from main thread
 */
- (NSRange)_additionalTruncationMessageRangeWithVisibleRange:(NSRange)visibleRange
{
  // Check if we even have an additional truncation message.
  if (!_additionalTruncationMessage) {
    return NSMakeRange(NSNotFound, 0);
  }

  // Character location of the unicode ellipsis (the first index after the visible range)
  NSInteger truncationTokenIndex = NSMaxRange(visibleRange);

  NSUInteger additionalTruncationMessageLength = _additionalTruncationMessage.length;
  // We get the location of the truncation token, then add the length of the
  // truncation attributed string +1 for the space between.
  NSRange range = NSMakeRange(truncationTokenIndex + _truncationAttributedString.length + 1, additionalTruncationMessageLength);
  return range;
}

/**
 * @return the truncation message for the string.  If there are both an
 * additional truncation message and a truncation attributed string, they will
 * be properly composed.
 */
- (NSAttributedString *)_composedTruncationString
{
  // Short circuit if we only have one or the other.
  if (!_additionalTruncationMessage) {
    return _truncationAttributedString;
  }
  if (!_truncationAttributedString) {
    return _additionalTruncationMessage;
  }

  // If we've reached this point, both _additionalTruncationMessage and
  // _truncationAttributedString are present.  Compose them.

  NSMutableAttributedString *newComposedTruncationString = [[NSMutableAttributedString alloc] initWithAttributedString:_truncationAttributedString];
  [newComposedTruncationString replaceCharactersInRange:NSMakeRange(newComposedTruncationString.length, 0) withString:@" "];
  [newComposedTruncationString appendAttributedString:_additionalTruncationMessage];
  return newComposedTruncationString;
}

/**
 * - cleanses it of core text attributes so TextKit doesn't crash
 * - Adds whole-string attributes so the truncation message matches the styling
 * of the body text
 */
- (NSAttributedString *)_prepareTruncationStringForDrawing:(NSAttributedString *)truncationString
{
  truncationString = ASCleanseAttributedStringOfCoreTextAttributes(truncationString);
  NSMutableAttributedString *truncationMutableString = [truncationString mutableCopy];
  // Grab the attributes from the full string
  if (_attributedString.length > 0) {
    NSAttributedString *originalString = _attributedString;
    NSInteger originalStringLength = _attributedString.length;
    // Add any of the original string's attributes to the truncation string,
    // but don't overwrite any of the truncation string's attributes
    NSDictionary *originalStringAttributes = [originalString attributesAtIndex:originalStringLength-1 effectiveRange:NULL];
    [truncationString enumerateAttributesInRange:NSMakeRange(0, truncationString.length) options:0 usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
       NSMutableDictionary *futureTruncationAttributes = [NSMutableDictionary dictionaryWithDictionary:originalStringAttributes];
       [futureTruncationAttributes addEntriesFromDictionary:attributes];
       [truncationMutableString setAttributes:futureTruncationAttributes range:range];
     }];
  }
  return truncationMutableString;
}

@end
