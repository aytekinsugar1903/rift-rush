extends Node
## Reklam kancalari (STUB). Gercek SDK (AdMob + UMP) baglaninca sadece bu dosya degisir.
signal ad_event(kind: String, state: String)

func show_interstitial(done: Callable) -> void:
	print("[Ads] interstitial (stub)")
	ad_event.emit("interstitial", "shown")
	done.call()

func show_rewarded(done: Callable) -> void:
	print("[Ads] rewarded (stub) -> odul verildi")
	ad_event.emit("rewarded", "rewarded")
	done.call(true)
