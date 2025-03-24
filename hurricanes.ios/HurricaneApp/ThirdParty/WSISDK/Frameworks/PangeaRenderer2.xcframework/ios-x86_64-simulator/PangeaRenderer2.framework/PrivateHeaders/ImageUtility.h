#import <memory>

#import <Pangea/Image.hpp>

#import <UIKit/UIKit.h>

// TODO: better naming
std::unique_ptr<pangea::Image> adoptImage(UIImage const *image);

pangea::Image adoptImage(NSData *data, unsigned width, unsigned height);
