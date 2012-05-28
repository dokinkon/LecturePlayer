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

void FFAVCodecContextToASBD(AVCodecContext *avctx, AudioStreamBasicDescription *asbd)
{
	//asbd->mFormatID         = avctx->codec_tag;
	asbd->mSampleRate       = avctx->sample_rate;
	asbd->mChannelsPerFrame = avctx->channels;
	asbd->mBytesPerPacket   = avctx->block_align;
	asbd->mFramesPerPacket  = avctx->frame_size;
	asbd->mBitsPerChannel   = avctx->bits_per_coded_sample;
    
    switch (avctx->sample_fmt) {
        case AV_SAMPLE_FMT_S16:
            asbd->mFormatFlags |= kAudioFormatFlagIsSignedInteger;
            break;
        default:
            break;
    }
    
    NSLog(@"SAMPLE FMT:%d", avctx->sample_fmt);
}

@interface AudioPlayer ()
{
    AVFormatContext* _formatCtx;
    AVCodecContext* _codecCtx;
    AVCodec* _codec;
    int _audioStreamIndex;
    AudioQueueRef _audioQueueRef;
    BOOL _isPlaying;
}

@property (nonatomic, assign) AVCodecContext* codecCtx;
@property (nonatomic, assign) AVFormatContext* formatCtx;
@property (nonatomic, assign) int audioStreamIndex;
@property (nonatomic, assign) AudioQueueRef audioQueueRef;

@end

void AQOutputCallback(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{    
    AudioPlayer* ap = (AudioPlayer*)inUserData;
    AVPacket avpkt;
    if (av_read_packet(ap.formatCtx, &avpkt) < 0) {
        // NO MORE PACKETS
        [ap stop];
        return;
    }
    
    if (avpkt.stream_index != ap.audioStreamIndex) {
        return;
    }
    
    while (avpkt.size > 0) {
        int8_t samples[AVCODEC_MAX_AUDIO_FRAME_SIZE];
        int sampleSize = AVCODEC_MAX_AUDIO_FRAME_SIZE;
        int len = avcodec_decode_audio3(ap.codecCtx, (int16_t*)samples, &sampleSize, &avpkt);
        if (len < 0) {
            NSLog(@"decode error");
            inBuffer->mAudioDataByteSize = 500;
            AudioQueueEnqueueBuffer(ap.audioQueueRef, inBuffer, 0, NULL);
            break;
        }
        
        memcpy(inBuffer->mAudioData, samples, sampleSize);
        inBuffer->mAudioDataByteSize = sampleSize;
        avpkt.size -= len;
        avpkt.data += len;
        
        //NSLog(@"enqueue audio buffer:%d, residule:%d", sampleSize, avpkt.size);
        //sleep(1);
        AudioQueueEnqueueBuffer(ap.audioQueueRef, inBuffer, 0, NULL);
        
        if (avpkt.size != 0) {
            NSLog(@"WARNING:avpkt has residuals...%d bytes", avpkt.size);
        }
    }
    
    
    
        
}

@implementation AudioPlayer

@synthesize formatCtx = _formatCtx;
@synthesize audioStreamIndex = _audioStream;
@synthesize codecCtx = _codecCtx;
@synthesize audioQueueRef = _audioQueueRef;
@synthesize isPlaying = _isPlaying;

+ (void)initFFEngine
{
    avcodec_register_all();
    av_register_all();
}

- (void)stop
{
    AudioQueueStop(_audioQueueRef, YES);
    NSLog(@"AudioPlayer:stop");
    avformat_free_context(_formatCtx);
    _formatCtx = NULL;
    _isPlaying = NO;
}

- (BOOL)play:(NSString*)fileName
{
    if (!fileName) {
        NSLog(@"[AUDIO PLAYER]ERROR:fileName is nil");
        return false;
    }
    
    _formatCtx = avformat_alloc_context();
    avformat_open_input(&_formatCtx, [fileName cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL);
    
    //avformat_free_context(pFormatCtx);
    
    if (avformat_find_stream_info(_formatCtx, 0) < 0) {
        NSLog(@"Failed to fine stream in %@", fileName);
        return false;
    }
    
    _audioStreamIndex = -1;
    for (int i=0;i<_formatCtx->nb_streams;i++) {
        if (_formatCtx->streams[i]->codec->codec_type== AVMEDIA_TYPE_AUDIO) {
            _audioStreamIndex = i;
            break;
        }
    }
    
    if (-1==_audioStreamIndex) {
        NSLog(@"Cannot find audio stream in %@", fileName);
        return false;
    }
    
    _codecCtx = _formatCtx->streams[_audioStreamIndex]->codec;
    _codec = avcodec_find_decoder(_codecCtx->codec_id);
    
    if (!_codec) {
        NSLog(@"Cannot find codec, CodecId:%d", _codecCtx->codec_id);
        return false;
    }
    
    if (_codec->capabilities & CODEC_CAP_TRUNCATED) {
        _codecCtx->flags |= CODEC_FLAG_TRUNCATED;
    }
    
    if (0!=avcodec_open2(_codecCtx, _codec, 0)) {
        NSLog(@"Failed to open codec");
        return false;
    }
    
    AudioStreamBasicDescription asbd = {0};
    asbd.mSampleRate = _codecCtx->sample_rate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    asbd.mBytesPerPacket = 4;
    asbd.mFramesPerPacket = 1; // For uncompressed audio, the value is 1
    asbd.mBytesPerFrame = 4;//_codecCtx->frame_size;
    asbd.mChannelsPerFrame = _codecCtx->channels;
    asbd.mReserved = 0;
    
    FFAVCodecContextToASBD(_codecCtx, &asbd);
    asbd.mBytesPerPacket = 4;
    asbd.mFramesPerPacket = 1; // For uncompressed audio, the value is 1
    asbd.mBytesPerFrame = 4;//_codecCtx->frame_size;
    
    
    NSLog(@"SAMPLE RATE:%f", asbd.mSampleRate);
    NSLog(@"FRAME SIZE(mBytesPerFrame):%lu", asbd.mBytesPerFrame);
    NSLog(@"CHANNELS:%lu", asbd.mChannelsPerFrame);
    NSLog(@"BITS PER CHANNELS:%lu", asbd.mBitsPerChannel);
    NSLog(@"BYTES PER PACKET:%lu", asbd.mBytesPerPacket);
    
    
    OSStatus ret;
    //if ((ret = AudioQueueNewOutput(&asbd, AQOutputCallback, self, NULL, NULL, 0, &_audioQueueRef))!=0) {
    if ((ret = AudioQueueNewOutput(&asbd, AQOutputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_audioQueueRef))!=0) {
        NSLog(@"ERROR:AudioQueueNewOutput");
        return NO;
    }
    
    AudioQueueBufferRef audioQueueBufferRef;
    if ((ret = AudioQueueAllocateBuffer(_audioQueueRef, AVCODEC_MAX_AUDIO_FRAME_SIZE, &audioQueueBufferRef))!=0) {
        NSLog(@"ERROR:AudioQueueAllocateBuffer, ERRNO:%ld", ret);
        return NO;
    }
    
    AQOutputCallback(self, _audioQueueRef, audioQueueBufferRef);
    
    Float32 gain = 1.0;                                       // 1
    // Optionally, allow user to override gain setting here
    AudioQueueSetParameter(_audioQueueRef, kAudioQueueParam_Volume, gain);
    
    

    if ((ret = AudioQueueStart(_audioQueueRef, NULL))!=0) {
        NSLog(@"ERROR:AudioQueueStart, ERRNO:%ld", ret);
        return NO;
    }
    
    _isPlaying = YES;
    NSLog(@"PLAY:%@", fileName);
    return YES;
    
}

@end
