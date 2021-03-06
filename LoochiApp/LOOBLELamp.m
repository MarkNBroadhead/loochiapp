//
//  LOOBLELamp.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 10/3/12.
//
//

#import "LOOBLELamp.h"
#import "DDLog.h"

@interface LOOBLELamp ()

@property (strong) CBPeripheral *peripheral;
@property (strong) CBCharacteristic *rgbChar;

@end

@implementation LOOBLELamp

static const int ddLogLevel = LOG_LEVEL_WARN;

- (id) initWithPeripheral:(CBPeripheral*)connectedPeripheral
{
    self = [super init];
    if (self) {
        self.peripheral = connectedPeripheral;
        self.peripheral.delegate = self;
        
        // Services and characteristics should have been discovered before
        for (CBService *aService in self.peripheral.services) {
            if ([aService.UUID isEqual:[CBUUID UUIDWithString:LOOCHI_SERVICE_UUID]]) {
                for (CBCharacteristic *aChar in aService.characteristics) {
                    if ([aChar.UUID isEqual:[CBUUID UUIDWithString:LOOCHI_CHARACTERISTIC_RGB]]) {
                        self.rgbChar = aChar;
                    }
                }
            }
        }
        
        if (!self.rgbChar) {
            DDLogWarn(@"Unable to find RGB characteristic");
        }
    }
    return self;
}

- (void)performWrite:(UIColor*) color
{
    float fred, fgreen, fblue, falpha;
    uint8_t rgb[3];
    
    [color getRed:&fred green:&fgreen blue:&fblue alpha:&falpha];
    
    rgb[0] = fred * 255;
    rgb[1] = fgreen * 255;
    rgb[2] = fblue * 255;
    
    DDLogVerbose(@"Writing %x %x %x on BLE module", rgb[0], rgb[1], rgb[2]);
    [self.peripheral writeValue:[NSData dataWithBytes:rgb length:3] forCharacteristic:self.rgbChar type:CBCharacteristicWriteWithoutResponse];
}

- (void) setColor:(UIColor*) color
{
    [self performWrite:color];
}

@end
