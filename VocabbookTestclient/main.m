//
//  main.m
//  VocabbookTestclient
//
//  Created by Oliver Brehm on 01/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *POSTRequest(NSString *url, NSString *body)
{
     NSData *postData = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
     
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
     [request setURL:[NSURL URLWithString:url]];
     [request setHTTPMethod:@"POST"];
    
    if(body) {
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;

    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    return response;
}

void querySets() {
    
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString *result = POSTRequest(@"http://vocabbook.funpic.de/getSet.php", nil);
        NSLog(@"%@", result);
    }
    return 0;
}

