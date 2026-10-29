package io.github.aytekinsugar1903.riftrush.ads;

import android.app.Activity;
import android.util.Log;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.UserMessagingPlatform;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.HashSet;
import java.util.Set;

/**
 * Rewarded and interstitial AdMob, after a UMP consent update.
 * Show methods never throw: a failure emits a signal and the game continues.
 */
public class RiftRushAdsPlugin extends GodotPlugin {
	private static final String TAG = "RiftRushAds";

	private String rewardedId = "";
	private String interstitialId = "";
	private boolean initialized = false;
	private boolean initStarted = false;
	private RewardedAd rewarded;
	private InterstitialAd interstitial;
	private boolean rewardedLoading = false;
	private boolean interstitialLoading = false;
	private boolean rewardedShowQueued = false;
	private boolean interstitialShowQueued = false;

	public RiftRushAdsPlugin(Godot godot) {
		super(godot);
	}

	@Override
	public String getPluginName() {
		return "RiftRushAds";
	}

	@Override
	public Set<SignalInfo> getPluginSignals() {
		Set<SignalInfo> signals = new HashSet<>();
		signals.add(new SignalInfo("consent_finished", int.class, int.class));
		signals.add(new SignalInfo("rewarded_finished", int.class));
		signals.add(new SignalInfo("interstitial_finished", int.class));
		return signals;
	}

	@UsedByGodot
	public void configure(String rewardedUnitId, String interstitialUnitId) {
		rewardedId = rewardedUnitId == null ? "" : rewardedUnitId;
		interstitialId = interstitialUnitId == null ? "" : interstitialUnitId;
	}

	@UsedByGodot
	public void gatherConsent() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Activity activity = getActivity();
				if (activity == null) {
					emitConsent(0, ConsentInformation.ConsentStatus.UNKNOWN);
					return;
				}
				ConsentRequestParameters params = new ConsentRequestParameters.Builder()
						.setTagForUnderAgeOfConsent(false)
						.build();
				final ConsentInformation info = UserMessagingPlatform.getConsentInformation(activity);
				info.requestConsentInfoUpdate(activity, params, new ConsentInformation.OnConsentInfoUpdateSuccessListener() {
					@Override
					public void onConsentInfoUpdateSuccess() {
						UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity, new com.google.android.ump.ConsentForm.OnConsentFormDismissedListener() {
							@Override
							public void onConsentFormDismissed(com.google.android.ump.FormError formError) {
								if (formError != null) {
									Log.w(TAG, "UMP form: " + formError.getMessage());
								}
								emitConsent(info.canRequestAds() ? 1 : 0, info.getConsentStatus());
							}
						});
					}
				}, new ConsentInformation.OnConsentInfoUpdateFailureListener() {
					@Override
					public void onConsentInfoUpdateFailure(com.google.android.ump.FormError formError) {
						Log.w(TAG, "UMP update failed: " + (formError == null ? "" : formError.getMessage()));
						emitConsent(0, ConsentInformation.ConsentStatus.UNKNOWN);
					}
				});
			}
		});
	}

	@UsedByGodot
	public void initialize() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (initStarted) {
					preload();
					return;
				}
				Activity activity = getActivity();
				if (activity == null) {
					return;
				}
				initStarted = true;
				MobileAds.initialize(activity, new com.google.android.gms.ads.initialization.OnInitializationCompleteListener() {
					@Override
					public void onInitializationComplete(com.google.android.gms.ads.initialization.InitializationStatus status) {
						initialized = true;
						preload();
					}
				});
			}
		});
	}

	@UsedByGodot
	public void showRewarded() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (rewarded != null) {
					presentRewarded();
					return;
				}
				rewardedShowQueued = true;
				loadRewarded();
			}
		});
	}

	@UsedByGodot
	public void showInterstitial() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (interstitial != null) {
					presentInterstitial();
					return;
				}
				interstitialShowQueued = true;
				loadInterstitial();
			}
		});
	}

	private void preload() {
		loadRewarded();
		loadInterstitial();
	}

	private void loadRewarded() {
		if (rewardedLoading || rewarded != null || rewardedId.isEmpty()) {
			if (rewardedId.isEmpty() && rewardedShowQueued) {
				rewardedShowQueued = false;
				emitRewarded(0);
			}
			return;
		}
		Activity activity = getActivity();
		if (activity == null) {
			if (rewardedShowQueued) {
				rewardedShowQueued = false;
				emitRewarded(0);
			}
			return;
		}
		rewardedLoading = true;
		RewardedAd.load(activity, rewardedId, new AdRequest.Builder().build(), new RewardedAdLoadCallback() {
			@Override
			public void onAdLoaded(RewardedAd ad) {
				rewardedLoading = false;
				rewarded = ad;
				if (rewardedShowQueued) {
					rewardedShowQueued = false;
					presentRewarded();
				}
			}

			@Override
			public void onAdFailedToLoad(LoadAdError error) {
				rewardedLoading = false;
				rewarded = null;
				Log.w(TAG, "rewarded load: " + error.getMessage());
				if (rewardedShowQueued) {
					rewardedShowQueued = false;
					emitRewarded(0);
				}
			}
		});
	}

	private void presentRewarded() {
		final RewardedAd ad = rewarded;
		rewarded = null;
		if (ad == null || getActivity() == null) {
			emitRewarded(0);
			loadRewarded();
			return;
		}
		final boolean[] earned = new boolean[] { false };
		ad.setFullScreenContentCallback(new FullScreenContentCallback() {
			@Override
			public void onAdDismissedFullScreenContent() {
				emitRewarded(earned[0] ? 1 : 0);
				loadRewarded();
			}

			@Override
			public void onAdFailedToShowFullScreenContent(AdError error) {
				Log.w(TAG, "rewarded show: " + error.getMessage());
				emitRewarded(0);
				loadRewarded();
			}
		});
		ad.show(getActivity(), new com.google.android.gms.ads.OnUserEarnedRewardListener() {
			@Override
			public void onUserEarnedReward(com.google.android.gms.ads.rewarded.RewardItem rewardItem) {
				earned[0] = true;
			}
		});
	}

	private void loadInterstitial() {
		if (interstitialLoading || interstitial != null || interstitialId.isEmpty()) {
			if (interstitialId.isEmpty() && interstitialShowQueued) {
				interstitialShowQueued = false;
				emitInterstitial(0);
			}
			return;
		}
		Activity activity = getActivity();
		if (activity == null) {
			if (interstitialShowQueued) {
				interstitialShowQueued = false;
				emitInterstitial(0);
			}
			return;
		}
		interstitialLoading = true;
		InterstitialAd.load(activity, interstitialId, new AdRequest.Builder().build(), new InterstitialAdLoadCallback() {
			@Override
			public void onAdLoaded(InterstitialAd ad) {
				interstitialLoading = false;
				interstitial = ad;
				if (interstitialShowQueued) {
					interstitialShowQueued = false;
					presentInterstitial();
				}
			}

			@Override
			public void onAdFailedToLoad(LoadAdError error) {
				interstitialLoading = false;
				interstitial = null;
				Log.w(TAG, "interstitial load: " + error.getMessage());
				if (interstitialShowQueued) {
					interstitialShowQueued = false;
					emitInterstitial(0);
				}
			}
		});
	}

	private void presentInterstitial() {
		final InterstitialAd ad = interstitial;
		interstitial = null;
		if (ad == null || getActivity() == null) {
			emitInterstitial(0);
			loadInterstitial();
			return;
		}
		ad.setFullScreenContentCallback(new FullScreenContentCallback() {
			@Override
			public void onAdDismissedFullScreenContent() {
				emitInterstitial(1);
				loadInterstitial();
			}

			@Override
			public void onAdFailedToShowFullScreenContent(AdError error) {
				Log.w(TAG, "interstitial show: " + error.getMessage());
				emitInterstitial(0);
				loadInterstitial();
			}
		});
		ad.show(getActivity());
	}

	private void emitConsent(int canRequest, int status) {
		emitSignal("consent_finished", canRequest, status);
	}

	private void emitRewarded(int earned) {
		emitSignal("rewarded_finished", earned);
	}

	private void emitInterstitial(int shown) {
		emitSignal("interstitial_finished", shown);
	}
}
