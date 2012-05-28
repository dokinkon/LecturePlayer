//PowerPoint_2003.h
// *********************************************************************//
// Declaration of Enumerations defined in Type Library
// *********************************************************************//
typedef enum PpWindowState
{
  ppWindowNormal = 1,
  ppWindowMinimized = 2,
  ppWindowMaximized = 3
} PpWindowState;

typedef enum PpArrangeStyle
{
  ppArrangeTiled = 1,
  ppArrangeCascade = 2
} PpArrangeStyle;

typedef enum PpViewType
{
  ppViewSlide = 1,
  ppViewSlideMaster = 2,
  ppViewNotesPage = 3,
  ppViewHandoutMaster = 4,
  ppViewNotesMaster = 5,
  ppViewOutline = 6,
  ppViewSlideSorter = 7,
  ppViewTitleMaster = 8,
  ppViewNormal = 9,
  ppViewPrintPreview = 10,
  ppViewThumbnails = 11,
  ppViewMasterThumbnails = 12
} PpViewType;

typedef enum PpColorSchemeIndex
{
  ppSchemeColorMixed = 0xFFFFFFFE,
  ppNotSchemeColor = 0,
  ppBackground = 1,
  ppForeground = 2,
  ppShadow = 3,
  ppTitle = 4,
  ppFill = 5,
  ppAccent1 = 6,
  ppAccent2 = 7,
  ppAccent3 = 8
} PpColorSchemeIndex;

typedef enum PpSlideSizeType
{
  ppSlideSizeOnScreen = 1,
  ppSlideSizeLetterPaper = 2,
  ppSlideSizeA4Paper = 3,
  ppSlideSize35MM = 4,
  ppSlideSizeOverhead = 5,
  ppSlideSizeBanner = 6,
  ppSlideSizeCustom = 7,
  ppSlideSizeLedgerPaper = 8,
  ppSlideSizeA3Paper = 9,
  ppSlideSizeB4ISOPaper = 10,
  ppSlideSizeB5ISOPaper = 11,
  ppSlideSizeB4JISPaper = 12,
  ppSlideSizeB5JISPaper = 13,
  ppSlideSizeHagakiCard = 14
} PpSlideSizeType;

typedef enum PpSaveAsFileType
{
  ppSaveAsPresentation = 1,
  ppSaveAsPowerPoint7 = 2,
  ppSaveAsPowerPoint4 = 3,
  ppSaveAsPowerPoint3 = 4,
  ppSaveAsTemplate = 5,
  ppSaveAsRTF = 6,
  ppSaveAsShow = 7,
  ppSaveAsAddIn = 8,
  ppSaveAsPowerPoint4FarEast = 10,
  ppSaveAsDefault = 11,
  ppSaveAsHTML = 12,
  ppSaveAsHTMLv3 = 13,
  ppSaveAsHTMLDual = 14,
  ppSaveAsMetaFile = 15,
  ppSaveAsGIF = 16,
  ppSaveAsJPG = 17,
  ppSaveAsPNG = 18,
  ppSaveAsBMP = 19,
  ppSaveAsWebArchive = 20,
  ppSaveAsTIF = 21,
  ppSaveAsPresForReview = 22,
  ppSaveAsEMF = 23
} PpSaveAsFileType;

typedef enum PpTextStyleType
{
  ppDefaultStyle = 1,
  ppTitleStyle = 2,
  ppBodyStyle = 3
} PpTextStyleType;

typedef enum PpSlideLayout
{
  ppLayoutMixed = 0xFFFFFFFE,
  ppLayoutTitle = 1,
  ppLayoutText = 2,
  ppLayoutTwoColumnText = 3,
  ppLayoutTable = 4,
  ppLayoutTextAndChart = 5,
  ppLayoutChartAndText = 6,
  ppLayoutOrgchart = 7,
  ppLayoutChart = 8,
  ppLayoutTextAndClipart = 9,
  ppLayoutClipartAndText = 10,
  ppLayoutTitleOnly = 11,
  ppLayoutBlank = 12,
  ppLayoutTextAndObject = 13,
  ppLayoutObjectAndText = 14,
  ppLayoutLargeObject = 15,
  ppLayoutObject = 16,
  ppLayoutTextAndMediaClip = 17,
  ppLayoutMediaClipAndText = 18,
  ppLayoutObjectOverText = 19,
  ppLayoutTextOverObject = 20,
  ppLayoutTextAndTwoObjects = 21,
  ppLayoutTwoObjectsAndText = 22,
  ppLayoutTwoObjectsOverText = 23,
  ppLayoutFourObjects = 24,
  ppLayoutVerticalText = 25,
  ppLayoutClipArtAndVerticalText = 26,
  ppLayoutVerticalTitleAndText = 27,
  ppLayoutVerticalTitleAndTextOverChart = 28,
  ppLayoutTwoObjects = 29,
  ppLayoutObjectAndTwoObjects = 30,
  ppLayoutTwoObjectsAndObject = 31
} PpSlideLayout;

typedef enum PpEntryEffect
{
  ppEffectMixed = 0xFFFFFFFE,
  ppEffectNone = 0,
  ppEffectCut = 257,
  ppEffectCutThroughBlack = 258,
  ppEffectRandom = 513,
  ppEffectBlindsHorizontal = 769,
  ppEffectBlindsVertical = 770,
  ppEffectCheckerboardAcross = 1025,
  ppEffectCheckerboardDown = 1026,
  ppEffectCoverLeft = 1281,
  ppEffectCoverUp = 1282,
  ppEffectCoverRight = 1283,
  ppEffectCoverDown = 1284,
  ppEffectCoverLeftUp = 1285,
  ppEffectCoverRightUp = 1286,
  ppEffectCoverLeftDown = 1287,
  ppEffectCoverRightDown = 1288,
  ppEffectDissolve = 1537,
  ppEffectFade = 1793,
  ppEffectUncoverLeft = 2049,
  ppEffectUncoverUp = 2050,
  ppEffectUncoverRight = 2051,
  ppEffectUncoverDown = 2052,
  ppEffectUncoverLeftUp = 2053,
  ppEffectUncoverRightUp = 2054,
  ppEffectUncoverLeftDown = 2055,
  ppEffectUncoverRightDown = 2056,
  ppEffectRandomBarsHorizontal = 2305,
  ppEffectRandomBarsVertical = 2306,
  ppEffectStripsUpLeft = 2561,
  ppEffectStripsUpRight = 2562,
  ppEffectStripsDownLeft = 2563,
  ppEffectStripsDownRight = 2564,
  ppEffectStripsLeftUp = 2565,
  ppEffectStripsRightUp = 2566,
  ppEffectStripsLeftDown = 2567,
  ppEffectStripsRightDown = 2568,
  ppEffectWipeLeft = 2817,
  ppEffectWipeUp = 2818,
  ppEffectWipeRight = 2819,
  ppEffectWipeDown = 2820,
  ppEffectBoxOut = 3073,
  ppEffectBoxIn = 3074,
  ppEffectFlyFromLeft = 3329,
  ppEffectFlyFromTop = 3330,
  ppEffectFlyFromRight = 3331,
  ppEffectFlyFromBottom = 3332,
  ppEffectFlyFromTopLeft = 3333,
  ppEffectFlyFromTopRight = 3334,
  ppEffectFlyFromBottomLeft = 3335,
  ppEffectFlyFromBottomRight = 3336,
  ppEffectPeekFromLeft = 3337,
  ppEffectPeekFromDown = 3338,
  ppEffectPeekFromRight = 3339,
  ppEffectPeekFromUp = 3340,
  ppEffectCrawlFromLeft = 3341,
  ppEffectCrawlFromUp = 3342,
  ppEffectCrawlFromRight = 3343,
  ppEffectCrawlFromDown = 3344,
  ppEffectZoomIn = 3345,
  ppEffectZoomInSlightly = 3346,
  ppEffectZoomOut = 3347,
  ppEffectZoomOutSlightly = 3348,
  ppEffectZoomCenter = 3349,
  ppEffectZoomBottom = 3350,
  ppEffectStretchAcross = 3351,
  ppEffectStretchLeft = 3352,
  ppEffectStretchUp = 3353,
  ppEffectStretchRight = 3354,
  ppEffectStretchDown = 3355,
  ppEffectSwivel = 3356,
  ppEffectSpiral = 3357,
  ppEffectSplitHorizontalOut = 3585,
  ppEffectSplitHorizontalIn = 3586,
  ppEffectSplitVerticalOut = 3587,
  ppEffectSplitVerticalIn = 3588,
  ppEffectFlashOnceFast = 3841,
  ppEffectFlashOnceMedium = 3842,
  ppEffectFlashOnceSlow = 3843,
  ppEffectAppear = 3844,
  ppEffectCircleOut = 3845,
  ppEffectDiamondOut = 3846,
  ppEffectCombHorizontal = 3847,
  ppEffectCombVertical = 3848,
  ppEffectFadeSmoothly = 3849,
  ppEffectNewsflash = 3850,
  ppEffectPlusOut = 3851,
  ppEffectPushDown = 3852,
  ppEffectPushLeft = 3853,
  ppEffectPushRight = 3854,
  ppEffectPushUp = 3855,
  ppEffectWedge = 3856,
  ppEffectWheel1Spoke = 3857,
  ppEffectWheel2Spokes = 3858,
  ppEffectWheel3Spokes = 3859,
  ppEffectWheel4Spokes = 3860,
  ppEffectWheel8Spokes = 3861
} PpEntryEffect;

typedef enum PpTextLevelEffect
{
  ppAnimateLevelMixed = 0xFFFFFFFE,
  ppAnimateLevelNone = 0,
  ppAnimateByFirstLevel = 1,
  ppAnimateBySecondLevel = 2,
  ppAnimateByThirdLevel = 3,
  ppAnimateByFourthLevel = 4,
  ppAnimateByFifthLevel = 5,
  ppAnimateByAllLevels = 16
} PpTextLevelEffect;

typedef enum PpTextUnitEffect
{
  ppAnimateUnitMixed = 0xFFFFFFFE,
  ppAnimateByParagraph = 0,
  ppAnimateByWord = 1,
  ppAnimateByCharacter = 2
} PpTextUnitEffect;

typedef enum PpChartUnitEffect
{
  ppAnimateChartMixed = 0xFFFFFFFE,
  ppAnimateBySeries = 1,
  ppAnimateByCategory = 2,
  ppAnimateBySeriesElements = 3,
  ppAnimateByCategoryElements = 4,
  ppAnimateChartAllAtOnce = 5
} PpChartUnitEffect;

typedef enum PpAfterEffect
{
  ppAfterEffectMixed = 0xFFFFFFFE,
  ppAfterEffectNothing = 0,
  ppAfterEffectHide = 1,
  ppAfterEffectDim = 2,
  ppAfterEffectHideOnClick = 3
} PpAfterEffect;

typedef enum PpAdvanceMode
{
  ppAdvanceModeMixed = 0xFFFFFFFE,
  ppAdvanceOnClick = 1,
  ppAdvanceOnTime = 2
} PpAdvanceMode;

typedef enum PpSoundEffectType
{
  ppSoundEffectsMixed = 0xFFFFFFFE,
  ppSoundNone = 0,
  ppSoundStopPrevious = 1,
  ppSoundFile = 2
} PpSoundEffectType;

typedef enum PpFollowColors
{
  ppFollowColorsMixed = 0xFFFFFFFE,
  ppFollowColorsNone = 0,
  ppFollowColorsScheme = 1,
  ppFollowColorsTextAndBackground = 2
} PpFollowColors;

typedef enum PpUpdateOption
{
  ppUpdateOptionMixed = 0xFFFFFFFE,
  ppUpdateOptionManual = 1,
  ppUpdateOptionAutomatic = 2
} PpUpdateOption;

typedef enum PpParagraphAlignment
{
  ppAlignmentMixed = 0xFFFFFFFE,
  ppAlignLeft = 1,
  ppAlignCenter = 2,
  ppAlignRight = 3,
  ppAlignJustify = 4,
  ppAlignDistribute = 5,
  ppAlignThaiDistribute = 6,
  ppAlignJustifyLow = 7
} PpParagraphAlignment;

typedef enum PpBaselineAlignment
{
  ppBaselineAlignMixed = 0xFFFFFFFE,
  ppBaselineAlignBaseline = 1,
  ppBaselineAlignTop = 2,
  ppBaselineAlignCenter = 3,
  ppBaselineAlignFarEast50 = 4
} PpBaselineAlignment;

typedef enum PpTabStopType
{
  ppTabStopMixed = 0xFFFFFFFE,
  ppTabStopLeft = 1,
  ppTabStopCenter = 2,
  ppTabStopRight = 3,
  ppTabStopDecimal = 4
} PpTabStopType;

typedef enum PpIndentControl
{
  ppIndentControlMixed = 0xFFFFFFFE,
  ppIndentReplaceAttr = 1,
  ppIndentKeepAttr = 2
} PpIndentControl;

typedef enum PpChangeCase
{
  ppCaseSentence = 1,
  ppCaseLower = 2,
  ppCaseUpper = 3,
  ppCaseTitle = 4,
  ppCaseToggle = 5
} PpChangeCase;

typedef enum PpSlideShowPointerType
{
  ppSlideShowPointerNone = 0,
  ppSlideShowPointerArrow = 1,
  ppSlideShowPointerPen = 2,
  ppSlideShowPointerAlwaysHidden = 3,
  ppSlideShowPointerAutoArrow = 4,
  ppSlideShowPointerEraser = 5
} PpSlideShowPointerType;

typedef enum PpSlideShowState
{
  ppSlideShowRunning = 1,
  ppSlideShowPaused = 2,
  ppSlideShowBlackScreen = 3,
  ppSlideShowWhiteScreen = 4,
  ppSlideShowDone = 5
} PpSlideShowState;

typedef enum PpSlideShowAdvanceMode
{
  ppSlideShowManualAdvance = 1,
  ppSlideShowUseSlideTimings = 2,
  ppSlideShowRehearseNewTimings = 3
} PpSlideShowAdvanceMode;

typedef enum PpFileDialogType
{
  ppFileDialogOpen = 1,
  ppFileDialogSave = 2
} PpFileDialogType;

typedef enum PpPrintOutputType
{
  ppPrintOutputSlides = 1,
  ppPrintOutputTwoSlideHandouts = 2,
  ppPrintOutputThreeSlideHandouts = 3,
  ppPrintOutputSixSlideHandouts = 4,
  ppPrintOutputNotesPages = 5,
  ppPrintOutputOutline = 6,
  ppPrintOutputBuildSlides = 7,
  ppPrintOutputFourSlideHandouts = 8,
  ppPrintOutputNineSlideHandouts = 9,
  ppPrintOutputOneSlideHandouts = 10
} PpPrintOutputType;

typedef enum PpPrintHandoutOrder
{
  ppPrintHandoutVerticalFirst = 1,
  ppPrintHandoutHorizontalFirst = 2
} PpPrintHandoutOrder;

typedef enum PpPrintColorType
{
  ppPrintColor = 1,
  ppPrintBlackAndWhite = 2,
  ppPrintPureBlackAndWhite = 3
} PpPrintColorType;

typedef enum PpSelectionType
{
  ppSelectionNone = 0,
  ppSelectionSlides = 1,
  ppSelectionShapes = 2,
  ppSelectionText = 3
} PpSelectionType;

typedef enum PpDirection
{
  ppDirectionMixed = 0xFFFFFFFE,
  ppDirectionLeftToRight = 1,
  ppDirectionRightToLeft = 2
} PpDirection;

typedef enum PpDateTimeFormat
{
  ppDateTimeFormatMixed = 0xFFFFFFFE,
  ppDateTimeMdyy = 1,
  ppDateTimeddddMMMMddyyyy = 2,
  ppDateTimedMMMMyyyy = 3,
  ppDateTimeMMMMdyyyy = 4,
  ppDateTimedMMMyy = 5,
  ppDateTimeMMMMyy = 6,
  ppDateTimeMMyy = 7,
  ppDateTimeMMddyyHmm = 8,
  ppDateTimeMMddyyhmmAMPM = 9,
  ppDateTimeHmm = 10,
  ppDateTimeHmmss = 11,
  ppDateTimehmmAMPM = 12,
  ppDateTimehmmssAMPM = 13,
  ppDateTimeFigureOut = 14
} PpDateTimeFormat;

typedef enum PpTransitionSpeed
{
  ppTransitionSpeedMixed = 0xFFFFFFFE,
  ppTransitionSpeedSlow = 1,
  ppTransitionSpeedMedium = 2,
  ppTransitionSpeedFast = 3
} PpTransitionSpeed;

typedef enum PpMouseActivation
{
  ppMouseClick = 1,
  ppMouseOver = 2
} PpMouseActivation;

typedef enum PpActionType
{
  ppActionMixed = 0xFFFFFFFE,
  ppActionNone = 0,
  ppActionNextSlide = 1,
  ppActionPreviousSlide = 2,
  ppActionFirstSlide = 3,
  ppActionLastSlide = 4,
  ppActionLastSlideViewed = 5,
  ppActionEndShow = 6,
  ppActionHyperlink = 7,
  ppActionRunMacro = 8,
  ppActionRunProgram = 9,
  ppActionNamedSlideShow = 10,
  ppActionOLEVerb = 11,
  ppActionPlay = 12
} PpActionType;

typedef enum PpPlaceholderType
{
  ppPlaceholderMixed = 0xFFFFFFFE,
  ppPlaceholderTitle = 1,
  ppPlaceholderBody = 2,
  ppPlaceholderCenterTitle = 3,
  ppPlaceholderSubtitle = 4,
  ppPlaceholderVerticalTitle = 5,
  ppPlaceholderVerticalBody = 6,
  ppPlaceholderObject = 7,
  ppPlaceholderChart = 8,
  ppPlaceholderBitmap = 9,
  ppPlaceholderMediaClip = 10,
  ppPlaceholderOrgChart = 11,
  ppPlaceholderTable = 12,
  ppPlaceholderSlideNumber = 13,
  ppPlaceholderHeader = 14,
  ppPlaceholderFooter = 15,
  ppPlaceholderDate = 16
} PpPlaceholderType;

typedef enum PpSlideShowType
{
  ppShowTypeSpeaker = 1,
  ppShowTypeWindow = 2,
  ppShowTypeKiosk = 3
} PpSlideShowType;

typedef enum PpPrintRangeType
{
  ppPrintAll = 1,
  ppPrintSelection = 2,
  ppPrintCurrent = 3,
  ppPrintSlideRange = 4,
  ppPrintNamedSlideShow = 5
} PpPrintRangeType;

typedef enum PpAutoSize
{
  ppAutoSizeMixed = 0xFFFFFFFE,
  ppAutoSizeNone = 0,
  ppAutoSizeShapeToFitText = 1
} PpAutoSize;

typedef enum PpMediaType
{
  ppMediaTypeMixed = 0xFFFFFFFE,
  ppMediaTypeOther = 1,
  ppMediaTypeSound = 2,
  ppMediaTypeMovie = 3
} PpMediaType;

typedef enum PpSoundFormatType
{
  ppSoundFormatMixed = 0xFFFFFFFE,
  ppSoundFormatNone = 0,
  ppSoundFormatWAV = 1,
  ppSoundFormatMIDI = 2,
  ppSoundFormatCDAudio = 3
} PpSoundFormatType;

typedef enum PpFarEastLineBreakLevel
{
  ppFarEastLineBreakLevelNormal = 1,
  ppFarEastLineBreakLevelStrict = 2,
  ppFarEastLineBreakLevelCustom = 3
} PpFarEastLineBreakLevel;

typedef enum PpSlideShowRangeType
{
  ppShowAll = 1,
  ppShowSlideRange = 2,
  ppShowNamedSlideShow = 3
} PpSlideShowRangeType;

typedef enum PpFrameColors
{
  ppFrameColorsBrowserColors = 1,
  ppFrameColorsPresentationSchemeTextColor = 2,
  ppFrameColorsPresentationSchemeAccentColor = 3,
  ppFrameColorsWhiteTextOnBlack = 4,
  ppFrameColorsBlackTextOnWhite = 5
} PpFrameColors;

typedef enum PpBorderType
{
  ppBorderTop = 1,
  ppBorderLeft = 2,
  ppBorderBottom = 3,
  ppBorderRight = 4,
  ppBorderDiagonalDown = 5,
  ppBorderDiagonalUp = 6
} PpBorderType;

typedef enum PpHTMLVersion
{
  ppHTMLv3 = 1,
  ppHTMLv4 = 2,
  ppHTMLDual = 3,
  ppHTMLAutodetect = 4
} PpHTMLVersion;

typedef enum PpPublishSourceType
{
  ppPublishAll = 1,
  ppPublishSlideRange = 2,
  ppPublishNamedSlideShow = 3
} PpPublishSourceType;

typedef enum PpBulletType
{
  ppBulletMixed = 0xFFFFFFFE,
  ppBulletNone = 0,
  ppBulletUnnumbered = 1,
  ppBulletNumbered = 2,
  ppBulletPicture = 3
} PpBulletType;

typedef enum PpNumberedBulletStyle
{
  ppBulletStyleMixed = 0xFFFFFFFE,
  ppBulletAlphaLCPeriod = 0,
  ppBulletAlphaUCPeriod = 1,
  ppBulletArabicParenRight = 2,
  ppBulletArabicPeriod = 3,
  ppBulletRomanLCParenBoth = 4,
  ppBulletRomanLCParenRight = 5,
  ppBulletRomanLCPeriod = 6,
  ppBulletRomanUCPeriod = 7,
  ppBulletAlphaLCParenBoth = 8,
  ppBulletAlphaLCParenRight = 9,
  ppBulletAlphaUCParenBoth = 10,
  ppBulletAlphaUCParenRight = 11,
  ppBulletArabicParenBoth = 12,
  ppBulletArabicPlain = 13,
  ppBulletRomanUCParenBoth = 14,
  ppBulletRomanUCParenRight = 15,
  ppBulletSimpChinPlain = 16,
  ppBulletSimpChinPeriod = 17,
  ppBulletCircleNumDBPlain = 18,
  ppBulletCircleNumWDWhitePlain = 19,
  ppBulletCircleNumWDBlackPlain = 20,
  ppBulletTradChinPlain = 21,
  ppBulletTradChinPeriod = 22,
  ppBulletArabicAlphaDash = 23,
  ppBulletArabicAbjadDash = 24,
  ppBulletHebrewAlphaDash = 25,
  ppBulletKanjiKoreanPlain = 26,
  ppBulletKanjiKoreanPeriod = 27,
  ppBulletArabicDBPlain = 28,
  ppBulletArabicDBPeriod = 29,
  ppBulletThaiAlphaPeriod = 30,
  ppBulletThaiAlphaParenRight = 31,
  ppBulletThaiAlphaParenBoth = 32,
  ppBulletThaiNumPeriod = 33,
  ppBulletThaiNumParenRight = 34,
  ppBulletThaiNumParenBoth = 35,
  ppBulletHindiAlphaPeriod = 36,
  ppBulletHindiNumPeriod = 37,
  ppBulletKanjiSimpChinDBPeriod = 38,
  ppBulletHindiNumParenRight = 39,
  ppBulletHindiAlpha1Period = 40
} PpNumberedBulletStyle;

typedef enum PpShapeFormat
{
  ppShapeFormatGIF = 0,
  ppShapeFormatJPG = 1,
  ppShapeFormatPNG = 2,
  ppShapeFormatBMP = 3,
  ppShapeFormatWMF = 4,
  ppShapeFormatEMF = 5
} PpShapeFormat;

typedef enum PpExportMode
{
  ppRelativeToSlide = 1,
  ppClipRelativeToSlide = 2,
  ppScaleToFit = 3,
  ppScaleXY = 4
} PpExportMode;

typedef enum PpPasteDataType
{
  ppPasteDefault = 0,
  ppPasteBitmap = 1,
  ppPasteEnhancedMetafile = 2,
  ppPasteMetafilePicture = 3,
  ppPasteGIF = 4,
  ppPasteJPG = 5,
  ppPastePNG = 6,
  ppPasteText = 7,
  ppPasteHTML = 8,
  ppPasteRTF = 9,
  ppPasteOLEObject = 10,
  ppPasteShape = 11
} PpPasteDataType;

typedef enum MsoAnimEffect
{
  msoAnimEffectCustom = 0,
  msoAnimEffectAppear = 1,
  msoAnimEffectFly = 2,
  msoAnimEffectBlinds = 3,
  msoAnimEffectBox = 4,
  msoAnimEffectCheckerboard = 5,
  msoAnimEffectCircle = 6,
  msoAnimEffectCrawl = 7,
  msoAnimEffectDiamond = 8,
  msoAnimEffectDissolve = 9,
  msoAnimEffectFade = 10,
  msoAnimEffectFlashOnce = 11,
  msoAnimEffectPeek = 12,
  msoAnimEffectPlus = 13,
  msoAnimEffectRandomBars = 14,
  msoAnimEffectSpiral = 15,
  msoAnimEffectSplit = 16,
  msoAnimEffectStretch = 17,
  msoAnimEffectStrips = 18,
  msoAnimEffectSwivel = 19,
  msoAnimEffectWedge = 20,
  msoAnimEffectWheel = 21,
  msoAnimEffectWipe = 22,
  msoAnimEffectZoom = 23,
  msoAnimEffectRandomEffects = 24,
  msoAnimEffectBoomerang = 25,
  msoAnimEffectBounce = 26,
  msoAnimEffectColorReveal = 27,
  msoAnimEffectCredits = 28,
  msoAnimEffectEaseIn = 29,
  msoAnimEffectFloat = 30,
  msoAnimEffectGrowAndTurn = 31,
  msoAnimEffectLightSpeed = 32,
  msoAnimEffectPinwheel = 33,
  msoAnimEffectRiseUp = 34,
  msoAnimEffectSwish = 35,
  msoAnimEffectThinLine = 36,
  msoAnimEffectUnfold = 37,
  msoAnimEffectWhip = 38,
  msoAnimEffectAscend = 39,
  msoAnimEffectCenterRevolve = 40,
  msoAnimEffectFadedSwivel = 41,
  msoAnimEffectDescend = 42,
  msoAnimEffectSling = 43,
  msoAnimEffectSpinner = 44,
  msoAnimEffectStretchy = 45,
  msoAnimEffectZip = 46,
  msoAnimEffectArcUp = 47,
  msoAnimEffectFadedZoom = 48,
  msoAnimEffectGlide = 49,
  msoAnimEffectExpand = 50,
  msoAnimEffectFlip = 51,
  msoAnimEffectShimmer = 52,
  msoAnimEffectFold = 53,
  msoAnimEffectChangeFillColor = 54,
  msoAnimEffectChangeFont = 55,
  msoAnimEffectChangeFontColor = 56,
  msoAnimEffectChangeFontSize = 57,
  msoAnimEffectChangeFontStyle = 58,
  msoAnimEffectGrowShrink = 59,
  msoAnimEffectChangeLineColor = 60,
  msoAnimEffectSpin = 61,
  msoAnimEffectTransparency = 62,
  msoAnimEffectBoldFlash = 63,
  msoAnimEffectBlast = 64,
  msoAnimEffectBoldReveal = 65,
  msoAnimEffectBrushOnColor = 66,
  msoAnimEffectBrushOnUnderline = 67,
  msoAnimEffectColorBlend = 68,
  msoAnimEffectColorWave = 69,
  msoAnimEffectComplementaryColor = 70,
  msoAnimEffectComplementaryColor2 = 71,
  msoAnimEffectContrastingColor = 72,
  msoAnimEffectDarken = 73,
  msoAnimEffectDesaturate = 74,
  msoAnimEffectFlashBulb = 75,
  msoAnimEffectFlicker = 76,
  msoAnimEffectGrowWithColor = 77,
  msoAnimEffectLighten = 78,
  msoAnimEffectStyleEmphasis = 79,
  msoAnimEffectTeeter = 80,
  msoAnimEffectVerticalGrow = 81,
  msoAnimEffectWave = 82,
  msoAnimEffectMediaPlay = 83,
  msoAnimEffectMediaPause = 84,
  msoAnimEffectMediaStop = 85,
  msoAnimEffectPathCircle = 86,
  msoAnimEffectPathRightTriangle = 87,
  msoAnimEffectPathDiamond = 88,
  msoAnimEffectPathHexagon = 89,
  msoAnimEffectPath5PointStar = 90,
  msoAnimEffectPathCrescentMoon = 91,
  msoAnimEffectPathSquare = 92,
  msoAnimEffectPathTrapezoid = 93,
  msoAnimEffectPathHeart = 94,
  msoAnimEffectPathOctagon = 95,
  msoAnimEffectPath6PointStar = 96,
  msoAnimEffectPathFootball = 97,
  msoAnimEffectPathEqualTriangle = 98,
  msoAnimEffectPathParallelogram = 99,
  msoAnimEffectPathPentagon = 100,
  msoAnimEffectPath4PointStar = 101,
  msoAnimEffectPath8PointStar = 102,
  msoAnimEffectPathTeardrop = 103,
  msoAnimEffectPathPointyStar = 104,
  msoAnimEffectPathCurvedSquare = 105,
  msoAnimEffectPathCurvedX = 106,
  msoAnimEffectPathVerticalFigure8 = 107,
  msoAnimEffectPathCurvyStar = 108,
  msoAnimEffectPathLoopdeLoop = 109,
  msoAnimEffectPathBuzzsaw = 110,
  msoAnimEffectPathHorizontalFigure8 = 111,
  msoAnimEffectPathPeanut = 112,
  msoAnimEffectPathFigure8Four = 113,
  msoAnimEffectPathNeutron = 114,
  msoAnimEffectPathSwoosh = 115,
  msoAnimEffectPathBean = 116,
  msoAnimEffectPathPlus = 117,
  msoAnimEffectPathInvertedTriangle = 118,
  msoAnimEffectPathInvertedSquare = 119,
  msoAnimEffectPathLeft = 120,
  msoAnimEffectPathTurnRight = 121,
  msoAnimEffectPathArcDown = 122,
  msoAnimEffectPathZigzag = 123,
  msoAnimEffectPathSCurve2 = 124,
  msoAnimEffectPathSineWave = 125,
  msoAnimEffectPathBounceLeft = 126,
  msoAnimEffectPathDown = 127,
  msoAnimEffectPathTurnUp = 128,
  msoAnimEffectPathArcUp = 129,
  msoAnimEffectPathHeartbeat = 130,
  msoAnimEffectPathSpiralRight = 131,
  msoAnimEffectPathWave = 132,
  msoAnimEffectPathCurvyLeft = 133,
  msoAnimEffectPathDiagonalDownRight = 134,
  msoAnimEffectPathTurnDown = 135,
  msoAnimEffectPathArcLeft = 136,
  msoAnimEffectPathFunnel = 137,
  msoAnimEffectPathSpring = 138,
  msoAnimEffectPathBounceRight = 139,
  msoAnimEffectPathSpiralLeft = 140,
  msoAnimEffectPathDiagonalUpRight = 141,
  msoAnimEffectPathTurnUpRight = 142,
  msoAnimEffectPathArcRight = 143,
  msoAnimEffectPathSCurve1 = 144,
  msoAnimEffectPathDecayingWave = 145,
  msoAnimEffectPathCurvyRight = 146,
  msoAnimEffectPathStairsDown = 147,
  msoAnimEffectPathUp = 148,
  msoAnimEffectPathRight = 149
} MsoAnimEffect;

typedef enum MsoAnimateByLevel
{
  msoAnimateLevelMixed = 0xFFFFFFFF,
  msoAnimateLevelNone = 0,
  msoAnimateTextByAllLevels = 1,
  msoAnimateTextByFirstLevel = 2,
  msoAnimateTextBySecondLevel = 3,
  msoAnimateTextByThirdLevel = 4,
  msoAnimateTextByFourthLevel = 5,
  msoAnimateTextByFifthLevel = 6,
  msoAnimateChartAllAtOnce = 7,
  msoAnimateChartByCategory = 8,
  msoAnimateChartByCategoryElements = 9,
  msoAnimateChartBySeries = 10,
  msoAnimateChartBySeriesElements = 11,
  msoAnimateDiagramAllAtOnce = 12,
  msoAnimateDiagramDepthByNode = 13,
  msoAnimateDiagramDepthByBranch = 14,
  msoAnimateDiagramBreadthByNode = 15,
  msoAnimateDiagramBreadthByLevel = 16,
  msoAnimateDiagramClockwise = 17,
  msoAnimateDiagramClockwiseIn = 18,
  msoAnimateDiagramClockwiseOut = 19,
  msoAnimateDiagramCounterClockwise = 20,
  msoAnimateDiagramCounterClockwiseIn = 21,
  msoAnimateDiagramCounterClockwiseOut = 22,
  msoAnimateDiagramInByRing = 23,
  msoAnimateDiagramOutByRing = 24,
  msoAnimateDiagramUp = 25,
  msoAnimateDiagramDown = 26
} MsoAnimateByLevel;

typedef enum MsoAnimTriggerType
{
  msoAnimTriggerMixed = 0xFFFFFFFF,
  msoAnimTriggerNone = 0,
  msoAnimTriggerOnPageClick = 1,
  msoAnimTriggerWithPrevious = 2,
  msoAnimTriggerAfterPrevious = 3,
  msoAnimTriggerOnShapeClick = 4
} MsoAnimTriggerType;

typedef enum MsoAnimAfterEffect
{
  msoAnimAfterEffectMixed = 0xFFFFFFFF,
  msoAnimAfterEffectNone = 0,
  msoAnimAfterEffectDim = 1,
  msoAnimAfterEffectHide = 2,
  msoAnimAfterEffectHideOnNextClick = 3
} MsoAnimAfterEffect;

typedef enum MsoAnimTextUnitEffect
{
  msoAnimTextUnitEffectMixed = 0xFFFFFFFF,
  msoAnimTextUnitEffectByParagraph = 0,
  msoAnimTextUnitEffectByCharacter = 1,
  msoAnimTextUnitEffectByWord = 2
} MsoAnimTextUnitEffect;

typedef enum MsoAnimEffectRestart
{
  msoAnimEffectRestartAlways = 1,
  msoAnimEffectRestartWhenOff = 2,
  msoAnimEffectRestartNever = 3
} MsoAnimEffectRestart;

typedef enum MsoAnimEffectAfter
{
  msoAnimEffectAfterFreeze = 1,
  msoAnimEffectAfterRemove = 2,
  msoAnimEffectAfterHold = 3,
  msoAnimEffectAfterTransition = 4
} MsoAnimEffectAfter;

typedef enum MsoAnimDirection
{
  msoAnimDirectionNone = 0,
  msoAnimDirectionUp = 1,
  msoAnimDirectionRight = 2,
  msoAnimDirectionDown = 3,
  msoAnimDirectionLeft = 4,
  msoAnimDirectionOrdinalMask = 5,
  msoAnimDirectionUpLeft = 6,
  msoAnimDirectionUpRight = 7,
  msoAnimDirectionDownRight = 8,
  msoAnimDirectionDownLeft = 9,
  msoAnimDirectionTop = 10,
  msoAnimDirectionBottom = 11,
  msoAnimDirectionTopLeft = 12,
  msoAnimDirectionTopRight = 13,
  msoAnimDirectionBottomRight = 14,
  msoAnimDirectionBottomLeft = 15,
  msoAnimDirectionHorizontal = 16,
  msoAnimDirectionVertical = 17,
  msoAnimDirectionAcross = 18,
  msoAnimDirectionIn = 19,
  msoAnimDirectionOut = 20,
  msoAnimDirectionClockwise = 21,
  msoAnimDirectionCounterclockwise = 22,
  msoAnimDirectionHorizontalIn = 23,
  msoAnimDirectionHorizontalOut = 24,
  msoAnimDirectionVerticalIn = 25,
  msoAnimDirectionVerticalOut = 26,
  msoAnimDirectionSlightly = 27,
  msoAnimDirectionCenter = 28,
  msoAnimDirectionInSlightly = 29,
  msoAnimDirectionInCenter = 30,
  msoAnimDirectionInBottom = 31,
  msoAnimDirectionOutSlightly = 32,
  msoAnimDirectionOutCenter = 33,
  msoAnimDirectionOutBottom = 34,
  msoAnimDirectionFontBold = 35,
  msoAnimDirectionFontItalic = 36,
  msoAnimDirectionFontUnderline = 37,
  msoAnimDirectionFontStrikethrough = 38,
  msoAnimDirectionFontShadow = 39,
  msoAnimDirectionFontAllCaps = 40,
  msoAnimDirectionInstant = 41,
  msoAnimDirectionGradual = 42,
  msoAnimDirectionCycleClockwise = 43,
  msoAnimDirectionCycleCounterclockwise = 44
} MsoAnimDirection;

typedef enum MsoAnimType
{
  msoAnimTypeMixed = 0xFFFFFFFE,
  msoAnimTypeNone = 0,
  msoAnimTypeMotion = 1,
  msoAnimTypeColor = 2,
  msoAnimTypeScale = 3,
  msoAnimTypeRotation = 4,
  msoAnimTypeProperty = 5,
  msoAnimTypeCommand = 6,
  msoAnimTypeFilter = 7,
  msoAnimTypeSet = 8
} MsoAnimType;

typedef enum MsoAnimAdditive
{
  msoAnimAdditiveAddBase = 1,
  msoAnimAdditiveAddSum = 2
} MsoAnimAdditive;

typedef enum MsoAnimAccumulate
{
  msoAnimAccumulateNone = 1,
  msoAnimAccumulateAlways = 2
} MsoAnimAccumulate;

typedef enum MsoAnimProperty
{
  msoAnimNone = 0,
  msoAnimX = 1,
  msoAnimY = 2,
  msoAnimWidth = 3,
  msoAnimHeight = 4,
  msoAnimOpacity = 5,
  msoAnimRotation = 6,
  msoAnimColor = 7,
  msoAnimVisibility = 8,
  msoAnimTextFontBold = 100,
  msoAnimTextFontColor = 101,
  msoAnimTextFontEmboss = 102,
  msoAnimTextFontItalic = 103,
  msoAnimTextFontName = 104,
  msoAnimTextFontShadow = 105,
  msoAnimTextFontSize = 106,
  msoAnimTextFontSubscript = 107,
  msoAnimTextFontSuperscript = 108,
  msoAnimTextFontUnderline = 109,
  msoAnimTextFontStrikeThrough = 110,
  msoAnimTextBulletCharacter = 111,
  msoAnimTextBulletFontName = 112,
  msoAnimTextBulletNumber = 113,
  msoAnimTextBulletColor = 114,
  msoAnimTextBulletRelativeSize = 115,
  msoAnimTextBulletStyle = 116,
  msoAnimTextBulletType = 117,
  msoAnimShapePictureContrast = 1000,
  msoAnimShapePictureBrightness = 1001,
  msoAnimShapePictureGamma = 1002,
  msoAnimShapePictureGrayscale = 1003,
  msoAnimShapeFillOn = 1004,
  msoAnimShapeFillColor = 1005,
  msoAnimShapeFillOpacity = 1006,
  msoAnimShapeFillBackColor = 1007,
  msoAnimShapeLineOn = 1008,
  msoAnimShapeLineColor = 1009,
  msoAnimShapeShadowOn = 1010,
  msoAnimShapeShadowType = 1011,
  msoAnimShapeShadowColor = 1012,
  msoAnimShapeShadowOpacity = 1013,
  msoAnimShapeShadowOffsetX = 1014,
  msoAnimShapeShadowOffsetY = 1015
} MsoAnimProperty;

typedef enum PpAlertLevel
{
  ppAlertsNone = 1,
  ppAlertsAll = 2
} PpAlertLevel;

typedef enum PpRevisionInfo
{
  ppRevisionInfoNone = 0,
  ppRevisionInfoBaseline = 1,
  ppRevisionInfoMerged = 2
} PpRevisionInfo;

typedef enum MsoAnimCommandType
{
  msoAnimCommandTypeEvent = 0,
  msoAnimCommandTypeCall = 1,
  msoAnimCommandTypeVerb = 2
} MsoAnimCommandType;

typedef enum MsoAnimFilterEffectType
{
  msoAnimFilterEffectTypeNone = 0,
  msoAnimFilterEffectTypeBarn = 1,
  msoAnimFilterEffectTypeBlinds = 2,
  msoAnimFilterEffectTypeBox = 3,
  msoAnimFilterEffectTypeCheckerboard = 4,
  msoAnimFilterEffectTypeCircle = 5,
  msoAnimFilterEffectTypeDiamond = 6,
  msoAnimFilterEffectTypeDissolve = 7,
  msoAnimFilterEffectTypeFade = 8,
  msoAnimFilterEffectTypeImage = 9,
  msoAnimFilterEffectTypePixelate = 10,
  msoAnimFilterEffectTypePlus = 11,
  msoAnimFilterEffectTypeRandomBar = 12,
  msoAnimFilterEffectTypeSlide = 13,
  msoAnimFilterEffectTypeStretch = 14,
  msoAnimFilterEffectTypeStrips = 15,
  msoAnimFilterEffectTypeWedge = 16,
  msoAnimFilterEffectTypeWheel = 17,
  msoAnimFilterEffectTypeWipe = 18
} MsoAnimFilterEffectType;

typedef enum MsoAnimFilterEffectSubtype
{
  msoAnimFilterEffectSubtypeNone = 0,
  msoAnimFilterEffectSubtypeInVertical = 1,
  msoAnimFilterEffectSubtypeOutVertical = 2,
  msoAnimFilterEffectSubtypeInHorizontal = 3,
  msoAnimFilterEffectSubtypeOutHorizontal = 4,
  msoAnimFilterEffectSubtypeHorizontal = 5,
  msoAnimFilterEffectSubtypeVertical = 6,
  msoAnimFilterEffectSubtypeIn = 7,
  msoAnimFilterEffectSubtypeOut = 8,
  msoAnimFilterEffectSubtypeAcross = 9,
  msoAnimFilterEffectSubtypeFromLeft = 10,
  msoAnimFilterEffectSubtypeFromRight = 11,
  msoAnimFilterEffectSubtypeFromTop = 12,
  msoAnimFilterEffectSubtypeFromBottom = 13,
  msoAnimFilterEffectSubtypeDownLeft = 14,
  msoAnimFilterEffectSubtypeUpLeft = 15,
  msoAnimFilterEffectSubtypeDownRight = 16,
  msoAnimFilterEffectSubtypeUpRight = 17,
  msoAnimFilterEffectSubtypeSpokes1 = 18,
  msoAnimFilterEffectSubtypeSpokes2 = 19,
  msoAnimFilterEffectSubtypeSpokes3 = 20,
  msoAnimFilterEffectSubtypeSpokes4 = 21,
  msoAnimFilterEffectSubtypeSpokes8 = 22,
  msoAnimFilterEffectSubtypeLeft = 23,
  msoAnimFilterEffectSubtypeRight = 24,
  msoAnimFilterEffectSubtypeDown = 25,
  msoAnimFilterEffectSubtypeUp = 26
} MsoAnimFilterEffectSubtype;

typedef enum MsoTriState
{
    msoTrue = -1,
    msoFalse = 0,
    msoCTrue = 1,
    msoTriStateToggle = -3,
    msoTriStateMixed = -2

} ;

enum      PpWindowState;
enum      PpArrangeStyle;
enum      PpViewType;
enum      PpColorSchemeIndex;
enum      PpSlideSizeType;
enum      PpSaveAsFileType;
enum      PpTextStyleType;
enum      PpSlideLayout;
enum      PpEntryEffect;
enum      PpTextLevelEffect;
enum      PpTextUnitEffect;
enum      PpChartUnitEffect;
enum      PpAfterEffect;
enum      PpAdvanceMode;
enum      PpSoundEffectType;
enum      PpFollowColors;
enum      PpUpdateOption;
enum      PpParagraphAlignment;
enum      PpBaselineAlignment;
enum      PpTabStopType;
enum      PpIndentControl;
enum      PpChangeCase;
enum      PpSlideShowPointerType;
enum      PpSlideShowState;
enum      PpSlideShowAdvanceMode;
enum      PpFileDialogType;
enum      PpPrintOutputType;
enum      PpPrintHandoutOrder;
enum      PpPrintColorType;
enum      PpSelectionType;
enum      PpDirection;
enum      PpDateTimeFormat;
enum      PpTransitionSpeed;
enum      PpMouseActivation;
enum      PpActionType;
enum      PpPlaceholderType;
enum      PpSlideShowType;
enum      PpPrintRangeType;
enum      PpAutoSize;
enum      PpMediaType;
enum      PpSoundFormatType;
enum      PpFarEastLineBreakLevel;
enum      PpSlideShowRangeType;
enum      PpFrameColors;
enum      PpBorderType;
enum      PpHTMLVersion;
enum      PpPublishSourceType;
enum      PpBulletType;
enum      PpNumberedBulletStyle;
enum      PpShapeFormat;
enum      PpExportMode;
enum      PpPasteDataType;
enum      MsoAnimEffect;
enum      MsoAnimateByLevel;
enum      MsoAnimTriggerType;
enum      MsoAnimAfterEffect;
enum      MsoAnimTextUnitEffect;
enum      MsoAnimEffectRestart;
enum      MsoAnimEffectAfter;
enum      MsoAnimDirection;
enum      MsoAnimType;
enum      MsoAnimAdditive;
enum      MsoAnimAccumulate;
enum      MsoAnimProperty;
enum      PpAlertLevel;
enum      PpRevisionInfo;
enum      MsoAnimCommandType;
enum      MsoAnimFilterEffectType;
enum      MsoAnimFilterEffectSubtype;
enum      MsoTriState;
