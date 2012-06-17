//
//  CLALight.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import "CLALight.h"

#define CLAMP_PORT 2000


@interface CLALight ()
{
    NSString *_host;
}

@end

@implementation CLALight

- (id) initWithHost:(NSString*)hostname
{
    self = [super init];
    if (self) {
        _host = hostname;
    }
    return self;
}

- (BOOL) sendCommand:(NSString*) command;
{
    NSLog(@"Sending command: %@", command);
    
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, 
                                       (__bridge CFStringRef)_host,
                                       CLAMP_PORT, 
                                       NULL, &writeStream);
    if (!CFWriteStreamOpen(writeStream)) {
        CFStreamError error = CFWriteStreamGetError(writeStream);
        NSLog(@"Failed to open write stream - Domain: %ld Error: %ld", error.domain, error.error);
    }
    else
    {
        const char *commandBytes = (const char*)[command cStringUsingEncoding:NSUTF8StringEncoding];
        
        if (CFWriteStreamWrite(writeStream, (const UInt8 *)commandBytes, strlen(commandBytes)) < 0) {
            CFStreamError error = CFWriteStreamGetError(writeStream);
            NSLog(@"Unable to write - Domain: %ld Error: %ld", error.domain, error.error);
        }
    }
    CFWriteStreamClose(writeStream);
    CFRelease(writeStream);
    writeStream = NULL;
    return YES;
}

#pragma mark Override isEqual and hash to avoid creating the same light twice

-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        CLALight *otherLight = (CLALight*) object;
        return [otherLight.host isEqual:self.host];
    }
    else {
        return NO;
    }
}

-(NSUInteger)hash
{
    return [self.host hash];
}

@end
