//
//  AudioPlayer.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/5/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AudioPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
 
#ifdef __cplusplus
extern "C" {
#endif 
    
#import "libavcodec/avcodec.h"
#import "libavformat/avformat.h"
    
#ifdef __cplusplus
}
#endif 

#define APTAG [AudioPlayer]

static const int kNumberBuffers = 3;

void FFAVCodecContextToASBD(AVCodecContext *avctx, AudioStreamBasicDescription *asbd)
{
	asbd->mSampleRate       = avctx->sample_rate;
	asbd->mChannelsPerFrame = avctx->channels;
	asbd->mBitsPerChannel   = avctx->bits_per_coded_sample;
    asbd->mBytesPerPacket   = 4;
    asbd->mFramesPerPacket  = 1; // For uncompressed audio, the value is 1
    asbd->mBytesPerFrame    = 4; //_codecCtx->frame_size;
    asbd->mFormatFlags = kAudioFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    asbd->mReserved = 0;

    switch (avctx->sample_fmt) {
        case AV_SAMPLE_FMT_S16:
            asbd->mFormatFlags |= kAudioFormatFlagIsSignedInteger;
            break;
        default:
            break;
    }
    
    NSLog(@"----------------------------------------------");
    NSLog(@"[AP] SAMPLE FMT:%d", avctx->sample_fmt);
    NSLog(@"[AP] SAMPLE RATE:%f", asbd->mSampleRate);
    NSLog(@"[AP] FRAME SIZE(mBytesPerFrame):%lu", asbd->mBytesPerFrame);
    NSLog(@"[AP] CHANNELS:%lu", asbd->mChannelsPerFrame);
    NSLog(@"[AP] BITS PER CHANNELS:%lu", asbd->mBitsPerChannel);
    NSLog(@"[AP] BYTES PER PACKET:%lu", asbd->mBytesPerPacket);
    NSLog(@"----------------------------------------------");
}

@interface AudioPlayer ()
{
    AVFormatContext* _formatCtx;
    AVCodecContext* _codecCtx;
    AVCodec* _codec;
    int _audioStreamIndex;
    AudioQueueRef _aqRef;
    AudioQueueBufferRef _aqBufferRefs[kNumberBuffers];
    NSMutableArray* _sourceNames;
    int  _sourceIndex;
    BOOL _isPlaying;
    BOOL _isStarted;
    BOOL _isPrepared;
    BOOL _isSourceOpened;
}

@property (nonatomic, assign) AVCodecContext* codecCtx;
@property (nonatomic, assign) AVFormatContext* formatCtx;
@property (nonatomic, assign) int audioStreamIndex;
@property (nonatomic, assign) AudioQueueRef aqRef;
@property (nonatomic, assign) BOOL stopFeedingBuffer;
@property (readonly) BOOL canFeedPCM;

@end

void AQDecodeStreamToBuffer(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{    
    AudioPlayer* ap = (AudioPlayer*)inUserData;
    if (!ap.canFeedPCM) {
        NSLog(@"[AP] CAN NOT FEED PCM");
        return;
    }
    
    AVPacket avpkt;
    
    if (av_read_frame(ap.formatCtx, &avpkt) < 0) {
        BOOL shouldStop = NO;
        
        [ap performSelectorOnMainThread:@selector(nextSource) withObject:nil waitUntilDone:YES];
        if (ap.isSourceOpened) { 
            if (av_read_frame(ap.formatCtx, &avpkt) < 0) {
                shouldStop = YES;
            }
        } else {
            shouldStop = YES;
        }
        
        if (shouldStop) {
            NSLog(@"[AP] NO MORE AUDIO DATA");
            //[ap performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO]; 
            return;
        }
    }
    
    //NSLog(@"[AP] PTS:%lld", avpkt.pts);
    
    if (avpkt.stream_index != ap.audioStreamIndex) {
        av_free_packet(&avpkt);
        return;
    }
    
    while (avpkt.size > 0) {
        
        //AVFrame frame;
        //int got_frame;
        //int len = avcodec_decode_audio4(ap.codecCtx, &frame, &got_frame, &avpkt);
        
        int8_t samples[AVCODEC_MAX_AUDIO_FRAME_SIZE];
        int sampleSize = AVCODEC_MAX_AUDIO_FRAME_SIZE;
        int len = avcodec_decode_audio3(ap.codecCtx, (int16_t*)samples, &sampleSize, &avpkt);
        
        if (len < 0) {
            NSLog(@"[AP][ERROR] DECODE ERROR");
            break;
        }
        
        //memcpy(inBuffer->mAudioData, frame.data[0], frame.linesize[0]);
        //inBuffer->mAudioDataByteSize = frame.linesize[0];
        
        memcpy(inBuffer->mAudioData, samples, sampleSize);
        inBuffer->mAudioDataByteSize = sampleSize;
        avpkt.size -= len;
        avpkt.data += len;
        
        AudioQueueEnqueueBuffer(ap.aqRef, inBuffer, 0, NULL);
        //NSLog(@"[AUDIO PLAYER]FEED BUFFER INDEX:%d", [ap checkBufferIndex:inBuffer]);
        
        if (avpkt.size != 0) {
            NSLog(@"[AP][WARNING] avpkt has residuals...%d bytes", avpkt.size);
            break;
        }
    }
}

@implementation AudioPlayer

@synthesize formatCtx = _formatCtx;
@synthesize audioStreamIndex = _audioStream;
@synthesize codecCtx = _codecCtx;
@synthesize aqRef = _aqRef;
@synthesize isPlaying = _isPlaying;
@synthesize isSourceOpened = _isSourceOpened;
@synthesize sourceNames = _sourceNames;
@synthesize canFeedPCM = _canFeedPCM;


+ (void)initFFEngine
{
    avcodec_register_all();
    av_register_all();
}

- (id)init
{
    if ((self=[super init])) {
        _isPrepared = NO;
        _isPlaying  = NO;
        _isSourceOpened = NO;
        _sourceIndex = 0;
        _formatCtx = NULL;
        _codecCtx  = NULL;
        _codec     = NULL;
        
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    [_sourceNames release];
    [super dealloc];
}

- (void)stop
{
    if (!_isPrepared) {
        //NSLog(@"[AP][WARN] !isPlaying || ");
        return;
    }
    _canFeedPCM = NO;
    AudioQueueStop(_aqRef, YES);
    for (int i=0;i<kNumberBuffers;++i) {
        AudioQueueFreeBuffer(_aqRef, _aqBufferRefs[i]);
    }
    [self closeSource];
    AudioQueueDispose(_aqRef, YES);
    _isPlaying = NO;
    _isPrepared = NO;
    _sourceIndex = 0;
    NSLog(@"[AP] STOP");
}

- (void)pause
{
    if (!_isPlaying || !_isPrepared)
        return;
    AudioQueuePause(_aqRef);
    _isPlaying = NO;
     NSLog(@"[AP] PAUSE");
}

- (void)resume
{
    if (_isPlaying || !_isPrepared)
        return;
    
    long ret;
    
    if ((ret = AudioQueueStart(_aqRef, NULL))!=0) {
        NSLog(@"[AP][ERROR] AudioQueueStart, ERRNO:%ld", ret);
        return;
    }
    _isPlaying = YES;
    NSLog(@"[AP] RESUME");
}

- (BOOL)seekTo:(int)s
{
    NSLog(@"[AP][SEEKTO] sec:%d", s);
    // check whether the player is paused.
    if (_isPlaying) {
        NSLog(@"[AP][ERROR] CAN'T SEEK CAUSE IT'S STILL PLAYING.");
        return NO;
    }
    
    // Flush Buffers
    _canFeedPCM = NO;
    AudioQueueStop(_aqRef, NO);
    // Synchronize Stop will cause program hang
    //AudioQueueStop(_aqRef, YES);
    
    // Calculate source index
    int sourceIndex = s / 10;
    [self closeSource];
    [self openSource:sourceIndex];
    
    int offset = s % 10;
    NSLog(@"[AP][SEEK] offset:%d", offset);

    BOOL found = NO;
    
    while (!found) {
        AVPacket avpkt;
        if (av_read_frame(_formatCtx, &avpkt) == 0) {
            
            if (avpkt.pts >= offset*1000) {
                NSLog(@"[AP][SEEK][PTS]:%lld", avpkt.pts);
                found = YES;
            }
        } else {
            NSLog(@"[AP][ERROR] failed to seek pts");
            return NO;
        }
    }
    
    _canFeedPCM = YES;
        
    for (int i=0;i<kNumberBuffers;++i) {
        AQDecodeStreamToBuffer(self, _aqRef, _aqBufferRefs[i]);
    }
    
    AudioQueueStart(_aqRef, NULL);
    return YES;
}

- (BOOL)nextSource
{
    if (_sourceIndex >= [_sourceNames count]-1) {
        return NO;
    }
    
    if ([self openSource:_sourceIndex+1]) {
        return YES;
    }
    return NO;
}

- (BOOL)openSource:(int)index
{
    if (_isSourceOpened) {
        //[self closeSource];
    }
    
    _isSourceOpened = NO;
    
    NSString* fileName = (NSString*)[_sourceNames objectAtIndex:index];
    if (!fileName) {
        NSLog(@"[AP][ERROR] fileName is nil");
        return NO;
    }
    
    _formatCtx = avformat_alloc_context();
    if (0!=avformat_open_input(&_formatCtx, [fileName cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL)) {
        NSLog(@"[AP][ERROR] avformat_open_input error");
        avformat_close_input(&_formatCtx);
        avformat_free_context(_formatCtx);
        _formatCtx = NULL;
        return NO;
    }
    
    // Find audio stream index
    _audioStreamIndex = -1;
    for (int i=0;i<_formatCtx->nb_streams;i++) {
        if (_formatCtx->streams[i]->codec->codec_type== AVMEDIA_TYPE_AUDIO) {
            _audioStreamIndex = i;
            break;
        }
    }
    
    if (-1==_audioStreamIndex) {
        NSLog(@"[AP][ERROR] Cannot find audio stream in %@", fileName);
        avformat_close_input(&_formatCtx);
        return NO;
    }
    
    _codecCtx = _formatCtx->streams[_audioStreamIndex]->codec;
    _codec = avcodec_find_decoder(_codecCtx->codec_id);
    
    if (!_codec) {
        NSLog(@"[AP][ERROR] Cannot find codec, CodecId:%d", _codecCtx->codec_id);
        avformat_close_input(&_formatCtx);
        return NO;
    }
    
    if (_codec->capabilities & CODEC_CAP_TRUNCATED) {
        _codecCtx->flags |= CODEC_FLAG_TRUNCATED;
    }
    
    if (0!=avcodec_open2(_codecCtx, _codec, 0)) {
        NSLog(@"[AP][ERROR] Failed to open codec");
        avformat_close_input(&_formatCtx);
        return NO;
    }
    
    if (!_isPrepared) {
        [self prepare];
    }
    
    _isSourceOpened = YES;
    _sourceIndex = index;
    NSLog(@"[AP] OPEN SOURCE:%d", _sourceIndex);
    return YES;
}

- (void)closeSource
{
    if (!_isSourceOpened)
        return;
    
    avformat_close_input(&_formatCtx);
    _isSourceOpened = NO;
    NSLog(@"[AP] CLOSE SOURCE:%d", _sourceIndex);
}

- (BOOL)prepare
{
    _isPrepared = NO;
    
    AudioStreamBasicDescription asbd = {0};
    asbd.mFormatID = kAudioFormatLinearPCM;
    FFAVCodecContextToASBD(_codecCtx, &asbd);
        
    OSStatus ret;
    if ((ret = AudioQueueNewOutput(&asbd, AQDecodeStreamToBuffer, self, NULL/*CFRunLoopGetCurrent()*/, kCFRunLoopCommonModes, 0, &_aqRef))!=0) {
        NSLog(@"[AP][ERROR] AudioQueueNewOutput");
        return NO;
    }
    
    _canFeedPCM = YES;
    for (int i=0;i<kNumberBuffers;++i) {
        if ((ret = AudioQueueAllocateBuffer(_aqRef, AVCODEC_MAX_AUDIO_FRAME_SIZE, &_aqBufferRefs[i]))!=0) {
            NSLog(@"[AP][ERROR] AudioQueueAllocateBuffer, ERRNO:%ld", ret);
            return NO;
        }
        AQDecodeStreamToBuffer(self, _aqRef, _aqBufferRefs[i]);
    }
    
    Float32 gain = 1.0;
    // Optionally, allow user to override gain setting here
    AudioQueueSetParameter(_aqRef, kAudioQueueParam_Volume, gain);
    
    _isPrepared = YES;
    NSLog(@"[AP] OUTPUT DEVICE IS PREPARED.");
    return YES;
}

- (void)play
{
    if (!_isSourceOpened) {
        [self openSource:0];
    }
    
    NSLog(@"[AP] PLAY");
    
    [self resume];
    
    //do {                                           
        //CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25, false);
    //} while (1);
}

- (int)checkBufferIndex:(AudioQueueBufferRef)inBuffer
{
    for (int i=0;i<kNumberBuffers;++i) {
        if (inBuffer==_aqBufferRefs[i]) {
            return i;
        }
    }
    return -1;
}

@end
