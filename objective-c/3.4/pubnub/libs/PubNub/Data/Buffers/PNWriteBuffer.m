//
//  PNWriteBuffer.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/14/12.
//
//

#import "PNWriteBuffer.h"
#import "PNBaseRequest+Protected.h"


#pragma mark Static

// Stores reference on maximum write TCP
// packet size which will be sent over the
// socket (Default: 4kb)
static NSUInteger const kPNWriteBufferSize = 4096;


#pragma mark - Private interface methods

@interface PNWriteBuffer () {
    
    char *buffer;
}


#pragma mark - Properties

// Stores reference on how long packet payload which should
// be sent over the socket
@property (nonatomic, assign) CFIndex length;


@end


#pragma mark - Public interface methods

@implementation PNWriteBuffer


#pragma mark - Class methods

+ (PNWriteBuffer *)writeBufferForRequest:(PNBaseRequest *)request {
    
    return [[[self class] alloc] initWithRequest:request];
}


#pragma mark - Instance methods

- (id)initWithRequest:(PNBaseRequest *)request {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.requestIdentifier = request.identifier;
        self.length = sizeof(char)*[[request HTTPPayload] length];
        
        // Allocate buffer for HTTP payload
        buffer = malloc(self.length);
        strncpy((char *)buffer, [[request HTTPPayload] UTF8String], self.length);
    }
    
    
    return self;
}

- (BOOL)hasData {
    
    return self.offset < self.length;
}

- (BOOL)isPartialDataSent {
    
    return self.offset != 0 && self.offset != self.length;
}

- (UInt8 *)buffer {
    
    return (UInt8 *)(buffer+self.offset);
}

- (CFIndex)bufferLength {
    
    return MIN(kPNWriteBufferSize, self.length);
}


#pragma mark - Memory management

/**
 * Deallocate and release all resources which
 * was taken for write buffer support
 */
- (void)dealloc {
    
    // Clean up
    free(buffer);
}

#pragma mark -


@end
