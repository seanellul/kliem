import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test ad unit IDs (replace with production IDs before release)
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  // TODO: Replace with production ad unit IDs
  static String get _bannerAdUnitId =>
      Platform.isAndroid ? _testBannerAndroid : _testBannerIos;

  static String get _interstitialAdUnitId =>
      Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos;

  static String get _rewardedAdUnitId =>
      Platform.isAndroid ? _testRewardedAndroid : _testRewardedIos;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isAdFree = false;
  bool _initialized = false;

  bool get isAdFree => _isAdFree;
  BannerAd? get bannerAd => _isAdFree ? null : _bannerAd;
  bool get isRewardedAdLoaded => _rewardedAd != null;

  /// Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _instance._initialized = true;
    debugPrint('AdService: Mobile Ads SDK initialized');
  }

  /// Set ad-free status (from purchase)
  void setAdFree(bool adFree) {
    _isAdFree = adFree;
    if (adFree) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _interstitialAd?.dispose();
      _interstitialAd = null;
    }
    debugPrint('AdService: Ad-free set to $adFree');
  }

  /// Load a banner ad
  void loadBannerAd() {
    if (_isAdFree || !_initialized) return;

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          debugPrint('AdService: Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner ad failed to load: $error');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  /// Load an interstitial ad
  void loadInterstitialAd() {
    if (_isAdFree || !_initialized) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('AdService: Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Load a rewarded ad
  void loadRewardedAd() {
    if (!_initialized) return;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('AdService: Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Show interstitial ad if loaded
  void showInterstitial({VoidCallback? onDismissed}) {
    if (_isAdFree || _interstitialAd == null) {
      onDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Pre-load next one
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Interstitial failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed?.call();
      },
    );

    _interstitialAd!.show();
  }

  /// Show rewarded ad
  void showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) {
    if (_rewardedAd == null) {
      onFailed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Pre-load next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onFailed();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
      onRewarded();
    });
  }

  /// Load all ads (call after initialization)
  void loadAllAds() {
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
