#import "ParticleSystem.h"

namespace pangea { class Camera; class SphericalMercator;
namespace renderer {
    class Backend;
}}

@interface ParticleSystem() {
}
-(id)init:(NSFileHandle*)resource backend:(pangea::renderer::Backend*)backend mercator:(pangea::SphericalMercator*)mercator;
- (id)initWithXML:(char const *)xmlSource backend:(pangea::renderer::Backend *)backend mercator:(pangea::SphericalMercator *)mercator;
-(void)update:(pangea_float_t)timeStep camera:(pangea::Camera*)camera;
@end
